import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parkxpert/Interface/Auth/signup_service.dart';
import 'package:parkxpert/Views/Auth/custom_scaffold.dart';
import 'package:parkxpert/Views/Auth/login_screen.dart';
import 'package:parkxpert/Views/Auth/theme.dart';
import 'package:parkxpert/res/routes/route_name.dart';
import 'package:parkxpert/utils/utils.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final signupService = Get.put(SignupService());
  final _formSignupKey = GlobalKey<FormState>();
  final RoundedLoadingButtonController controller =
      RoundedLoadingButtonController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  void resetFields() {
    signupService.nameController.clear();
    signupService.emailController.clear();
    signupService.phoneNumberController.clear();
    signupService.passwordController.clear();
    signupService.confirmPasswordController.clear();
  }

  Future<bool> emailAlreadyExists(String email) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<bool> hasInternet() async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity != ConnectivityResult.none;
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', signupService.nameController.text.trim());
    await prefs.setString('email', signupService.emailController.text.trim());
    await prefs.setString(
        'phone', signupService.phoneNumberController.text.trim());
    await prefs.setString(
        'password', signupService.passwordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 10)),
          Expanded(
            flex: 9,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      TextFormField(
                        controller: signupService.nameController,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Please enter name'
                                : null,
                        decoration: InputDecoration(
                          label: const Text('Name'),
                          hintText: 'Enter your Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: signupService.emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            // ignore: curly_braces_in_flow_control_structures
                            return 'Please enter Email';
                          if (!GetUtils.isEmail(value))
                            // ignore: curly_braces_in_flow_control_structures
                            return 'Enter a valid email';
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Enter Email',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: signupService.phoneNumberController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            // ignore: curly_braces_in_flow_control_structures
                            return 'Please enter phone number';
                          if (!RegExp(r'^\d{11}$').hasMatch(value))
                            // ignore: curly_braces_in_flow_control_structures
                            return 'Enter a valid 11-digit phone number';
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Phone Number'),
                          hintText: 'Enter Phone Number',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: signupService.passwordController,
                        obscureText: !_showPassword,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            // ignore: curly_braces_in_flow_control_structures
                            return 'Please enter Password';
                          if (value.length < 8 ||
                              !RegExp(r'[A-Z]').hasMatch(value) ||
                              !RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Password must be:\n• At least 8 characters\n• Include uppercase letter\n• Include number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          hintText: 'Enter Password',
                          suffixIcon: IconButton(
                            icon: Icon(_showPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () =>
                                setState(() => _showPassword = !_showPassword),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: signupService.confirmPasswordController,
                        obscureText: !_showConfirmPassword,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            // ignore: curly_braces_in_flow_control_structures
                            return 'Please confirm your Password';
                          if (value != signupService.passwordController.text)
                            // ignore: curly_braces_in_flow_control_structures
                            return 'Passwords do not match';
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Confirm Password'),
                          hintText: 'Re-enter Password',
                          suffixIcon: IconButton(
                            icon: Icon(_showConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => setState(() =>
                                _showConfirmPassword = !_showConfirmPassword),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: Hero(
                          tag: "auth",
                          child: RoundedLoadingButton(
                            successColor: Colors.green,
                            errorColor: Colors.red,
                            controller: controller,
                            onPressed: () async {
                              if (!await hasInternet()) {
                                controller.error();
                                Utils.snackBar(
                                    "Error", "No internet Connection", true);
                                Timer(const Duration(seconds: 2),
                                    () => controller.reset());
                                return;
                              }

                              if (_formSignupKey.currentState!.validate()) {
                                controller.start();
                                final email =
                                    signupService.emailController.text.trim();

                                if (await emailAlreadyExists(email)) {
                                  controller.error();
                                  Utils.snackBar(
                                      "Error", "Email already exists", true);
                                  Timer(const Duration(seconds: 2),
                                      () => controller.reset());
                                  return;
                                }

                                try {
                                  final credential = await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                    email: email,
                                    password: signupService
                                        .passwordController.text
                                        .trim(),
                                  );

                                  final user = credential.user;

                                  if (user != null && !user.emailVerified) {
                                    await user.sendEmailVerification();

                                    await saveToPrefs(); // Save inputs locally

                                    Get.dialog(
                                      AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        backgroundColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.all(25),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.email_outlined,
                                                color: lightColorScheme.primary,
                                                size: 60),
                                            const SizedBox(height: 20),
                                            Text(
                                              'Verify Your Email',
                                              style: GoogleFonts.nobile(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: lightColorScheme.primary,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 15),
                                            Text(
                                              'A verification link has been sent to your email.\nPlease check your inbox and verify before logging in.',
                                              style: GoogleFonts.nobile(
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 25),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                Get.back();
                                                FirebaseAuth.instance.signOut();
                                                Get.offAll(
                                                    () => const LoginScreen());
                                              },
                                              icon: const Icon(
                                                Icons.check_circle_outline,
                                                color: Colors.white,
                                              ),
                                              label: const Text(
                                                'Got it!',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    lightColorScheme.primary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 30,
                                                        vertical: 12),
                                                textStyle: GoogleFonts.nobile(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );

                                    resetFields();
                                    controller.success();
                                  }
                                } on FirebaseAuthException catch (e) {
                                  controller.error();
                                  Utils.snackBar("Signup Error",
                                      e.message ?? "Unknown error", true);
                                  Timer(const Duration(seconds: 2),
                                      () => controller.reset());
                                }
                              } else {
                                controller.error();
                                Timer(const Duration(seconds: 2),
                                    () => controller.reset());
                              }
                            },
                            color: lightColorScheme.primary,
                            borderRadius: 10,
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.nobile(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? ',
                              style: TextStyle(color: Colors.black45)),
                          GestureDetector(
                            onTap: () => Get.toNamed(RouteName.login),
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
