import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:double_tap_exit/double_tap_exit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:parkxpert/Controller/LocationController/location_controller.dart';
import 'package:parkxpert/Controller/UserController/user_controller.dart';
import 'package:parkxpert/res/routes/route_name.dart';
import 'package:parkxpert/utils/utils.dart';

class ParkingRoute extends StatefulWidget {
  const ParkingRoute({super.key});

  @override
  State<ParkingRoute> createState() => _ParkingRouteState();
}

class _ParkingRouteState extends State<ParkingRoute> {
  UserController controller = Get.find<UserController>();
  String ownerName = '';
  bool loadingOwner = true;
  Duration remainingTime = const Duration(minutes: 15);
  Timer? countdownTimer;
  StreamSubscription<DocumentSnapshot>? bookingStream;
  bool showCancelButton = false;
  double? bookingPrice;

  String? bookingId;
  LatLng? parkingCoords;
  List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null && args['uid'] != null) {
      bookingId = args['bookingId'];
      fetchOwnerName(args['uid']);
      fetchBookingPrice(args['bookingId']);
      listenToStartTime(args['bookingId']);
      fetchParkingCoords(args);
    }
  }

  Future<void> fetchBookingPrice(String? bookingId) async {
    if (bookingId == null) return;

    try {
      final bookingDoc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .get();

      if (bookingDoc.exists) {
        final data = bookingDoc.data();
        final priceStr = data?['price']?.toString() ?? '0';
        final price = double.tryParse(priceStr) ?? 0;

        setState(() {
          bookingPrice = price;
        });
      }
    } catch (e) {
      print('Error fetching booking price: $e');
    }
  }

  Future<void> fetchParkingCoords(Map<String, dynamic> parking) async {
    final lat = parking['latitude'];
    final lng = parking['longitude'];
    if (lat != null && lng != null) {
      final LatLng parkingLatLng = LatLng(lat, lng);
      setState(() => parkingCoords = parkingLatLng);

      final userCoords = Get.find<LocationController>().currentLocation.value;
      if (userCoords != null) {
        final route = await getRoutePoints(userCoords, parkingLatLng);
        setState(() => routePoints = route);
      }
    }
  }

  Future<List<LatLng>> getRoutePoints(LatLng start, LatLng end) async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final coords =
          decoded['routes'][0]['geometry']['coordinates'] as List<dynamic>;

      return coords
          .map((point) => LatLng(point[1] as double, point[0] as double))
          .toList();
    } else {
      print('Failed to get route: ${response.body}');
      return [];
    }
  }

  void listenToStartTime(String? bookingId) {
    if (bookingId == null) return;

    bookingStream = FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;

      final data = doc.data();
      final startTimestamp = data?['startTime'];
      final createdTimestamp = data?['createdAt'];

      if (startTimestamp != null) {
        setState(() {
          remainingTime = Duration.zero;
          showCancelButton = false;
        });
        countdownTimer?.cancel();
      } else if (createdTimestamp != null) {
        final createdAt = (createdTimestamp as Timestamp).toDate();
        final now = DateTime.now();
        final expiry = createdAt.add(const Duration(minutes: 15));
        final diff = expiry.difference(now);

        if (!mounted) return;

        if (diff.isNegative) {
          setState(() {
            remainingTime = Duration.zero;
            showCancelButton = false;
          });
        } else {
          setState(() {
            remainingTime = diff;
            showCancelButton = true;
          });
          startCountdown();
        }
      }
    });
  }

  void startCountdown() {
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (remainingTime.inSeconds > 0) {
        setState(() {
          remainingTime = remainingTime - const Duration(seconds: 1);
        });
      } else {
        setState(() => showCancelButton = false);
        timer.cancel();
      }
    });
  }

  Future<void> cancelBooking() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Row(
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Cancelling booking..."),
              ],
            ),
          );
        },
      );

      final bookingRef =
          FirebaseFirestore.instance.collection('bookings').doc(bookingId);
      final bookingDoc = await bookingRef.get();

      if (!bookingDoc.exists) {
        Navigator.of(context).pop();
        Get.snackbar("Error", "Booking not found");
        return;
      }

      final bookingData = bookingDoc.data()!;
      final parkingId = bookingData['parkingId'];
      final userId = bookingData['userId'];
      final ownerId = bookingData['ownerId'];
      final slotId = bookingData['slotid'];
      final priceStr = bookingData['price']?.toString() ?? '0';
      final priceDouble = double.tryParse(priceStr) ?? 0;

      final parkingRef =
          FirebaseFirestore.instance.collection('parkings').doc(parkingId);
      final parkingDoc = await parkingRef.get();

      if (!parkingDoc.exists) {
        Navigator.of(context).pop();
        Get.snackbar("Error", "Parking not found");
        return;
      }

      final rawEarning = parkingDoc.data()?['parkingEarning'] ?? 0;
      final currentEarning =
          rawEarning is int ? rawEarning.toDouble() : rawEarning;

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(bookingRef, {
          'status': 'canceled',
          'paymentStatus': 'refunded',
        });

        transaction.update(parkingRef, {
          'parkingEarning': currentEarning - priceDouble,
        });
      });

      final monitoringQuery = await FirebaseFirestore.instance
          .collection('slot_monitoring_model_results')
          .where('puid', isEqualTo: parkingId)
          .limit(1)
          .get();

      if (monitoringQuery.docs.isNotEmpty) {
        final doc = monitoringQuery.docs.first;
        final List<dynamic> slots = doc['slots'] ?? [];
        int freeSlots = (doc['free'] ?? 0) as int;

        final updatedSlots = slots.map((slot) {
          if (slot['slot_id'].toString() == slotId.toString()) {
            return {
              ...slot,
              'status': 'free',
            };
          }
          return slot;
        }).toList();

        await doc.reference.update({
          'slots': updatedSlots,
          'free': freeSlots + 1,
        });

        if (userId != null && ownerId != null) {
          await controller.sendInAppNotification(
            uid: userId,
            title: 'Booking Cancelled',
            body: 'Your booking has been cancelled and amount is refunded.',
            type: 'user_cancel',
            data: {
              'bookingId': bookingId,
              'parkingId': parkingId,
            },
          );

          await controller.sendInAppNotification(
            uid: ownerId,
            title: 'Booking Cancelled by User',
            body: 'A user has cancelled their booking at your parking.',
            type: 'owner_cancel',
            data: {
              'bookingId': bookingId,
              'userId': userId,
            },
          );
        } else {
          Utils.snackBar("Error", "User or Owner ID missing", true);
        }
      }

      Navigator.of(context).pop();
      Get.offAllNamed(RouteName.userScreenfadein);
    } catch (e) {
      Navigator.of(context).pop();
      Utils.snackBar("Error", "Failed to cancel booking", true);
    }
  }

  Future<void> fetchOwnerName(String ownerUid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('owners')
          .doc(ownerUid)
          .get();
      if (!mounted) return;
      if (doc.exists) {
        setState(() {
          ownerName = doc.data()?['firstName'] ?? 'Unknown';
          loadingOwner = false;
        });
      } else {
        setState(() {
          ownerName = 'Unknown Owner';
          loadingOwner = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        ownerName = 'Error loading';
        loadingOwner = false;
      });
    }
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    bookingStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();
    return Obx(() {
      final LatLng? coords = locationController.currentLocation.value;
      final Map<String, dynamic>? parking = Get.arguments;

      if (coords == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return DoubleTap(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(5),
            child: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              automaticallyImplyLeading: false,
            ),
          ),
          body: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: coords,
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.parkxpert',
                  ),
                  if (routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          strokeWidth: 4,
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: coords,
                        width: 50,
                        height: 50,
                        child: Image.asset('assets/images/marker.png'),
                      ),
                      if (parkingCoords != null)
                        Marker(
                          point: parkingCoords!,
                          width: 30,
                          height: 30,
                          child: Image.asset('assets/images/parking.png'),
                        ),
                    ],
                  ),
                ],
              ),
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Card(
                  elevation: 10,
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '🚗 Parking Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (parking != null) ...[
                          detailRow('🅿️Parking Name',
                              parking['parkingName'] ?? 'N/A'),
                          detailRow('📍Parking Address',
                              parking['parkingAddress'] ?? 'N/A'),
                          detailRowWithIcon('💰 Total Price', bookingPrice),
                          detailRow('👤 Owner Name',
                              loadingOwner ? 'Loading...' : ownerName),
                        ],
                        const SizedBox(height: 16),
                        if (showCancelButton)
                          Column(
                            children: [
                              Text(
                                "⏳ Time to Cancel: ${remainingTime.inMinutes.toString().padLeft(2, '0')}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                    color: Colors.orangeAccent, fontSize: 14),
                              ),
                              const SizedBox(height: 14),
                            ],
                          ),
                        Row(
                          children: [
                            if (showCancelButton)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: cancelBooking,
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('Cancel Parking'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[600],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                ),
                              ),
                            if (showCancelButton) const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Get.offAllNamed(RouteName.userScreenfadein);
                                },
                                icon: const Icon(Icons.home),
                                label: const Text('Main Page'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent[400],
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget detailRowWithIcon(String title, double? price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: price != null
                ? Row(
                    children: [
                      const Icon(Icons.currency_rupee,
                          color: Colors.white, size: 16),
                      Text(
                        price.toStringAsFixed(0),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  )
                : const Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
