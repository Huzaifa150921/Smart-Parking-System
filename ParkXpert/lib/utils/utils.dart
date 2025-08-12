// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:parkxpert/res/Colors/app_color.dart';

class Utils {
  static toastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColor.blackcolor,
      gravity: ToastGravity.BOTTOM,
    );
  }

  static toastMessageCenter(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColor.blackcolor,
      gravity: ToastGravity.CENTER,
    );
  }

  static snackBar(String title, String message, bool isError) {
    Get.snackbar(
      title,
      message,
      colorText: Colors.white,
      backgroundColor: Colors.transparent,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      borderRadius: 15,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(16),
      boxShadows: [
        BoxShadow(
          color: isError
              ? Colors.red.withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
          blurRadius: 10,
          spreadRadius: 2,
          offset: const Offset(0, 5),
        ),
      ],
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: true,
      forwardAnimationCurve: Curves.easeOutBack,
      barBlur: 10,
      overlayBlur: 3,
      overlayColor: Colors.black.withOpacity(0.3),
      mainButton: TextButton(
        onPressed: () => Get.back(),
        child: const Text(
          "Dismiss",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundGradient: LinearGradient(
        colors: isError
            ? [Colors.red, Colors.redAccent]
            : [Colors.green, Colors.greenAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}
