// ignore_for_file: file_names

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_loaders/widgets/circle_dots_loader.dart';
import 'package:shimmer/shimmer.dart';
import 'package:parkxpert/Controller/Owner%20Controller/owner_controller.dart';
import 'package:parkxpert/Views/Widgets/user_screens/drawer/user_drawer_button.dart';
import 'package:parkxpert/res/routes/route_name.dart';
import 'package:parkxpert/utils/utils.dart';

class OwnerDrawer extends StatelessWidget {
  const OwnerDrawer({super.key});

  Future<Map<String, dynamic>?> _fetchOwnerData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc =
        await FirebaseFirestore.instance.collection("owners").doc(uid).get();
    if (doc.exists) return doc.data();
    return null;
  }

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
            FutureBuilder<Map<String, dynamic>?>(
              future: _fetchOwnerData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: EdgeInsets.only(
                      top: screenheight * 0.10,
                      left: screenwidth * 0.10,
                    ),
                    child: Row(
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
                    ),
                  );
                }

                final data = snapshot.data;
                final String name = data?['firstName'] ?? "Owner";
                final String shortName =
                    name.length > 8 ? "${name.substring(0, 8)}..." : name;
                final String? base64Image = data?['profilePic'];

                return Padding(
                  padding: EdgeInsets.only(
                    top: screenheight * 0.10,
                    left: screenwidth * 0.10,
                  ),
                  child: Row(
                    children: [
                      GFAvatar(
                        size: 40,
                        backgroundImage: base64Image != null &&
                                base64Image.isNotEmpty
                            ? MemoryImage(base64Decode(base64Image))
                            : const AssetImage(
                                    "assets/images/default_profile_pic.jfif")
                                as ImageProvider,
                      ),
                      SizedBox(width: screenwidth * 0.08),
                      Text(
                        "Hi, $shortName",
                        style: GoogleFonts.nobile(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade600),

            /// List Options
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserDrawerButton(
                    text: "Profile",
                    icon: Icons.person_outline,
                    func: () => Get.toNamed(RouteName.ownerProfile),
                  ),
                  SizedBox(height: screenheight * 0.02),
                  UserDrawerButton(
                    text: "My Parkings",
                    icon: Icons.local_parking_outlined,
                    func: () => Get.toNamed(RouteName.ownerparking),
                  ),
                  SizedBox(height: screenheight * 0.02),
                  UserDrawerButton(
                    text: "Reviews",
                    icon: Icons.reviews_outlined,
                    func: () => Get.toNamed(RouteName.ownerReview),
                  ),
                  SizedBox(height: screenheight * 0.02),
                  UserDrawerButton(
                    text: "Register Parking",
                    icon: Icons.app_registration_outlined,
                    func: () async {
                      final OwnerController controller = Get.find();
                      final uid = FirebaseAuth.instance.currentUser?.uid;

                      if (uid == null) {
                        Utils.snackBar("Error", "User not logged in", true);
                        return;
                      }

                      // Show loader
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircleDotsLoader(
                            size: 60,
                            color: Colors.blue,
                          ),
                        ),
                      );

                      try {
                        final doc = await FirebaseFirestore.instance
                            .collection("pending_parking")
                            .doc(uid)
                            .get();

                        if (doc.exists &&
                            (doc.data()?['isFormSubmit'] ?? false)) {
                          Navigator.of(context).pop(); // Dismiss loader
                          Get.toNamed(RouteName.ownerRegistrationParkingStatus);
                          return;
                        }

                        await controller.createPendingParkingIfNotExists();

                        Navigator.of(context).pop(); // Dismiss loader
                        Get.toNamed(RouteName.ownerRegisterParking);
                      } catch (e) {
                        Navigator.of(context)
                            .pop(); // Dismiss loader in case of error
                        Utils.snackBar("Error", "Something went wrong", true);
                      }
                    },
                  ),
                  SizedBox(height: screenheight * 0.02),
                  UserDrawerButton(
                    text: "Help",
                    icon: Icons.help_outline,
                    func: () => Get.toNamed(RouteName.ownerHelp),
                  ),
                  SizedBox(height: screenheight * 0.02),
                  UserDrawerButton(
                    text: "Support",
                    icon: Icons.support_outlined,
                    func: () => Get.toNamed(RouteName.ownerSupport),
                  ),
                  SizedBox(height: screenheight * 0.02),
                  UserDrawerButton(
                    text: "Rate Us",
                    icon: Icons.rate_review_outlined,
                    func: () => Get.toNamed(RouteName.ownerRateUs),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.grey.shade600),

            Padding(
              padding: EdgeInsets.only(
                  bottom: screenheight * 0.1, top: screenheight * 0.02),
              child: SizedBox(
                width: screenwidth * 0.7,
                child: GFButton(
                  size: 50,
                  onPressed: () => Get.toNamed(RouteName.userScreen),
                  text: "User mode",
                  color: Colors.blue,
                  textStyle: const TextStyle(
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
