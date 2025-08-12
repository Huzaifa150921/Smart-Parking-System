import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:micro_loaders/widgets/growing_arc_loader.dart';

class DynamicLoader extends StatelessWidget {
  final String targetRoute;
  final int delayInSeconds;

  const DynamicLoader({
    super.key,
    required this.targetRoute,
    this.delayInSeconds = 2,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = true.obs;

    Future.delayed(Duration(seconds: delayInSeconds), () {
      isLoading.value = false;
      Get.offNamed(targetRoute);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => isLoading.value
          ? Center(
              child: GrowingArcLoader(
                size: 80,
                primaryColor: Colors.white,
                arcColor: Colors.blueAccent,
                duration: 1500,
              ),
            )
          : const SizedBox.shrink()),
    );
  }
}
