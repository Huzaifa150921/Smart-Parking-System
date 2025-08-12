import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parkxpert/utils/utils.dart';
import 'package:get/get.dart';
import 'package:parkxpert/res/routes/route_name.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool isLoading = false;
  bool showOldPassword = false;
  bool showNewPassword = false;

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty) {
      Utils.snackBar("Error", "Please enter both fields", true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final cred = EmailAuthProvider.credential(
        email: user!.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      Utils.snackBar("Success", "Password updated successfully!", false);

      await Future.delayed(const Duration(seconds: 2));
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(RouteName.login);
    } on FirebaseAuthException catch (e) {
      Utils.snackBar("Error", "Incorrect password", true);
      // ignore: avoid_print
      print(e.message);
    } catch (e) {
      Utils.snackBar("Error", "Unexpected error", true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        centerTitle: true,
        foregroundColor: Colors.white,
        title: const Text("Change Password",
            style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: !showOldPassword,
              decoration: InputDecoration(
                labelText: "Old Password",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(showOldPassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      showOldPassword = !showOldPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: newPasswordController,
              obscureText: !showNewPassword,
              decoration: InputDecoration(
                labelText: "New Password",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(showNewPassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      showNewPassword = !showNewPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Update Password",
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
