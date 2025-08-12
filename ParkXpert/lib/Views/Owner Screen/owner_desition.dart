import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parkxpert/Controller/Owner%20Controller/owner_registration_track_controller.dart';
import 'package:parkxpert/Views/Loaders/owner_registration_loader.dart';
import 'package:parkxpert/Views/Widgets/Owner%20Screen/drawer/unregister_owner_drawer.dart';
import 'package:parkxpert/Views/Widgets/extra%20features/double_tap_exit_feature.dart';
import 'package:parkxpert/res/routes/route_name.dart';

class OwnerDesition extends StatelessWidget {
  OwnerDesition({super.key});
  final Color navigationBarColor = Colors.black;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final ownerController = Get.find<OwnerRegistrationTrackController>();
    double screenheight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;

    return DoubleTapExitFeature(
      bgColor: Colors.white,
      textColor: Colors.black,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: navigationBarColor,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 73, 73, 73),
          key: _scaffoldKey,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(screenheight * 0.0001),
            child: AppBar(
              centerTitle: true,
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              elevation: 0,
              automaticallyImplyLeading: false,
            ),
          ),
          extendBodyBehindAppBar: true,
          drawer: UnregisterOwnerDrawer(),
          body: Stack(
            children: [
              Positioned(
                top: screenheight * 0.07,
                left: screenwidth * 0.05,
                child: GestureDetector(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: const Icon(Icons.menu, color: Colors.white, size: 28),
                ),
              ),
              Positioned(
                top: screenheight * 0.15,
                child: Container(
                  width: screenwidth,
                  padding: EdgeInsets.symmetric(horizontal: screenwidth * 0.05),
                  child: Card(
                    color: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 6,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Get income with us",
                            style: GoogleFonts.nunito(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: screenheight * 0.02),
                          Row(
                            children: [
                              Icon(Icons.add_location_alt,
                                  color: Colors.white70, size: 24),
                              SizedBox(width: screenwidth * 0.03),
                              Expanded(
                                child: Text(
                                  "List Your Parking Space Easily",
                                  style: GoogleFonts.nunito(
                                      fontSize: 16, color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenheight * 0.01),
                          Row(
                            children: [
                              Icon(Icons.attach_money,
                                  color: Colors.white70, size: 24),
                              SizedBox(width: screenwidth * 0.03),
                              Expanded(
                                child: Text(
                                  "Set Your Own Prices",
                                  style: GoogleFonts.nunito(
                                      fontSize: 16, color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenheight * 0.01),
                          Row(
                            children: [
                              Icon(Icons.payment,
                                  color: Colors.white70, size: 24),
                              SizedBox(width: screenwidth * 0.03),
                              Expanded(
                                child: Text(
                                  "Get Secure Payments",
                                  style: GoogleFonts.nunito(
                                      fontSize: 16, color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenheight * 0.01),
                          Row(
                            children: [
                              Icon(Icons.people,
                                  color: Colors.white70, size: 24),
                              SizedBox(width: screenwidth * 0.03),
                              Expanded(
                                child: Text(
                                  "More Customers, More Income",
                                  style: GoogleFonts.nobile(
                                      fontSize: 16, color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenheight * 0.03),
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                final user = FirebaseAuth.instance.currentUser;

                                if (user == null) {
                                  Get.snackbar(
                                      "Error", "Please log in to continue.");
                                  return;
                                }

                                try {
                                  final doc = await FirebaseFirestore.instance
                                      .collection('pending_owner')
                                      .doc(user.uid)
                                      .get();

                                  if (doc.exists) {
                                    final data = doc.data()!;
                                    final formSubmitted =
                                        data['formSubmitted'] ?? false;

                                    if (formSubmitted) {
                                      // If already submitted, go to status screen
                                      Get.toNamed(
                                          RouteName.ownerRegistrationStatus);
                                    } else {
                                      // If not submitted, create if not exist and go to loader
                                      await ownerController
                                          .createPendingOwnerIfNotExists(
                                              user.uid);
                                      Get.to(() => OwnerRegistrationLoader(),
                                          transition: Transition.fade);
                                    }
                                  } else {
                                    // Doc does not exist, create then navigate to loader
                                    await ownerController
                                        .createPendingOwnerIfNotExists(
                                            user.uid);
                                    Get.to(() => OwnerRegistrationLoader(),
                                        transition: Transition.fade);
                                  }
                                } catch (e) {
                                  // ignore: avoid_print
                                  print("Error checking pending_owner doc: $e");
                                  Get.snackbar("Error",
                                      "Something went wrong. Please try again.");
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 24),
                              ),
                              child: Text(
                                "Start Earning Now!",
                                style: GoogleFonts.nobile(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
