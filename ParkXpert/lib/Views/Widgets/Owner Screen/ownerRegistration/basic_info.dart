import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:micro_loaders/widgets/four_dots_loader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:parkxpert/Controller/Owner%20Controller/owner_registration_track_controller.dart';
import 'package:parkxpert/utils/utils.dart';

class BasicInfo extends StatefulWidget {
  const BasicInfo({super.key});

  @override
  State<BasicInfo> createState() => _BasicInfoFormState();
}

class _BasicInfoFormState extends State<BasicInfo> {
  final _formKey = GlobalKey<FormState>();
  File? profileImage;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  Future<void> pickImage() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Image Source"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () async {
                Navigator.of(context).pop();
                await _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                Navigator.of(context).pop();
                await _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final granted = await _requestPermission(source);
    if (!granted) return;

    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() {
        profileImage = File(picked.path);
      });
    }
  }

  Future<bool> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      return await Permission.camera.request().isGranted;
    } else {
      final photo = await Permission.photos.request();
      final storage = await Permission.storage.request();
      return photo.isGranted || storage.isGranted;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        title: const Text("Basic Info"),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.shade300, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        profileImage != null ? FileImage(profileImage!) : null,
                    child: profileImage == null
                        ? const Icon(Icons.add_a_photo,
                            size: 30, color: Colors.blueGrey)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildInputField(
                controller: _firstNameController,
                label: "First Name",
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _lastNameController,
                label: "Last Name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleSubmit,
                  icon: const Icon(Icons.check_circle),
                  label: const Text("Done"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade800),
        filled: true,
        fillColor: Colors.grey[200],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate() && profileImage != null) {
      final controller = Get.find<OwnerRegistrationTrackController>();

      // Show loader dialog before starting async operation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
            child: const FourRotatingDots(
          size: 50,
          colors: [Colors.blue, Colors.cyan, Colors.indigo, Colors.teal],
          dotCount: 4,
        )),
      );

      await controller.uploadBasicInfoWithBase64(
        profileImage: profileImage!,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      Navigator.pop(context, {
        "firstName": _firstNameController.text,
        "lastName": _lastNameController.text,
        "imagePath": profileImage!.path,
      });
    } else {
      Utils.snackBar("Error", "Please complete all fields and image", true);
    }
  }
}
