import 'package:animated_confirm_dialog/animated_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parkxpert/Controller/LocationController/location_controller.dart';
import 'package:parkxpert/Controller/UserController/user_controller.dart';
import 'package:parkxpert/Views/Loaders/logout_loader.dart';
import 'package:parkxpert/res/routes/route_name.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});
  final UserController userController = Get.find<UserController>();

  Widget buildButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    Color color = const Color(0xFF4C84FF),
    Color textColor = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          minimumSize: const Size(double.infinity, 55),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 1,
        centerTitle: true,
        backgroundColor: const Color(0xFF3F51B5), // Soft blue
        title: Text(
          'Settings',
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.04),

            // Rules Button
            buildButton(
              icon: Icons.rule,
              text: "Rules and Terms",
              color: Colors.white,
              textColor: Colors.black87,
              onPressed: () {
                Get.toNamed(RouteName.rulesTerms);
              },
            ),

            // Log Out Button
            buildButton(
              icon: Icons.logout,
              text: "Log Out",
              color: const Color(0xFF4C84FF),
              textColor: Colors.white,
              onPressed: () {
                showCustomDialog(
                  context: context,
                  title: 'Log Out?',
                  message: 'Are you sure you want to log out?',
                  cancelButtonText: 'No',
                  confirmButtonText: 'Yes',
                  cancelButtonColor: Colors.red.shade400,
                  cancelButtonTextColor: Colors.white,
                  confirmButtonColor: Colors.blue.shade600,
                  confirmButtonTextColor: Colors.white,
                  onCancel: () => Navigator.of(context).pop(),
                  onConfirm: () {
                    final box = GetStorage();
                    box.remove('latitude');
                    box.remove('longitude');
                    final locationController = Get.find<LocationController>();
                    locationController.currentLocation.value = null;
                    Get.to(() => LogoutLoader(), transition: Transition.fade);
                  },
                  isFlip: true,
                );
              },
            ),

            // Delete Account Button
          ],
        ),
      ),
    );
  }
}
