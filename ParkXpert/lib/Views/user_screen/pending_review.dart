import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:parkxpert/Views/user_screen/write_review_screen.dart';

class PendingReview extends StatelessWidget {
  const PendingReview({super.key});

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Stream<List<DocumentSnapshot>> _getPendingReviews() {
    if (_userId == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: _userId)
        .where('status', isEqualTo: 'complete')
        .where('isReviewed', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<String> _getParkingName(String parkingId) async {
    final doc = await FirebaseFirestore.instance
        .collection('parkings')
        .doc(parkingId)
        .get();
    return doc.data()?['parkingName'] ?? 'Unknown Parking';
  }

  Future<String> _getOwnerName(String ownerId) async {
    final doc = await FirebaseFirestore.instance
        .collection('owners')
        .doc(ownerId)
        .get();
    return doc.data()?['firstName'] ?? 'Unknown Owner';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF3F51B5),
        title: Text(
          'Pending Reviews',
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
        stream: _getPendingReviews(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!;

          if (bookings.isEmpty) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 2),
                            SizedBox(
                              width: 300,
                              height: 300,
                              child: Lottie.asset(
                                  'assets/animations/No_data.json'),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No Pending Reviews Found",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(flex: 3),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final data = booking.data() as Map<String, dynamic>;
              final plateNo = data['plateNo'] ?? 'N/A';
              final parkingId = data['parkingId'];
              final ownerId = data['ownerId'];
              final bookingId = booking.id;

              return FutureBuilder<List<String>>(
                future: Future.wait([
                  _getParkingName(parkingId),
                  _getOwnerName(ownerId),
                ]),
                builder: (context, futureSnapshot) {
                  if (!futureSnapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: LinearProgressIndicator(),
                    );
                  }

                  final parkingName = futureSnapshot.data![0];
                  final ownerName = futureSnapshot.data![1];

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: const Duration(seconds: 1),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  WriteReviewScreen(
                            bookingId: bookingId,
                            ownerId: ownerId,
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            final fadeAnimation =
                                Tween<double>(begin: 0.0, end: 1.0)
                                    .animate(animation);
                            return FadeTransition(
                                opacity: fadeAnimation, child: child);
                          },
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_car,
                              size: 36, color: Colors.blueGrey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Plate: $plateNo",
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text("Parking: $parkingName",
                                    style: textTheme.bodyMedium),
                                Text("Owner: $ownerName",
                                    style: textTheme.bodyMedium),
                              ],
                            ),
                          ),
                          const Icon(Icons.rate_review_outlined,
                              color: Colors.orangeAccent, size: 24),
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
}
