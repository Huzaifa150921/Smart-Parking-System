import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parkxpert/Controller/Owner%20Controller/owner_controller.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  final OwnerController controller = Get.find<OwnerController>();
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await controller.loadOwnerProfile();
      setState(() {});
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await controller.pickProfileImage(context);
    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile;
      });
    }
  }

  Future<void> _saveProfile() async {
    await controller.saveOwnerProfile();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final base64String = controller.profileImageBase64.value;
    ImageProvider? imageProvider;

    if (_profileImage != null) {
      imageProvider = FileImage(_profileImage!);
    } else if (base64String.isNotEmpty) {
      imageProvider = MemoryImage(base64Decode(base64String));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0081C9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: imageProvider,
                    child: imageProvider == null
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0081C9),
                        ),
                        child: const Icon(Icons.edit,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            TextField(
              controller: controller.nameController.value,
              style: const TextStyle(color: Colors.black),
              cursorColor: Color(0xFF0081C9),
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: const TextStyle(color: Color(0xFF0081C9)),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: const Icon(Icons.person, color: Color(0xFF0081C9)),
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
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  "Save Profile",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0081C9),
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
  }
}
