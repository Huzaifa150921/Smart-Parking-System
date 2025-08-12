import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:parkxpert/Controller/LocationController/location_controller.dart';
import 'package:parkxpert/Controller/UserController/user_controller.dart';
import 'package:parkxpert/Views/user_screen/location_input_screen.dart';
import 'package:parkxpert/res/routes/route_name.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  String _locationName = "Loading location...";
  late LocationController locationController;
  final UserController userController = Get.find<UserController>();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    locationController = Get.find();
    locationController.loadSavedLocation();

    // If no saved location, get device location
    if (locationController.currentLocation.value == null) {
      _getLocation();
    } else {
      final saved = locationController.currentLocation.value!;
      _currentLocation = saved;
      _locationName = "Loading location...";
      _updateLocationName(saved); // Update name for saved location
      _loading = false;
    }

    // Listen to changes
    locationController.currentLocation.listen((location) {
      if (location != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 200), () {
            _mapController.move(location, 13);
          });
        });
        _updateLocationName(location);
      }
    });
  }

  Future<void> _updateLocationName(LatLng location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final line1 = "${p.name}, ${p.locality}";
        final line2 = "${p.administrativeArea}, ${p.country}";

        setState(() {
          _locationName = "$line1\n$line2";
        });
      } else {
        setState(() {
          _locationName = "Selected location";
        });
      }
    } catch (e) {
      setState(() {
        _locationName = "Error retrieving location name";
      });
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    _currentLocation = LatLng(position.latitude, position.longitude);
    locationController
        .setLocation(_currentLocation!); // Controller updated here

    try {
      final placemarks = await placemarkFromCoordinates(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final line1 = "${p.name}, ${p.locality}";
        final line2 = "${p.administrativeArea}, ${p.country}";

        setState(() {
          _locationName = "$line1\n$line2";
          _loading = false;
        });
      } else {
        setState(() {
          _locationName = "Location not found";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _locationName = "Error retrieving location name";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    if (_loading || _currentLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation!,
              initialZoom: 13,
              onMapReady: () {
                _mapController.move(_currentLocation!, 13);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.parkxpert',
              ),
              Obx(() {
                final selectedLocation =
                    locationController.currentLocation.value;
                return MarkerLayer(
                  markers: selectedLocation == null
                      ? []
                      : [
                          Marker(
                            point: selectedLocation,
                            width: 60,
                            height: 60,
                            child: Image.asset(
                              'assets/images/marker.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                );
              }),
            ],
          ),
          Positioned(
            top: screenHeight * 0.65,
            left: screenWidth * 0.015,
            right: screenWidth * 0.015,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: Card(
                color: Colors.black,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _locationName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      SizedBox(
                        width: screenWidth - 30,
                        child: InkWell(
                          onTap: () {
                            Get.to(() => LocationInputScreen(),
                                transition: Transition.fade);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.018),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child:
                                      Icon(Icons.search, color: Colors.white),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Enter Location',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      SizedBox(
                        width: screenWidth * 0.4,
                        child: ElevatedButton(
                          onPressed: () async {
                            final selectedLocation =
                                locationController.currentLocation.value;

                            final LatLng locationToUse =
                                selectedLocation ?? _currentLocation!;

                            Get.toNamed(
                              RouteName.displayParking,
                              arguments: {
                                'latitude': locationToUse.latitude,
                                'longitude': locationToUse.longitude,
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF90DD47),
                            foregroundColor: const Color(0xFF08CC0E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Find a Parking',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
