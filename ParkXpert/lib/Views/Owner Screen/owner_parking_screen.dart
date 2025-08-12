import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:parkxpert/res/routes/route_name.dart';

class OwnerParkingScreen extends StatefulWidget {
  const OwnerParkingScreen({super.key});

  @override
  State<OwnerParkingScreen> createState() => _OwnerParkingScreenState();
}

class _OwnerParkingScreenState extends State<OwnerParkingScreen> {
  List<Map<String, dynamic>> parkingList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchParkings();
  }

  Future<void> fetchParkings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final query = await FirebaseFirestore.instance
        .collection("parkings")
        .where("uid", isEqualTo: uid)
        .orderBy("accountCreated", descending: true)
        .get();

    final results = query.docs.map((doc) => doc.data()).toList();

    // Reduced shimmer delay to 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      parkingList = results;
      isLoading = false;
    });
  }

  Widget buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget buildParkingItem(Map<String, dynamic> parking) {
    return GestureDetector(
      onTap: () {
        final puid = parking['puid'];
        if (puid != null) {
          Get.toNamed(RouteName.ownerparkingdetail, arguments: {'puid': puid});
        } else {
          Get.snackbar("Error", "Parking ID not found");
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.local_parking, color: Color(0xFF0081C9), size: 32),
            const SizedBox(height: 12),
            Text(
              parking["parkingName"] ?? "Unnamed",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              parking["parkingAddress"] ?? "No address",
              style: const TextStyle(color: Colors.black54),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Parkings",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0081C9),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? GridView.builder(
                itemCount: 10,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 5 / 3.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (_, __) => buildShimmerItem(),
              )
            : parkingList.isEmpty
                ? const Center(
                    child: Text(
                      "No parking data found.",
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : GridView.builder(
                    itemCount: parkingList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 4 / 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final parking = parkingList[index];
                      return buildParkingItem(parking);
                    },
                  ),
      ),
    );
  }
}
