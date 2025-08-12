import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:parkxpert/Controller/UserController/user_controller.dart';
import 'package:parkxpert/Views/Widgets/user_screens/drawer/user_drawer_button.dart';
import 'package:parkxpert/res/routes/route_name.dart';

class UserDrawer extends StatelessWidget {
  UserDrawer({super.key});
  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return Container(
      width: screenwidth * 0.8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black87, Colors.blueGrey.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: GFDrawer(
        color: const Color.fromARGB(255, 24, 24, 24),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: screenheight * 0.10,
                left: screenwidth * 0.10,
              ),
              child: Obx(() {
                final user = userController.currentUser.value;
                if (user == null) {
                  return Row(
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade700,
                        highlightColor: Colors.grey.shade500,
                        child: const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey,
                        ),
                      ),
                      SizedBox(width: screenwidth * 0.08),
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade700,
                        highlightColor: Colors.grey.shade500,
                        child: Container(
                          width: 100,
                          height: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                }

                final String name = user.name ?? "Guest";
                final String shortName =
                    name.length > 8 ? "${name.substring(0, 8)}..." : name;
                final String? base64Image = user.profilePic;

                return Row(
                  children: [
                    GFAvatar(
                      size: 40,
                      backgroundImage:
                          base64Image != null && base64Image.isNotEmpty
                              ? MemoryImage(base64Decode(base64Image))
                              : const AssetImage(
                                      "assets/images/default_profile_pic.jfif")
                                  as ImageProvider,
                      backgroundColor: Colors.grey[800],
                    ),
                    SizedBox(width: screenwidth * 0.08),
                    Text(
                      "Hi, $shortName",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                );
              }),
            ),
            SizedBox(height: screenheight * 0.03),
            Divider(color: const Color.fromARGB(162, 158, 158, 158)),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  UserDrawerButton(
                    text: "Profile",
                    icon: Icons.person_outline,
                    func: () => Get.toNamed(RouteName.profileScreen),
                  ),
                  SizedBox(height: screenheight * 0.02),
                  UserDrawerButton(
                    text: "Bookings",
                    icon: Icons.history_outlined,
                    func: () => Get.toNamed(RouteName.bookingScreen),
                  ),
                  SizedBox(height: screenheight * 0.02),
                  UserDrawerButton(
                    text: "Notifications",
                    icon: Icons.notifications_outlined,
                    func: () => Get.toNamed(RouteName.notificationScreen),
                  ),
                  SizedBox(height: screenheight * 0.02),
                  UserDrawerButton(
                    text: "Settings",
                    icon: Icons.settings_outlined,
                    func: () => Get.toNamed(RouteName.settingScreen),
                  ),
                  SizedBox(height: screenheight * 0.02),
                  UserDrawerButton(
                    text: "Parking Fine",
                    icon: Icons.note_add_outlined,
                    func: () => Get.toNamed(RouteName.userFineScreen),
                  ),
                  SizedBox(height: screenheight * 0.02),
                  UserDrawerButton(
                    text: "Pending Reviews",
                    icon: Icons.pending_actions_outlined,
                    func: () => Get.toNamed(RouteName.pendingReview),
                  ),
                  SizedBox(height: screenheight * 0.02),
                  UserDrawerButton(
                    text: "Help",
                    icon: Icons.help_outline,
                    func: () => Get.toNamed(RouteName.helpScreen),
                  ),
                  SizedBox(height: screenheight * 0.02),
                  UserDrawerButton(
                    text: "Support",
                    icon: Icons.support_outlined,
                    func: () => Get.toNamed(RouteName.supportScreen),
                  ),
                  SizedBox(height: screenheight * 0.02),
                  UserDrawerButton(
                    text: "Rate Us",
                    icon: Icons.rate_review_outlined,
                    func: () => Get.toNamed(RouteName.rateusScreen),
                  ),
                ],
              ),
            ),
            Divider(color: const Color.fromARGB(162, 158, 158, 158)),
            Padding(
              padding: EdgeInsets.only(
                  bottom: screenheight * 0.1, top: screenheight * 0.02),
              child: SizedBox(
                width: screenwidth * 0.7,
                child: GFButton(
                  size: 50,
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      Get.snackbar("Error", "Please log in first.");
                      return;
                    }

                    try {
                      final doc = await FirebaseFirestore.instance
                          .collection('pending_owner')
                          .doc(user.uid)
                          .get();

                      if (doc.exists) {
                        final data = doc.data()!;
                        final status =
                            (data['status'] ?? '').toString().toLowerCase();

                        if (status == 'approved') {
                          Get.toNamed(RouteName.mainOwnerScreen);
                        } else {
                          Get.toNamed(RouteName.ownerDesitionScreen);
                        }
                      } else {
                        Get.toNamed(RouteName.ownerDesitionScreen);
                      }
                    } catch (e) {
                      print("Error fetching owner status: $e");
                      Get.snackbar(
                          "Error", "Unable to check owner status. Try again.");
                    }
                  },
                  text: "Owner mode",
                  color: Colors.blue,
                  textStyle: GoogleFonts.nobile(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
