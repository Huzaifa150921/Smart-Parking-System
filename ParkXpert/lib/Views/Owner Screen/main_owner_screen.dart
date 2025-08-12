import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:parkxpert/Views/Widgets/Owner%20Screen/drawer/owner_drawer.dart';
import 'package:parkxpert/res/routes/route_name.dart';

class MainOwnerScreen extends StatelessWidget {
  MainOwnerScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF2F4F7),
        drawer: OwnerDrawer(),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0081C9),
          elevation: 1,
          title: const Text(
            "Dashboard",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        /// BODY
        body: Column(
          children: [
            /// Wallet Card with StreamBuilder
            Container(
              height: screenHeight * 0.22,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded,
                        color: Color(0xFF0081C9), size: 36),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Total Income",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 14)),
                          const SizedBox(height: 6),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("parkings")
                                .where("uid",
                                    isEqualTo:
                                        FirebaseAuth.instance.currentUser?.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 100,
                                    height: 28,
                                    color: Colors.grey,
                                  ),
                                );
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Text("Rs. 0",
                                    style: TextStyle(
                                        color: Color(0xFF0081C9),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold));
                              }

                              double total = 0;
                              for (var doc in snapshot.data!.docs) {
                                final data = doc.data() as Map<String, dynamic>;
                                total +=
                                    (data['parkingEarning'] ?? 0).toDouble();
                              }

                              return Text(
                                "Rs. ${total.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  color: Color(0xFF0081C9),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Dashboard Grid
            Expanded(
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _buildDashboardIcon(
                        Icons.account_circle_outlined,
                        "Profile",
                        () => Get.toNamed(RouteName.ownerProfilefadein)),
                    _buildDashboardIcon(Icons.local_parking_rounded, "Parkings",
                        () => Get.toNamed(RouteName.ownerparkingfadein)),
                    _buildDashboardIcon(Icons.reviews_rounded, "Help",
                        () => Get.toNamed(RouteName.ownerHelpfadein)),
                    _buildDashboardIcon(Icons.highlight_remove_rounded,
                        "Revenue", () => Get.toNamed(RouteName.revenueScreen)),
                    _buildDashboardIcon(Icons.star_border_rounded, "Reviews",
                        () => Get.toNamed(RouteName.ownerReviewfadein)),
                    _buildDashboardIcon(Icons.support_agent_rounded, "Support",
                        () => Get.toNamed(RouteName.ownerSupportfadein)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dashboard Item Widget
  Widget _buildDashboardIcon(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(2, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Color(0xFF0081C9)),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
