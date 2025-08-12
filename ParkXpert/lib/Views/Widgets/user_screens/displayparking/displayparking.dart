import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:parkxpert/Views/Widgets/user_screens/displayparking/parking_detail_screen.dart';

class DisplayParking extends StatefulWidget {
  DisplayParking({super.key});

  final double? latitude = Get.arguments?['latitude'];
  final double? longitude = Get.arguments?['longitude'];

  @override
  State<DisplayParking> createState() => _DisplayParkingState();
}

class _DisplayParkingState extends State<DisplayParking>
    with SingleTickerProviderStateMixin {
  static const double maxSearchRadiusKm = 1.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371;
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degree) => degree * pi / 180;

  @override
  Widget build(BuildContext context) {
    final latitude = widget.latitude;
    final longitude = widget.longitude;

    if (latitude == null || longitude == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Location unavailable. Cannot find nearby parkings.",
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0f0f), Color(0xFF1a1a1a)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: const Text(
                "Nearby Parkings",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('parkings')
                    .where("isDisable", isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text("Error loading data",
                            style: TextStyle(color: Colors.redAccent)));
                  }

                  if (!snapshot.hasData ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final filteredDocs = <Map<String, dynamic>>[];

                  for (var doc in docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (!data.containsKey('latitude') ||
                        !data.containsKey('longitude')) continue;

                    try {
                      final lat = (data['latitude'] as num).toDouble();
                      final lon = (data['longitude'] as num).toDouble();
                      final distance =
                          _calculateDistance(latitude, longitude, lat, lon);

                      if (distance <= maxSearchRadiusKm) {
                        filteredDocs.add({
                          "data": data,
                          "id": doc.id,
                          "distance": distance,
                        });
                      }
                    } catch (_) {}
                  }

                  if (_isLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Searching for nearby parkings...",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: Lottie.asset(
                                'assets/animations/finding.json',
                                fit: BoxFit.contain),
                          ),
                        ],
                      ),
                    );
                  }

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("No nearby parkings found!",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.25,
                            child: Lottie.asset(
                                'assets/animations/Nonearby.json',
                                fit: BoxFit.contain),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final parkingInfo = filteredDocs[index];
                      final data = parkingInfo["data"];
                      final distance = parkingInfo["distance"];
                      final docId = parkingInfo["id"];
                      final String puid = docId;
                      final String uid = data["uid"];

                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('reviews')
                            .where('parkingId', isEqualTo: puid)
                            .where('ownerId', isEqualTo: uid)
                            .snapshots(),
                        builder: (context, reviewSnapshot) {
                          double averageRating = 0.0;
                          int reviewCount = 0;

                          if (reviewSnapshot.hasData &&
                              reviewSnapshot.data!.docs.isNotEmpty) {
                            final reviews = reviewSnapshot.data!.docs;
                            double total = 0.0;
                            for (var r in reviews) {
                              total += (r['rating'] ?? 0).toDouble();
                            }
                            averageRating = total / reviews.length;
                            reviewCount = reviews.length;
                          }

                          return GestureDetector(
                            onTap: () {
                              Get.to(
                                () => ParkingDetailScreen(
                                  parking: {
                                    ...data,
                                    "uid": uid,
                                    "puid": puid,
                                  },
                                ),
                                transition: Transition.size,
                                duration: const Duration(milliseconds: 800),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 18),
                              decoration: BoxDecoration(
                                color: Colors.grey[900]?.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.25),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.local_parking,
                                          color: Colors.blueAccent, size: 26),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          data["parkingName"] ?? "Unnamed",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      if (reviewCount > 0) ...[
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 20),
                                        Text(
                                          averageRating.toStringAsFixed(1),
                                          style: const TextStyle(
                                              color: Colors.white70),
                                        ),
                                      ] else ...[
                                        const Text(
                                          "Not rated yet",
                                          style:
                                              TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.route_outlined,
                                          color: Colors.cyanAccent, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${(distance * 1000).toStringAsFixed(0)} meters away",
                                        style: const TextStyle(
                                            color: Colors.cyanAccent),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.place,
                                          color: Colors.orange, size: 18),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          data["parkingAddress"] ??
                                              "No address",
                                          style: const TextStyle(
                                              color: Colors.white70),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.currency_rupee_sharp,
                                          color: Colors.greenAccent, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Price: ${data["price"] ?? "N/A"}",
                                        style: const TextStyle(
                                            color: Colors.greenAccent),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
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
