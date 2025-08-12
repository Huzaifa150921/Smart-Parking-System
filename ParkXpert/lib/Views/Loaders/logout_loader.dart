import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:micro_loaders/micro_loaders.dart';
import 'package:parkxpert/Controller/UserController/user_controller.dart';

class LogoutLoader extends StatelessWidget {
  LogoutLoader({super.key});
  final UserController userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    final isLoading = RxBool(true);

    Future.delayed(Duration(seconds: 3), () {
      isLoading.value = false;

      userController.logoutUser();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => isLoading.value
          ? Center(
              child: PulseRingLoader(
                size: 40,
                color: Colors.blueAccent,
              ),
            )
          : Container()),
    );
  }
}
