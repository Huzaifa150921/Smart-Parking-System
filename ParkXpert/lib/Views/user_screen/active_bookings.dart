import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart'; // Lottie added
import 'package:parkxpert/res/routes/route_name.dart';

class ActiveBookings extends StatefulWidget {
  const ActiveBookings({super.key});

  @override
  State<ActiveBookings> createState() => _ActiveBookingsState();
}

class _ActiveBookingsState extends State<ActiveBookings> {
  bool showShimmer = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => showShimmer = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: showShimmer
            ? ListView.builder(
                padding: const EdgeInsets.only(top: 60, bottom: 16),
                itemCount: 5,
                itemBuilder: (context, index) => shimmerCard(),
              )
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('userId', isEqualTo: userId)
                    .where('status', isEqualTo: 'active')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildNoActiveBookings();
                  }

                  final bookings = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 80, bottom: 16),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final bookingDoc = bookings[index];
                      final booking = bookingDoc.data() as Map<String, dynamic>;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(
                              RouteName.parkingRouteActiveBooking,
                              arguments: {
                                'ownerUid': booking['ownerId'],
                                'bookingId': bookingDoc.id,
                                'parkingName': booking['parkingName'],
                                'parkingAddress': booking['parkingAddress'],
                                'price': booking['price'],
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.blue,
                                  child: Icon(Icons.local_parking,
                                      color: Colors.white, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        booking['parkingName'] ?? 'No name',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        booking['parkingAddress'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Plate No: ${booking['plateNo'] ?? ''}',
                                        style: const TextStyle(
                                            color: Colors.black45,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 12),
                                    ),
                                    Text(
                                      'Rs ${booking['price'].toString()}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${booking['durationInDays']} day(s)',
                                      style: const TextStyle(
                                          color: Colors.black45, fontSize: 12),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget shimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Container(
          height: 112,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  /// 📌 No Active Bookings UI
  Widget _buildNoActiveBookings() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/No_data.json',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No active bookings found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
