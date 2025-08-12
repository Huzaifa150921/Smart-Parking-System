import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parkxpert/res/routes/route_name.dart';
import 'package:parkxpert/utils/utils.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String currentEmail;
  const EmailVerificationScreen({super.key, required this.currentEmail});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  Timer? _checkTimer;
  String? newEmail;

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  Future<bool> reauthenticateUser() async {
    String password = '';
    final user = FirebaseAuth.instance.currentUser;

    await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController passController = TextEditingController();
        return AlertDialog(
          title: const Text("Reauthenticate"),
          content: TextField(
            controller: passController,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Enter your password"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                password = passController.text.trim();
                Navigator.of(context).pop();
              },
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );

    if (password.isEmpty) return false;

    try {
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      Utils.snackBar("Error", "Invalid credentials", true);
      return false;
    }
  }

  Future<void> sendVerificationEmail() async {
    setState(() => isLoading = true);
    final enteredEmail = emailController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (enteredEmail == widget.currentEmail) {
      Utils.snackBar("Error", "New email cannot be same as current", true);
      setState(() => isLoading = false);
      return;
    }

    // Accurate check: try creating dummy account with entered email
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: enteredEmail,
        password: 'Temporary@123',
      );
      // If no error, email is not in use (rare)
      final tempUser = FirebaseAuth.instance.currentUser;
      await tempUser?.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Utils.snackBar(
            "Error", "Email is already in use. Try another one.", true);
        setState(() => isLoading = false);
        return;
      } else if (e.code == 'invalid-email') {
        Utils.snackBar("Error", "Invalid email address format", true);
        setState(() => isLoading = false);
        return;
      }
    }

    final success = await reauthenticateUser();
    if (!success) {
      setState(() => isLoading = false);
      return;
    }

    try {
      await user!.verifyBeforeUpdateEmail(enteredEmail);
      newEmail = enteredEmail;

      Utils.snackBar(
          "Verify", "Check $enteredEmail for confirmation link", false);

      _checkTimer = Timer.periodic(
        const Duration(seconds: 4),
        (_) => checkIfEmailVerified(),
      );
    } on FirebaseAuthException catch (e) {
      Utils.snackBar("Error", e.message ?? "Unknown error", true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> checkIfEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      await user?.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser?.email == newEmail) {
        _checkTimer?.cancel();

        Utils.snackBar("Success", "Email updated! Please log in again.", false);
        await Future.delayed(const Duration(seconds: 2));
        await FirebaseAuth.instance.signOut();
        Get.offAllNamed(RouteName.login);
      } else {
        print("Email not yet verified. Current: ${refreshedUser?.email}");
      }
    } on FirebaseAuthException catch (e) {
      _checkTimer?.cancel();
      if (e.code == 'user-token-expired' || e.code == 'requires-recent-login') {
        Utils.snackBar("Session expired", "Please log in again", false);
      } else {
        Utils.snackBar("Error", e.message ?? "Unexpected error", true);
      }
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(RouteName.login);
    } catch (e) {
      _checkTimer?.cancel();
      Utils.snackBar("Error", "Unexpected error", true);
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(RouteName.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3E7F1),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title:
            const Text("Update Email", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Enter New Email",
                prefixIcon: const Icon(Icons.email),
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : sendVerificationEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Send Verification Email",
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
