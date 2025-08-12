import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parkxpert/Views/Auth/custom_scaffold.dart';
import 'package:parkxpert/Views/Auth/login_screen.dart';
import 'package:parkxpert/Views/Auth/signup_screen.dart';
import 'package:parkxpert/Views/Auth/theme.dart';
import 'package:parkxpert/Views/Auth/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: SafeArea(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // pushes top and bottom apart
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 60),
              child: Column(
                children: [
                  Text(
                    'Get Started with',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Colors.cyanAccent],
                    ).createShader(bounds),
                    child: Text(
                      'ParkXpert!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nobile(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1.5, 1.5),
                            blurRadius: 4,
                            color: Colors.black26,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Create an account or sign in to reserve, manage, and track your parking with ease.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Buttons Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                children: [
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign In',
                      onTap: LoginScreen(),
                      color: Colors.transparent,
                      textColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign Up',
                      onTap: const SignupScreen(),
                      color: Colors.white,
                      textColor: lightColorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
