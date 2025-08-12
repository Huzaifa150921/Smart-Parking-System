import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parkxpert/utils/utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool isLoading = false;
  bool isCooldown = false;
  bool isCooldownLoading = true;
  int cooldownSeconds = 60;
  Timer? _cooldownTimer;

  static const String _lastResetTimeKey = 'last_password_reset_time';

  @override
  void initState() {
    super.initState();
    _checkCooldownState();
  }

  Future<void> _checkCooldownState() async {
    setState(() {
      isCooldownLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final lastTimeStr = prefs.getString(_lastResetTimeKey);

    if (lastTimeStr != null) {
      final lastTime = DateTime.tryParse(lastTimeStr);
      if (lastTime != null) {
        final diff = DateTime.now().difference(lastTime).inSeconds;
        if (diff < 60) {
          cooldownSeconds = 60 - diff;
          isCooldown = true;
          _startCooldownTimer();
        }
      }
    }

    setState(() {
      isCooldownLoading = false;
    });
  }

  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );

        Utils.snackBar("Success", "Password reset email has been sent", false);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            _lastResetTimeKey, DateTime.now().toIso8601String());

        setState(() {
          cooldownSeconds = 60;
          isCooldown = true;
        });

        _startCooldownTimer();
      } on FirebaseAuthException catch (e) {
        Utils.snackBar("Error", e.message ?? 'Something went wrong', true);
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cooldownSeconds <= 1) {
        timer.cancel();
        setState(() {
          isCooldown = false;
        });
      } else {
        setState(() {
          cooldownSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      elevation: 4,
      backgroundColor: Colors.indigo,
      centerTitle: true,
      title: Text(
        'Forgot Password',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );

    final heightWithoutAppBar = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        appBar.preferredSize.height;

    return Scaffold(
      backgroundColor: const Color(0xFFE3E7F1),
      appBar: appBar,
      body: SizedBox(
        height: heightWithoutAppBar,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: -100, end: 0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, value),
              child: child,
            );
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 10,
                shadowColor: Colors.indigo.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Reset Your Password',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enter your registered email address and we’ll send you a reset link.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.email_outlined),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Colors.indigo),
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        isLoading
                            ? const CircularProgressIndicator()
                            : isCooldownLoading
                                ? const SizedBox(
                                    height: 50) // Placeholder space
                                : SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: Hero(
                                      tag: "auth",
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 3,
                                          backgroundColor: isCooldown
                                              ? Colors.grey
                                              : Colors.indigo,
                                        ),
                                        onPressed:
                                            isCooldown ? null : _sendResetEmail,
                                        child: Text(
                                          isCooldown
                                              ? 'Wait ${cooldownSeconds}s'
                                              : 'Send Reset Link',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
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
        ),
      ),
    );
  }
}
