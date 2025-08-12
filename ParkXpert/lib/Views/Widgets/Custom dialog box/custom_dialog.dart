import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAwesomeDialog {
  static void show({
    required BuildContext context,
    required TextEditingController controller,
    required Function(String) onChanged,
    required RxBool isButtonDisabled,
    required VoidCallback onConfirm,
    required TextInputType type,
    required IconData icon,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      dismissOnTouchOutside: true,
      dialogBackgroundColor: const Color(0xFFF3F7FB), // Soft bluish white
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: TextField(
          keyboardType: type,
          controller: controller,
          style: const TextStyle(color: Colors.black),
          cursorColor: Color(0xFF007BFF), // Bootstrap blue
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE6EFF9), // Very light blue
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            prefixIcon: Icon(icon, color: Color(0xFF007BFF)),
            hintText: "Enter value",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          onChanged: onChanged,
        ),
      ),
      btnCancel: TextButton(
        style: TextButton.styleFrom(
          backgroundColor:
              // ignore: deprecated_member_use
              const Color.fromARGB(255, 241, 31, 31).withOpacity(0.85),
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {
          Get.back();
        },
        child: const Text("Cancel", style: TextStyle(color: Colors.white)),
      ),
      btnOk: Obx(() => TextButton(
            style: TextButton.styleFrom(
              backgroundColor: isButtonDisabled.value
                  ? Colors.blue.shade100
                  : const Color(0xFF007BFF),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: isButtonDisabled.value ? null : onConfirm,
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          )),
    ).show();
  }
}
