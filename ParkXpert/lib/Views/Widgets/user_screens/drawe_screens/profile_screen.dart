import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parkxpert/Controller/UserController/user_controller.dart';
import 'package:parkxpert/Views/Widgets/Custom%20dialog%20box/custom_dialog.dart';
import 'package:parkxpert/Views/Widgets/user_screens/drawe_screens/changepasswordscreen.dart';
import 'package:parkxpert/Views/Widgets/user_screens/drawe_screens/emailverificationscreen.dart';
import 'package:parkxpert/Views/Widgets/user_screens/user_data_show.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double avatarSize = screenWidth * 0.4;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.5,
        centerTitle: true,
        backgroundColor: const Color(0xFF3F51B5),
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
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
      body: SingleChildScrollView(
        child: Center(
          child: Obx(() {
            final user = userController.currentUser.value;
            if (user == null) {
              return const CircularProgressIndicator();
            }

            final nameController = TextEditingController(text: user.name);
            // final emailController = TextEditingController(text: user.email);
            final phoneController =
                TextEditingController(text: user.phoneNumber);
            final RxBool isButtonDisabled = true.obs;

            void validateInput(String value) {
              isButtonDisabled.value = value.isEmpty || value == user.name;
            }

            // bool isValidEmailFormat(String email) {
            //   final emailRegex = RegExp(r'^[\w.+-]+@[a-z\d.-]+\.[a-z]{2,}$');
            //   return emailRegex.hasMatch(email);
            // }

            // void validateEmailInput(String value) {
            //   isButtonDisabled.value = value.isEmpty ||
            //       value == user.email ||
            //       !isValidEmailFormat(value);
            // }

            bool isValidPhoneNumber(String phone) {
              final phoneRegex = RegExp(r'^\d{11}$');
              return phoneRegex.hasMatch(phone);
            }

            void validatePhoneNumberInput(String value) {
              isButtonDisabled.value = value.isEmpty ||
                  value == user.phoneNumber ||
                  !isValidPhoneNumber(value);
            }

            return Column(
              children: [
                SizedBox(height: screenHeight * 0.05),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: '',
                          transitionDuration: const Duration(milliseconds: 300),
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              behavior: HitTestBehavior.opaque,
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                                child: Dialog(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  child: Center(
                                    child: CircleAvatar(
                                      radius: avatarSize * 0.68,
                                      backgroundColor: Colors.white,
                                      backgroundImage: (user.profilePic != null)
                                          ? MemoryImage(
                                              base64Decode(user.profilePic!))
                                          : const AssetImage(
                                                  "assets/images/default_profile_pic.jfif")
                                              as ImageProvider,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          transitionBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                                opacity: animation, child: child);
                          },
                        );
                      },
                      child: Container(
                        width: avatarSize,
                        height: avatarSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            // ignore: deprecated_member_use
                            color: Colors.lightBlueAccent.withOpacity(0.7),
                            width: 4,
                          ),
                          gradient: const LinearGradient(
                            colors: [Colors.lightBlueAccent, Colors.blueAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: avatarSize * 0.48,
                          backgroundColor: Colors.white,
                          backgroundImage: user.profilePic != null
                              ? MemoryImage(base64Decode(user.profilePic!))
                              : const AssetImage(
                                      "assets/images/default_profile_pic.jfif")
                                  as ImageProvider,
                        ),
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.15,
                      left: screenWidth * 0.26,
                      child: GestureDetector(
                        onTap: () {
                          userController.showImageSourceDialog(context);
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 22,
                          child: Icon(Icons.camera_alt,
                              size: 24, color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.06),
                UserDataShow(
                  text: "Name",
                  subtext: user.name,
                  icon: Icons.edit,
                  color: Colors.black87,
                  onPressed: () {
                    CustomAwesomeDialog.show(
                      icon: Icons.person,
                      type: TextInputType.text,
                      context: context,
                      controller: nameController,
                      onChanged: validateInput,
                      isButtonDisabled: isButtonDisabled,
                      onConfirm: () {
                        userController.updateUserName(nameController.text);
                        Get.back();
                      },
                    );
                  },
                ),
                // SizedBox(height: screenHeight * 0.02),
                UserDataShow(
                  text: "Email",
                  subtext: user.email,
                  icon: Icons.edit,
                  color: Colors.black87,
                  onPressed: () {
                    Get.to(
                      () => EmailVerificationScreen(
                          currentEmail: user.email ?? ''),
                      transition: Transition.fadeIn,
                      duration: const Duration(seconds: 1),
                    );
                  },
                ),
                // SizedBox(height: screenHeight * 0.02),
                UserDataShow(
                    text: "Password",
                    subtext: "*************",
                    icon: Icons.lock_outline,
                    color: Colors.black87,
                    onPressed: () {
                      Get.to(() => const ChangePasswordScreen(),
                          transition: Transition.fadeIn,
                          duration: const Duration(seconds: 1));
                    }),
                // SizedBox(height: screenHeight * 0.02),
                UserDataShow(
                  text: "Phone Number",
                  subtext: user.phoneNumber,
                  icon: Icons.edit,
                  color: Colors.black87,
                  onPressed: () {
                    CustomAwesomeDialog.show(
                      icon: Icons.phone,
                      type: TextInputType.phone,
                      context: context,
                      controller: phoneController,
                      onChanged: validatePhoneNumberInput,
                      isButtonDisabled: isButtonDisabled,
                      onConfirm: () {
                        userController
                            .updateUserphoneNumber(phoneController.text);
                        Get.back();
                      },
                    );
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
