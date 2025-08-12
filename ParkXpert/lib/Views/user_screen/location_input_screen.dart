import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:parkxpert/Controller/LocationController/location_controller.dart';
import 'package:http/http.dart' as http;

class LocationInputScreen extends StatefulWidget {
  const LocationInputScreen({super.key});

  @override
  State<LocationInputScreen> createState() => _LocationInputScreenState();
}

class _LocationInputScreenState extends State<LocationInputScreen> {
  final TextEditingController _locationTextController = TextEditingController();
  final LocationController locationController = Get.find<LocationController>();
  List<Map<String, dynamic>> suggestions = [];
  Timer? _debounce;

  void _onTextChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      fetchSuggestions(value);
    });
  }

  Future<void> fetchSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() => suggestions = []);
      return;
    }

    final url =
        'https://nominatim.openstreetmap.org/search?q=$input&format=json&addressdetails=1&limit=5&countrycodes=pk';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'FlutterApp (your@email.com)'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          suggestions = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("Suggestion error: $e");
    }
  }

  void _onSuggestionTap(Map<String, dynamic> suggestion) {
    final displayName = suggestion['display_name'];
    final lat = double.tryParse(suggestion['lat'] ?? '');
    final lon = double.tryParse(suggestion['lon'] ?? '');

    if (lat != null && lon != null) {
      locationController.setLocation(LatLng(lat, lon));
      _locationTextController.text = displayName;
      Get.back();
    }
  }

  @override
  void dispose() {
    _locationTextController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Select Location",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade600,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                controller: _locationTextController,
                onChanged: _onTextChanged,
                decoration: InputDecoration(
                  hintText: "Search a Location...",
                  prefixIcon: const Icon(Icons.search),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: suggestions.isEmpty
                  ? Center()
                  : ListView.builder(
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = suggestions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              suggestion['display_name'],
                              style: const TextStyle(fontSize: 15),
                            ),
                            leading: const Icon(Icons.location_on,
                                color: Colors.blueAccent),
                            onTap: () => _onSuggestionTap(suggestion),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
