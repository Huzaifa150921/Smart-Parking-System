import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:micro_loaders/widgets/growing_arc_loader.dart';
import 'package:parkxpert/res/routes/route_name.dart';

class OwnerRegistrationLoader extends StatelessWidget {
  const OwnerRegistrationLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = RxBool(true);

    Future.delayed(Duration(seconds: 3), () {
      isLoading.value = false;

      Get.offNamed(RouteName.ownerRegistrationTrack);
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
          : Container()),
    );
  }
}
