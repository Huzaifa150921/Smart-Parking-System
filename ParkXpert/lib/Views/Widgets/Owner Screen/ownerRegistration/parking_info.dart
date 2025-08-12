import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:micro_loaders/widgets/four_dots_loader.dart';
import 'package:parkxpert/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:parkxpert/Controller/Owner%20Controller/owner_registration_track_controller.dart';

class ParkingInfo extends StatefulWidget {
  const ParkingInfo({super.key});

  @override
  State<ParkingInfo> createState() => _ParkingInfoFormState();
}

class _ParkingInfoFormState extends State<ParkingInfo> {
  final _formKey = GlobalKey<FormState>();
  File? parkingImage;
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> addressSuggestions = [];
  double? selectedLatitude;
  double? selectedLongitude;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final granted = await _requestPermission(source);
    if (!granted) return;

    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() {
        parkingImage = File(picked.path);
      });
    }
  }

  Future<bool> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      return await Permission.camera.request().isGranted;
    } else {
      final storage = await Permission.storage.request();
      final photos = await Permission.photos.request();
      return storage.isGranted || photos.isGranted;
    }
  }

  Future<void> fetchAddressSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => addressSuggestions = []);
      return;
    }

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&countrycodes=pk',
    );

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'parkxpert-app',
      });

      if (response.statusCode == 200) {
        final List results = json.decode(response.body);
        setState(() {
          addressSuggestions = results.map<Map<String, dynamic>>((item) {
            return {
              'display_name': item['display_name'],
              'lat': double.tryParse(item['lat']),
              'lon': double.tryParse(item['lon']),
            };
          }).toList();
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("Address fetch error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        title: const Text("Parking Info"),
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
                  height: 170,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      )
                    ],
                    image: parkingImage != null
                        ? DecorationImage(
                            image: FileImage(parkingImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: parkingImage == null
                      ? const Center(
                          child: Icon(Icons.add_a_photo,
                              size: 40, color: Colors.blueGrey),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              _buildInputField(
                controller: _nameController,
                label: "Parking Name",
                icon: Icons.local_parking,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _addressController,
                label: "Parking Address",
                icon: Icons.location_on,
                onChanged: fetchAddressSuggestions,
              ),
              const SizedBox(height: 8),
              if (addressSuggestions.isNotEmpty)
                Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueGrey.shade100),
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: addressSuggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = addressSuggestions[index];
                        return ListTile(
                          title: Text(suggestion['display_name']),
                          onTap: () {
                            setState(() {
                              _addressController.text =
                                  suggestion['display_name'];
                              selectedLatitude = suggestion['lat'];
                              selectedLongitude = suggestion['lon'];
                              addressSuggestions.clear();
                            });
                          },
                        );
                      },
                    ),
                  ),
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
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
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
    if (_formKey.currentState!.validate() && parkingImage != null) {
      if (selectedLatitude == null || selectedLongitude == null) {
        Utils.snackBar(
            "Error", "Please select an address from suggestions", true);
        return;
      }

      final controller = Get.find<OwnerRegistrationTrackController>();

      // 🔵 Show loader before awaiting the upload
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: FourRotatingDots(
            size: 50,
            colors: [Colors.blue, Colors.cyan, Colors.indigo, Colors.teal],
            dotCount: 4,
          ),
        ),
      );

      // 🔵 Wait for upload
      await controller.uploadParkingInfoWithBase64(
        imageFile: parkingImage!,
        parkingName: _nameController.text,
        parkingAddress: _addressController.text,
        latitude: selectedLatitude,
        longitude: selectedLongitude,
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      Navigator.of(context).pop({
        "parkingName": _nameController.text,
        "parkingAddress": _addressController.text,
        "imagePath": parkingImage!.path,
      });
    } else {
      Utils.snackBar("Error", "Please complete all fields and image", true);
    }
  }
}
