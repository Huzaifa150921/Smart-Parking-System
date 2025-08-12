import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parkxpert/Views/user_screen/booking_screen.dart';
import 'package:parkxpert/utils/utils.dart';
import 'package:shimmer/shimmer.dart';

class ParkingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> parking;

  const ParkingDetailScreen({super.key, required this.parking});

  @override
  State<ParkingDetailScreen> createState() => _ParkingDetailScreenState();
}

class _ParkingDetailScreenState extends State<ParkingDetailScreen> {
  String? ownerName;
  String? ownerImage;
  String? phone;
  String? email;
  String? parkingPrice;

  @override
  void initState() {
    super.initState();
    _fetchOwnerData();
  }

  Future<void> _fetchOwnerData() async {
    final uid = widget.parking["uid"];
    final pid = widget.parking["puid"];

    try {
      final ownerSnapshot =
          await FirebaseFirestore.instance.collection('owners').doc(uid).get();
      final userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final parkingSnapshot = await FirebaseFirestore.instance
          .collection('parkings')
          .doc(pid)
          .get();

      setState(() {
        if (ownerSnapshot.exists) {
          final ownerData = ownerSnapshot.data()!;
          ownerName = ownerData['firstName'] ?? "Unknown Owner";
          ownerImage = ownerData['profilePic'];
        }

        if (userSnapshot.exists) {
          final userData = userSnapshot.data()!;
          phone = userData['phoneNumber'] ?? "No Phone";
          email = userData['email'] ?? "No Email";
        }

        if (parkingSnapshot.exists) {
          final parkingData = parkingSnapshot.data()!;
          parkingPrice = parkingData['price']?.toString() ?? "N/A";
        }
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final parking = widget.parking;
    final puid = parking["puid"];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Parking Details",
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('slot_monitoring_model_results')
            .where('puid', isEqualTo: puid)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          final slotDoc = snapshot.data?.docs.first;
          final slotData = slotDoc?.data() as Map<String, dynamic>?;

          final int freeSlots = slotData?['free'] ?? 0;
          final bool hasAvailableSlots = freeSlots > 0;

          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    _buildOwnerCard(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildInfoTile(Icons.currency_rupee,
                              Colors.greenAccent, parkingPrice),
                          GestureDetector(
                            onTap: () => _showSlotsPopup(context),
                            child: _buildInfoTile(
                                Icons.local_parking,
                                Colors.blueAccent,
                                "Slots Available: $freeSlots",
                                clickable: true),
                          ),
                          _buildInfoTile(Icons.location_on, Colors.redAccent,
                              parking["parkingAddress"] ?? "Unknown Location"),
                          _buildInfoTile(Icons.phone, Colors.lightGreen, phone),
                          _buildInfoTile(
                              Icons.email, Colors.orangeAccent, email),
                        ],
                      ),
                    ),
                    _buildBookingButton(hasAvailableSlots),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOwnerCard() {
    if (ownerName == null || ownerImage == null) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[500]!,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }

    ImageProvider imageProvider;
    if (ownerImage!.startsWith("http")) {
      imageProvider = NetworkImage(ownerImage!);
    } else if (ownerImage!.length > 100) {
      try {
        final decodedBytes = base64Decode(ownerImage!);
        imageProvider = MemoryImage(decodedBytes);
      } catch (_) {
        imageProvider =
            const AssetImage("assets/images/default_profile_pic.jfif");
      }
    } else {
      imageProvider =
          const AssetImage("assets/images/default_profile_pic.jfif");
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 23, 98, 226).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
              color: Colors.blueAccent.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(radius: 55, backgroundImage: imageProvider),
          const SizedBox(height: 12),
          Text(ownerName!,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, Color color, String? text,
      {bool clickable = false}) {
    return Card(
      color: Colors.grey[900]!.withOpacity(0.5),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: text != null
            ? Text(
                text,
                style: TextStyle(
                  color: clickable ? Colors.blueAccent : Colors.white70,
                  fontSize: 18,
                  fontWeight: clickable ? FontWeight.bold : FontWeight.normal,
                ),
              )
            : Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[500]!,
                child: Container(height: 20, color: Colors.grey)),
        trailing: clickable
            ? const Icon(Icons.chevron_right, color: Colors.blueAccent)
            : null,
      ),
    );
  }

  Widget _buildBookingButton(bool hasAvailableSlots) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: hasAvailableSlots
            ? const LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)])
            : const LinearGradient(colors: [Colors.grey, Colors.grey]),
      ),
      child: ElevatedButton(
        onPressed: hasAvailableSlots ? _handleBooking : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          hasAvailableSlots ? "Book Now" : "No Slots Available",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: hasAvailableSlots ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Future<void> _handleBooking() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        Utils.snackBar("Already Booked",
            "You already have an active booking. You can't book again", true);
      } else {
        Get.to(
          () => BookingScreen(parking: widget.parking),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      Utils.snackBar(
          "Error", "Failed to check bookings: ${e.toString()}", true);
    }
  }

  void _showSlotsPopup(BuildContext context) {
    final puid = widget.parking["puid"];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: 380,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 5),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  gradient: LinearGradient(
                      colors: [Color(0xFF1E1E1E), Color(0xFF121212)]),
                ),
                child: const Center(
                  child: Text("Available Slots",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('slot_monitoring_model_results')
                      .where('puid', isEqualTo: puid)
                      .limit(1)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final slotDoc = snapshot.data?.docs.first;
                    final slotData = slotDoc?.data() as Map<String, dynamic>?;
                    final List<dynamic> slotDetails = slotData?['slots'] ?? [];

                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: slotDetails.length,
                        itemBuilder: (context, index) {
                          final slot = slotDetails[index];
                          final status =
                              slot['status']?.toString().toLowerCase() ??
                                  'unknown';
                          final slotId = slot['slot_id']?.toString() ?? 'N/A';

                          Color slotColor;
                          switch (status) {
                            case "free":
                              slotColor = Colors.green;
                              break;
                            case "occupied":
                              slotColor = Colors.red;
                              break;
                            case "reserved":
                              slotColor = Colors.yellow;
                              break;
                            default:
                              slotColor = Colors.grey;
                          }

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: slotColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: slotColor.withOpacity(0.6),
                                    blurRadius: 10,
                                    spreadRadius: 2),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text("Slot $slotId",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
