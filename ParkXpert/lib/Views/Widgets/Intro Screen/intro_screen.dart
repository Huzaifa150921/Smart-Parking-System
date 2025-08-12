import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie_screen_onboarding_flutter/introduction.dart';
import 'package:lottie_screen_onboarding_flutter/introscreenonboarding.dart';
import 'package:parkxpert/res/routes/route_name.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final List<Introduction> list = [
    Introduction(
      lottieUrl: 'assets/animations/welcome.json',
      lottieHeight: 300,
      lottieWidth: 300,
      title: 'Start Smart Parking',
      titleTextStyle: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D2D2D),
      ),
      subTitle:
          'Welcome to ParkXpert! The smarter way to discover, book, and manage parking spots in Pakistan',
      subTitleTextStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
        height: 1.4,
      ),
    ),
    Introduction(
      lottieUrl: 'assets/animations/earth.json',
      lottieHeight: 300,
      lottieWidth: 300,
      title: 'Discover Nearby Spots',
      titleTextStyle: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D2D2D),
      ),
      subTitle:
          'Find parking with real-time availability and reserve your slot before you arrive',
      subTitleTextStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
        height: 1.4,
      ),
    ),
    Introduction(
      lottieUrl: 'assets/animations/fastpay.json',
      lottieHeight: 300,
      lottieWidth: 300,
      title: 'Pay Securely in Seconds',
      titleTextStyle: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D2D2D),
      ),
      subTitle:
          'Enjoy quick and secure payments using your favorite payment method, all inside the app',
      subTitleTextStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
        height: 1.4,
      ),
    ),
    Introduction(
      lottieUrl: 'assets/animations/earning.json',
      lottieHeight: 300,
      lottieWidth: 300,
      title: 'Earn with Your Space',
      titleTextStyle: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D2D2D),
      ),
      subTitle:
          'Own a space? Register it and start earning by offering verified parking services',
      subTitleTextStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
        height: 1.4,
      ),
    ),
  ];

  Future<void> setIsFirstTimeFalse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: const Color(0xFFD5D5D5),
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFD5D5D5),
        body: SafeArea(
          child: IntroScreenOnboarding(
            introductionList: list,
            onTapSkipButton: () async {
              await setIsFirstTimeFalse();
              Get.offNamed(RouteName.welcomeScreen);
            },
            backgroudColor: const Color(0xFFD5D5D5),
            foregroundColor: Colors.blueAccent, // Purple accent
            skipTextStyle: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
