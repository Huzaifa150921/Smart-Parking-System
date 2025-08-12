import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parkxpert/Views/Owner%20Screen/entry_logs.dart';
import 'package:parkxpert/Views/Owner%20Screen/exit_logs.dart';
import 'package:shimmer/shimmer.dart';
import 'package:parkxpert/utils/utils.dart';

class OwnerParkingDetailScreen extends StatefulWidget {
  const OwnerParkingDetailScreen({super.key});

  @override
  State<OwnerParkingDetailScreen> createState() =>
      _OwnerParkingDetailScreenState();
}

class _OwnerParkingDetailScreenState extends State<OwnerParkingDetailScreen> {
  bool isEnabled = true;
  String parkingName = "";
  String parkingAddress = "";
  String puid = "";
  int earning = 0;
  bool isLoading = true;
  final TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    puid = Get.arguments['puid'] ?? "";
    if (puid.isNotEmpty) loadData();
  }

  Future<void> loadData() async {
    await Future.wait([fetchParkingDetails(), fetchParkingEarning()]);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => isLoading = false);
  }

  Future<void> fetchParkingDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("parkings")
          .doc(puid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          parkingName = data['parkingName'] ?? "Unnamed";
          parkingAddress = data['parkingAddress'] ?? "No address";
          isEnabled = !(data['isDisable'] ?? false);
          priceController.text = data['price'].toString();
        }
      } else {
        Get.snackbar("Error", "Parking not found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load parking details");
    }
  }

  Future<void> fetchParkingEarning() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("parkings")
          .doc(puid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          earning = data['parkingEarning'] ?? 0;
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch earnings");
    }
  }

  Future<void> saveChanges() async {
    final price = priceController.text.trim();
    if (price.isEmpty) {
      Utils.snackBar("Error", "Price cannot be empty", true);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection("parkings").doc(puid).update({
        "price": int.parse(price),
        "isDisable": !isEnabled,
      });

      Utils.snackBar("Success", "Changes saved successfully!", false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save changes."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF), // Vibrant light background
      appBar: AppBar(
        title: const Text("Parking Details",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0081C9),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoading ? _buildShimmer(height: 100) : _buildEarningCard(),
            const SizedBox(height: 16),
            isLoading ? _buildShimmer(height: 120) : _buildHeader(),
            const SizedBox(height: 28),
            _buildLogButtons(),
            const SizedBox(height: 28),
            _buildSectionTitle("Set per day price"),
            const SizedBox(height: 8),
            isLoading ? _buildShimmer(height: 60) : _buildPriceField(),
            const SizedBox(height: 28),
            _buildSectionTitle("Status"),
            const SizedBox(height: 8),
            isLoading ? _buildShimmer(height: 70) : _buildStatusToggle(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer({required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.white,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildEarningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text("Total Earnings",
              style: TextStyle(color: Colors.black54, fontSize: 16)),
          const SizedBox(height: 8),
          Text("Rs. $earning",
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            parkingName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 45,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      parkingAddress,
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 15),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.location_on, color: Colors.red, size: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildTile(
            color: Colors.greenAccent.shade100,
            icon: Icons.login,
            label: "Entry Logs",
            onTap: () {
              Get.to(() => EntryLogs(puid: puid),
                  transition: Transition.fadeIn,
                  duration: Duration(seconds: 1));
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTile(
            color: Colors.redAccent.shade100,
            icon: Icons.logout,
            label: "Exit Logs",
            onTap: () {
              Get.to(() => ExitLogs(puid: puid),
                  transition: Transition.fadeIn,
                  duration: const Duration(seconds: 1));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return TextField(
      controller: priceController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.currency_rupee),
        hintText: 'Enter price',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildStatusToggle() {
    return GestureDetector(
      onTap: () => setState(() => isEnabled = !isEnabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isEnabled ? Colors.green : Colors.red,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isEnabled ? Icons.toggle_on : Icons.toggle_off_outlined,
                  color: Colors.white,
                  size: 36,
                ),
                const SizedBox(width: 10),
                Text(
                  isEnabled ? "Parking Enabled" : "Parking Disabled",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Icon(Icons.power_settings_new, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: saveChanges,
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text("Save Changes"),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0081C9),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTile({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
