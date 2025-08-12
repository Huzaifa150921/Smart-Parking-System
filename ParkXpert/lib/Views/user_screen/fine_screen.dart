import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:parkxpert/utils/utils.dart';

class FineScreen extends StatefulWidget {
  const FineScreen({super.key});

  @override
  State<FineScreen> createState() => _FineScreenState();
}

class _FineScreenState extends State<FineScreen> {
  String? _payingBookingId;

  Stream<List<DocumentSnapshot>> _getUserFines() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      debugPrint("User is not logged in.");
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .where('isFine', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<String> _getParkingName(String parkingId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('parkings')
          .doc(parkingId)
          .get();
      return doc.data()?['parkingName'] ?? 'Unknown Parking';
    } catch (e) {
      debugPrint("Error fetching parking name: $e");
      return 'Unknown Parking';
    }
  }

  Future<void> _payFine({
    required String bookingId,
    required String slotId,
    required String parkingId,
  }) async {
    try {
      final now = Timestamp.now();
      final userId = FirebaseAuth.instance.currentUser?.uid;

      final bookingSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .get();

      final bookingData = bookingSnapshot.data();
      if (bookingData == null) throw Exception("Booking not found.");

      final plateNo = bookingData['plateNo'] ?? 'Unknown';
      final endTime = now;

      final parkingName = await _getParkingName(parkingId);

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
        'status': 'complete',
        'endTime': endTime,
      });

      final monitoringQuery = await FirebaseFirestore.instance
          .collection('slot_monitoring_model_results')
          .where('puid', isEqualTo: parkingId)
          .get();

      if (monitoringQuery.docs.isNotEmpty) {
        final monitoringDoc = monitoringQuery.docs.first;
        final monitoringRef = monitoringDoc.reference;
        final data = monitoringDoc.data();

        if (data.containsKey('slots')) {
          List<dynamic> slots = List.from(data['slots']);
          for (int i = 0; i < slots.length; i++) {
            Map<String, dynamic> slot = Map<String, dynamic>.from(slots[i]);
            if (slot['slot_id'].toString() == slotId) {
              slot['status'] = 'free';
              slots[i] = slot;
              await monitoringRef.update({
                'slots': slots,
                'free': FieldValue.increment(1),
              });
              break;
            }
          }
        }
      }

      await FirebaseFirestore.instance.collection('exit_logs').add({
        'userId': userId,
        'bookingId': bookingId,
        'parkingId': parkingId,
        'parkingName': parkingName,
        'plateNo': plateNo,
        'endTime': endTime,
        'timestamp': now,
      });

      Utils.snackBar("Success", "Fine paid Successfully", false);
    } catch (e) {
      debugPrint("Error paying fine: $e");

      Utils.snackBar("Error", "Failed to pay fine", true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF3F51B5),
        title: Text(
          'Fine Details',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _getUserFines(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final fineDocs = snapshot.data ?? [];

          if (fineDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(
                    flex: 1,
                  ),
                  Lottie.asset(
                    "assets/animations/No_data.json",
                    width: 250, // Increased width
                    height: 250, // Set height to make it bigger
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "No fines found.",
                    style: TextStyle(fontSize: 16),
                  ),
                  Spacer(
                    flex: 2,
                  )
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: fineDocs.length,
            itemBuilder: (context, index) {
              final doc = fineDocs[index];
              final data = doc.data() as Map<String, dynamic>?;

              if (data == null) return const SizedBox();

              final plateNumber = data['plateNo'] ?? 'N/A';
              final fineAmount = data['fine'] ?? 0;
              final slotId = data['slotid']?.toString() ?? 'N/A';
              final parkingId = data['parkingId'] ?? '';
              final bookingId = doc.id;

              return FutureBuilder<String>(
                future: _getParkingName(parkingId),
                builder: (context, nameSnapshot) {
                  final parkingName = nameSnapshot.data ?? 'Loading...';

                  return Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.red.shade200, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: Colors.red, size: 40),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _infoRow("Plate No: ", plateNumber),
                                    const SizedBox(height: 6),
                                    _infoRow("Slot ID: ", slotId),
                                    const SizedBox(height: 6),
                                    _infoRow("Parking: ", parkingName),
                                    const SizedBox(height: 6),
                                    _infoRow(
                                        "Fine Amount: ", "Rs. $fineAmount"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0081C9),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              onPressed: _payingBookingId == bookingId
                                  ? null
                                  : () {
                                      setState(() {
                                        _payingBookingId = bookingId;
                                      });
                                      _payFine(
                                              bookingId: bookingId,
                                              slotId: slotId,
                                              parkingId: parkingId)
                                          .then((_) {
                                        setState(() {
                                          _payingBookingId = null;
                                        });
                                      });
                                    },
                              child: _payingBookingId == bookingId
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.payment),
                                        SizedBox(width: 8),
                                        Text("Pay Fine"),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 14),
        children: [
          TextSpan(
              text: label, style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
