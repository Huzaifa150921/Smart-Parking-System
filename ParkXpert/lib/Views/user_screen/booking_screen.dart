// booking_screen.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:micro_loaders/micro_loaders.dart';
import 'package:parkxpert/Controller/UserController/user_controller.dart';
import 'package:parkxpert/res/routes/route_name.dart';
import 'package:parkxpert/utils/utils.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> parking;

  const BookingScreen({super.key, required this.parking});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController daysController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final userController = Get.find<UserController>();

  final RegExp plateRegex = RegExp(r'^[A-Z]{2,3}-\d{3,4}$');

  String? errorText;
  int totalAmount = 0;
  Map<String, dynamic>? paymentIntentData;
  List<String> freeSlotIds = [];
  String? selectedSlotId;

  @override
  void initState() {
    super.initState();
    daysController.addListener(_updateTotalAmount);
    _fetchFreeSlots();
  }

  void _updateTotalAmount() {
    final daysStr = daysController.text.trim();
    final int price = (widget.parking['price'] as num?)?.toInt() ?? 0;
    final int days = int.tryParse(daysStr) ?? 0;
    setState(() => totalAmount = days * price);
  }

  Future<void> _fetchFreeSlots() async {
    final puid = widget.parking['puid'];
    final query = await FirebaseFirestore.instance
        .collection('slot_monitoring_model_results')
        .where('puid', isEqualTo: puid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      final List<dynamic> slots = data['slots'] ?? [];

      final List<String> free = slots
          .where((slot) =>
              slot['status']?.toString().toLowerCase() == 'free' &&
              slot['slot_id'] != null)
          .map<String>((slot) => slot['slot_id'].toString())
          .toList();

      setState(() {
        freeSlotIds = free;
        if (free.isNotEmpty) selectedSlotId = free.first;
      });
    }
  }

  @override
  void dispose() {
    daysController.removeListener(_updateTotalAmount);
    daysController.dispose();
    plateController.dispose();
    super.dispose();
  }

  void _proceedToPay() async {
    FocusScope.of(context).unfocus();

    final plate = plateController.text.trim().toUpperCase();
    final daysStr = daysController.text.trim();

    if (plate.isEmpty || daysStr.isEmpty || selectedSlotId == null) {
      setState(() => errorText = "All fields must be filled");
      return;
    }

    if (!plateRegex.hasMatch(plate)) {
      setState(() => errorText = "Invalid number plate. Format: LEB-1234");
      return;
    }

    setState(() => errorText = null);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircleDotsLoader(
          size: 50,
          color: Colors.blueAccent,
          duration: 1,
        ),
      ),
    );

    try {
      final stillFree = await _isSlotStillFree();
      if (!stillFree) {
        // ignore: use_build_context_synchronously
        Navigator.of(context, rootNavigator: true).pop();
        Utils.snackBar("Error", "Selected slot is no longer free", true);
        return;
      }

      await makePayment();
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.of(context, rootNavigator: true).pop();
      Utils.snackBar("Error", "Payment failed: $e", true);
    }
  }

  Future<bool> _isSlotStillFree() async {
    final puid = widget.parking['puid'];
    final snapshot = await FirebaseFirestore.instance
        .collection('slot_monitoring_model_results')
        .where('puid', isEqualTo: puid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      final List<dynamic> slots = data['slots'] ?? [];

      for (final slot in slots) {
        if (slot['slot_id'].toString() == selectedSlotId) {
          return slot['status'].toString().toLowerCase() == 'free';
        }
      }
    }

    return false;
  }

  Future<void> makePayment() async {
    paymentIntentData =
        await createPaymentIntent(totalAmount.toString(), 'PKR');

    await stripe.Stripe.instance.initPaymentSheet(
      paymentSheetParameters: stripe.SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentData!['client_secret'],
        customFlow: false,
        style: ThemeMode.dark,
        merchantDisplayName: 'ParkXpert',
      ),
    );

    await displayPaymentSheet();
  }

  Future<void> displayPaymentSheet() async {
    try {
      await stripe.Stripe.instance.presentPaymentSheet();

      final stillFree = await _isSlotStillFree();
      if (!stillFree) {
        // ignore: use_build_context_synchronously
        Navigator.of(context, rootNavigator: true).pop();
        Utils.snackBar(
            "Error", "Slot was taken before payment finalized", true);
        return;
      }

      final paymentIntentId = paymentIntentData?['id'];
      final chargeId = await getChargeId(paymentIntentId ?? '');
      final transactionId = chargeId ?? paymentIntentId;

      if (transactionId != null) {
        final bookingId = await saveBooking(transactionId);
        // ignore: use_build_context_synchronously
        Navigator.of(context, rootNavigator: true).pop();

        Future.delayed(const Duration(milliseconds: 200), () {
          Get.offAllNamed(RouteName.parkingRoute, arguments: {
            ...widget.parking,
            'bookingId': bookingId,
          });
        });
      }
    } on stripe.StripeException {
      // ignore: use_build_context_synchronously
      Navigator.of(context, rootNavigator: true).pop();
      Utils.snackBar("Cancelled", "Payment cancelled", true);
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.of(context, rootNavigator: true).pop();
      Utils.snackBar("Error", "Unexpected error: $e", true);
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      body: {
        'amount': (int.parse(amount) * 100).toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      },
      headers: {
        'Authorization': 'Bearer Your Api key',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    return jsonDecode(response.body);
  }

  Future<String?> getChargeId(String paymentIntentId) async {
    final url =
        Uri.parse('https://api.stripe.com/v1/payment_intents/$paymentIntentId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer Your Api key',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    final data = jsonDecode(response.body);
    final chargeData = data['charges']?['data'];
    return chargeData != null && chargeData.isNotEmpty
        ? chargeData[0]['id']
        : null;
  }

  Future<String> saveBooking(String transactionId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final parking = widget.parking;
    final int days = int.parse(daysController.text.trim());

    final booking = {
      'userId': userId,
      'parkingId': parking['puid'],
      'ownerId': parking['uid'],
      'parkingName': parking['parkingName'],
      'parkingAddress': parking['parkingAddress'],
      'plateNo': plateController.text.trim().toUpperCase(),
      'slotid': selectedSlotId,
      'startTime': null,
      'isReviewed': false,
      'endTime': null,
      'fine': null,
      'isFine': false,
      'durationInDays': days,
      'price': totalAmount,
      'paymentStatus': 'paid',
      'transactionId': transactionId,
      'createdAt': Timestamp.now(),
      'status': 'active',
    };

    final docRef =
        await FirebaseFirestore.instance.collection('bookings').add(booking);
    await docRef.update({'bookingId': docRef.id});

    final parkingDocRef =
        FirebaseFirestore.instance.collection('parkings').doc(parking['puid']);
    final snapshot = await parkingDocRef.get();
    final currentEarning = (snapshot.data()?['parkingEarning'] ?? 0) as num;
    await parkingDocRef
        .update({'parkingEarning': currentEarning + totalAmount});

    await _markSlotAsReserved();
    await userController.sendInAppNotification(
      uid: parking['uid'],
      title: "You've Got a New Booking!",
      body: "You have a new booking for parking${parking['parkingName']}.",
      type: "booking_alert",
      data: {
        'bookingId': docRef.id,
      },
    );

    await userController.sendInAppNotification(
      uid: userId,
      title: "Booking Confirmed",
      body: "Your parking at ${parking['parkingName']} is booked successfully.",
      type: "booking",
      data: {
        'bookingId': docRef.id,
      },
    );

    return docRef.id;
  }

  Future<void> _markSlotAsReserved() async {
    final puid = widget.parking['puid'];

    final query = await FirebaseFirestore.instance
        .collection('slot_monitoring_model_results')
        .where('puid', isEqualTo: puid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final List<dynamic> slots = doc['slots'] ?? [];
      final int currentFree = (doc['free'] ?? 0) as int;

      final updatedSlots = slots.map((slot) {
        if (slot['slot_id'].toString() == selectedSlotId) {
          return {
            ...slot,
            'status': 'reserved',
          };
        }
        return slot;
      }).toList();

      await doc.reference.update({
        'slots': updatedSlots,
        'free': currentFree > 0 ? currentFree - 1 : 0,
      });
    }
  }

  Widget _buildSlotDropdown() {
    return Card(
      color: Colors.grey[900], // Match other input fields
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: freeSlotIds.isEmpty
            ? null
            : () {
                FocusScope.of(context).unfocus();
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.grey[900],
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  isScrollControlled: true,
                  builder: (_) {
                    return DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.5,
                      minChildSize: 0.3,
                      maxChildSize: 0.7,
                      builder: (_, controller) => ScrollConfiguration(
                        behavior:
                            const ScrollBehavior().copyWith(overscroll: false),
                        child: ListView.builder(
                          controller: controller,
                          itemCount: freeSlotIds.length,
                          itemBuilder: (context, index) {
                            final slotId = freeSlotIds[index];
                            return ListTile(
                              leading: const Icon(Icons.local_parking,
                                  color: Colors.cyanAccent),
                              title: Text(
                                "Slot $slotId",
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              onTap: () {
                                setState(() => selectedSlotId = slotId);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              const Icon(Icons.local_parking,
                  color: Colors.blueAccent, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  selectedSlotId != null
                      ? "Selected Slot: $selectedSlotId"
                      : freeSlotIds.isEmpty
                          ? "No free slots available"
                          : "Tap to select a slot",
                  style: TextStyle(
                    color:
                        freeSlotIds.isEmpty ? Colors.redAccent : Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_drop_down,
                  color: Colors.white70, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title:
            const Text("Book Parking", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Enter Booking Details",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                const SizedBox(height: 30),
                _buildInputCard(
                  label: "Number of Days",
                  controller: daysController,
                  hintText: "e.g. 6",
                  keyboardType: TextInputType.number,
                  icon: Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 20),
                _buildInputCard(
                  label: "Car Plate Number",
                  controller: plateController,
                  hintText: "e.g. LEB-1234",
                  icon: Icons.directions_car_filled_outlined,
                ),
                const SizedBox(height: 20),
                _buildSlotDropdown(),
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(errorText!,
                        style: const TextStyle(color: Colors.redAccent)),
                  ),
                const SizedBox(height: 40),
                _buildGradientButton("Proceed to Pay", _proceedToPay),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            icon: Icon(icon, color: Colors.blueAccent),
            labelText: label,
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white24),
            labelStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
    );
  }
}
