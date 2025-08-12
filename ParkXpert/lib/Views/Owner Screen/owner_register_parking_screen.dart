import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:micro_loaders/widgets/dual_rotating_expanding_arc_loader.dart';
import 'package:parkxpert/Controller/Owner%20Controller/owner_controller.dart';
import 'package:parkxpert/res/routes/route_name.dart';
import 'package:parkxpert/utils/utils.dart';

class OwnerRegisterParkingScreen extends StatelessWidget {
  OwnerRegisterParkingScreen({super.key});

  final OwnerController controller = Get.find();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final ScrollController _suggestionScrollController = ScrollController();

  Future<void> _submit(BuildContext context) async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final imageFile = controller.selectedParkingImage.value;

    if (imageFile == null || name.isEmpty || address.isEmpty) {
      Utils.snackBar("Error", "Please fill all fields and pick an image", true);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: DualRotatingExpandingArcLoader(
          size: 70,
          outerColor: Color(0xFF0081C9),
          innerColor: Colors.white,
          strokeWidth: 5,
        ),
      ),
    );

    try {
      await controller.updateParkingPic(imageFile);
      await controller.updateParkingInfo(
        name,
        address,
        controller.selectedLat.value,
        controller.selectedLon.value,
      );
      await controller.formSubmit();
      Navigator.of(context).pop();
      Get.offNamed(RouteName.ownerRegistrationParkingStatus);
    } catch (e) {
      Navigator.of(context).pop();
      Utils.snackBar("Error", "Failed to load data", true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0081C9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Register Parking",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => controller.pickParkingImage(context),
              child: Obx(() {
                final imageFile = controller.selectedParkingImage.value;
                return Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Color(0xFF0081C9).withOpacity(0.5)),
                    image: imageFile != null
                        ? DecorationImage(
                            image: FileImage(imageFile),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageFile == null
                      ? const Center(
                          child: Icon(Icons.add_a_photo,
                              color: Color(0xFF0081C9), size: 40),
                        )
                      : null,
                );
              }),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              cursorColor: Color(0xFF0081C9),
              decoration: InputDecoration(
                labelText: "Parking Name",
                labelStyle: const TextStyle(color: Colors.black87),
                filled: true,
                fillColor: Colors.white,
                prefixIcon:
                    const Icon(Icons.local_parking, color: Color(0xFF0081C9)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0081C9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF0081C9), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _addressController,
              cursorColor: Color(0xFF0081C9),
              decoration: InputDecoration(
                labelText: "Parking Address",
                labelStyle: const TextStyle(color: Colors.black87),
                filled: true,
                fillColor: Colors.white,
                prefixIcon:
                    const Icon(Icons.location_on, color: Color(0xFF0081C9)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0081C9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF0081C9), width: 2),
                ),
              ),
              onChanged: (value) => controller.fetchAddressSuggestions(value),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final suggestions = controller.addressSuggestions;
              if (suggestions.isEmpty) return const SizedBox.shrink();

              return Scrollbar(
                controller: _suggestionScrollController,
                thumbVisibility: true,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Color(0xFF0081C9).withOpacity(0.3)),
                  ),
                  child: ListView.builder(
                    controller: _suggestionScrollController,
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = suggestions[index];
                      return ListTile(
                        title: Text(
                          suggestion,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () async {
                          _addressController.text = suggestion;
                          controller.addressSuggestions.clear();

                          final url = Uri.parse(
                            'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(suggestion)}&format=json&limit=1&countrycodes=pk',
                          );

                          final response = await http.get(url, headers: {
                            'User-Agent': 'parkxpert-app (huzaifa@example.com)',
                          });

                          if (response.statusCode == 200) {
                            final data = jsonDecode(response.body);
                            if (data.isNotEmpty) {
                              controller.selectedLat.value =
                                  double.parse(data[0]['lat']);
                              controller.selectedLon.value =
                                  double.parse(data[0]['lon']);
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _submit(context),
                label:
                    const Text("Submit", style: TextStyle(color: Colors.white)),
                icon: const Icon(Icons.send, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0081C9),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
