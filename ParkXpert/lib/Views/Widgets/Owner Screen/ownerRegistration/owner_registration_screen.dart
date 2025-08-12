import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:micro_loaders/widgets/dots_loading_circle.dart';
import 'package:parkxpert/Controller/Owner%20Controller/owner_registration_track_controller.dart';
import 'package:parkxpert/Views/Widgets/Owner%20Screen/ownerRegistration/basic_info.dart';
import 'package:parkxpert/Views/Widgets/Owner%20Screen/ownerRegistration/parking_info.dart';
import 'package:parkxpert/res/routes/route_name.dart';

class OwnerRegistrationScreen extends StatelessWidget {
  const OwnerRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OwnerRegistrationTrackController>();

    return Obx(() {
      final data = controller.currentOwner.value;

      if (data == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final isBasicInfoDone = data.basicInfoDone ?? false;
      final isParkingInfoDone = data.parkingInfoDone ?? false;

      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          title: const Text("Registration"),
          centerTitle: true,
          elevation: 1,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSectionCard(
                context,
                title: "Basic Info",
                completed: isBasicInfoDone,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BasicInfo()),
                  );
                  if (result != null) {
                    await controller.refreshOwnerData();
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                context,
                title: "Parking Info",
                completed: isParkingInfoDone,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ParkingInfo()),
                  );
                  if (result != null) {
                    await controller.refreshOwnerData();
                  }
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (isBasicInfoDone && isParkingInfoDone)
                      ? () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: DotsLoaderView(
                                dotSize: 10,
                                dotCount: 5,
                                duration: Duration(seconds: 1),
                                dotColor: Colors.blue,
                              ),
                            ),
                          );

                          await controller.submitForm();

                          if (context.mounted) {
                            Navigator.of(context).pop(); // close loader
                            Get.offNamed(RouteName.ownerRegistrationStatus);
                          }
                        }
                      : null,
                  icon: const Icon(Icons.send),
                  label: const Text("Submit for Approval"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required bool completed,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Icon(
              completed ? Icons.check_circle : Icons.cancel,
              color: completed ? Colors.green : Colors.redAccent,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              completed ? "Completed" : "Not Provided",
              style: TextStyle(
                color: completed ? Colors.green : Colors.redAccent,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.edit, color: Colors.blueGrey),
        onTap: onTap,
      ),
    );
  }
}
