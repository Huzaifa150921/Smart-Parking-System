// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parkxpert/Controller/Owner%20Controller/owner_controller.dart';
import 'package:parkxpert/Controller/Owner%20Controller/owner_registration_track_controller.dart';
import 'package:parkxpert/Views/Loaders/owner_registration_loader.dart';
import 'package:parkxpert/res/routes/route_name.dart';
import 'package:parkxpert/utils/utils.dart';

class OwnerRegistrationStatus extends StatefulWidget {
  const OwnerRegistrationStatus({super.key});

  @override
  State<OwnerRegistrationStatus> createState() =>
      _OwnerRegistrationStatusRoutingState();
}

class _OwnerRegistrationStatusRoutingState
    extends State<OwnerRegistrationStatus> {
  @override
  Widget build(BuildContext context) {
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("User not found")),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("pending_owner")
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Scaffold(
              body: Center(
                  child: Text("Error fetching data or document missing")),
            );
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          bool formSubmitted = data['formSubmitted'] ?? false;
          String status = data['status'] ?? '';

          if (formSubmitted && status == "pending") {
            return const PendingScreen();
          } else if (formSubmitted && status == "rejected") {
            return const RejectedScreen();
          } else if (formSubmitted && status == "approved") {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final controller = Get.find<OwnerController>();
              controller.fetchAndCopyPendingOwner();
            });
            return const ApprovedScreen();
          } else {
            return const Scaffold(
              body: Center(child: Text("Loading...")),
            );
          }
        });
  }
}

class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Pending Approval",
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(30),
              child: Icon(
                Icons.hourglass_top,
                size: screenWidth * 0.4,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Your Request is Under Review",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                "We are currently reviewing your details. It will take a few business days to complete the approval process.",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(RouteName.ownerDesitionScreenfade);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: Text(
                "Back to Home",
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RejectedScreen extends StatefulWidget {
  const RejectedScreen({super.key});

  @override
  State<RejectedScreen> createState() => _RejectedScreenState();
}

class _RejectedScreenState extends State<RejectedScreen> {
  String? rejectionReason;
  bool isLoading = false;
  bool isResubmitting = false;

  Future<void> fetchRejectionReason() async {
    setState(() => isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('pending_owner')
          .doc(uid)
          .get();

      if (doc.exists && doc.data()!.containsKey('reason')) {
        rejectionReason = doc['reason'];
      } else {
        rejectionReason = "No reason provided.";
      }
    } catch (e) {
      rejectionReason = "Failed to fetch reason.";
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showReasonDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 60, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                "Rejection Reason",
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                rejectionReason ?? "No reason found.",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 150,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Close",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Request Rejected",
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade900, Colors.red.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cancel, size: 120, color: Colors.red.shade900),
                    const SizedBox(height: 20),
                    Text(
                      "Your request was rejected!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Please check the reason and try again.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // See Reason Button
                    SizedBox(
                      width: 180,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                await fetchRejectionReason();
                                if (mounted) showReasonDialog();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isLoading ? "Loading..." : "See Reason",
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Resubmit Form Button
                    SizedBox(
                      width: 180,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: isResubmitting
                            ? null
                            : () async {
                                final uid =
                                    FirebaseAuth.instance.currentUser?.uid;
                                if (uid == null) return;

                                setState(() => isResubmitting = true);

                                try {
                                  await FirebaseFirestore.instance
                                      .collection('pending_owner')
                                      .doc(uid)
                                      .update({
                                    'status': 'pending',
                                    'formSubmitted': false,
                                    'basicInfoDone': false,
                                    'parkingInfoDone': false,
                                  });

                                  final OwnerRegistrationTrackController
                                      controller = Get.find<
                                          OwnerRegistrationTrackController>();
                                  await controller.refreshOwnerData();

                                  Get.off(() => const OwnerRegistrationLoader(),
                                      transition: Transition.fade);
                                } catch (e) {
                                  Utils.snackBar(
                                      "Error",
                                      "Failed to update data. Please try again",
                                      true);
                                  setState(() => isResubmitting = false);
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Colors.redAccent, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          isResubmitting ? "Submitting..." : "Resubmit Form",
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ApprovedScreen extends StatelessWidget {
  const ApprovedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Request Approved",
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade900, Colors.green.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 120,
                      color: Colors.green.shade900,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Your request was approved!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Please go to dashboard",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Get.toNamed(RouteName.mainOwnerScreenfade);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 24),
                      ),
                      child: Text(
                        "Dashboard",
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
