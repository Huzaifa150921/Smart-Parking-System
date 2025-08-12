import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Map<String, dynamic>? bookingData;
  String ownerName = '';
  String parkingName = '';
  String parkingAddress = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args['bookingId'] != null) {
      fetchBookingDetails(args['bookingId']);
    }
  }

  Future<void> fetchBookingDetails(String bookingId) async {
    try {
      final bookingDoc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .get();

      if (bookingDoc.exists) {
        final data = bookingDoc.data()!;
        setState(() => bookingData = data);

        final ownerDoc = await FirebaseFirestore.instance
            .collection('owners')
            .doc(data['ownerId'])
            .get();
        if (ownerDoc.exists) {
          ownerName = ownerDoc.data()?['firstName'] ?? 'Unknown';
        }

        final parkingDoc = await FirebaseFirestore.instance
            .collection('parkings')
            .doc(data['parkingId'])
            .get();
        if (parkingDoc.exists) {
          parkingName = parkingDoc.data()?['parkingName'] ?? 'N/A';
          parkingAddress = parkingDoc.data()?['parkingAddress'] ?? 'N/A';
        }

        setState(() => loading = false);
      }
    } catch (e) {
      print('Error fetching booking details: $e');
      setState(() => loading = false);
    }
  }

  DateTime? parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      try {
        // Try ISO parsing first
        return DateTime.parse(value);
      } catch (_) {
        try {
          // Handle format: "August 6, 2025 at 4:54:03 PM GMT+5"
          return DateFormat("MMMM d, y 'at' h:mm:ss a 'GMT'Z").parse(value);
        } catch (e) {
          print('Failed to parse timestamp: $e');
          return null;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
      );
    }

    if (bookingData == null) {
      return const Scaffold(
        body: Center(child: Text("Booking not found.")),
      );
    }

    final startTime = parseTimestamp(bookingData!['startTime']);
    final endTime = parseTimestamp(bookingData!['endTime']);
    final bookingTime = parseTimestamp(bookingData!['createdAt']);

    final formattedStartDate = startTime != null
        ? DateFormat('yyyy-MM-dd hh:mm a').format(startTime)
        : 'N/A';
    final formattedEndDate = endTime != null
        ? DateFormat('yyyy-MM-dd hh:mm a').format(endTime)
        : 'N/A';
    final formattedBookingDate = bookingTime != null
        ? DateFormat('yyyy-MM-dd hh:mm a').format(bookingTime)
        : 'N/A';

    final paymentStatus =
        ((bookingData!['paymentStatus'] ?? '-') as String).capitalizeFirst ??
            '-';
    final bookingStatus =
        ((bookingData!['status'] ?? '-') as String).capitalizeFirst ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Icon(Icons.receipt_long_rounded,
                        size: 60, color: Colors.white),
                    const SizedBox(height: 10),
                    Text(
                      'Booking Summary',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 40,
                left: 16,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withOpacity(0.95),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildInfoTile('🧾 Transaction ID',
                          bookingData!['transactionId'] ?? 'N/A'),
                      buildInfoTile(
                          '🚗 Slot ID', bookingData!['slotid'] ?? 'N/A'),
                      buildInfoTile(
                          '🔢 Plate Number', bookingData!['plateNo'] ?? 'N/A'),
                      buildInfoTile('👤 Owner Name', ownerName),
                      buildInfoTile('🅿️ Parking Name', parkingName),
                      buildInfoTile('📍 Address', parkingAddress),
                      buildInfoTile(
                          '💰 Total Amount', 'Rs ${bookingData!['price']}'),
                      buildInfoBadgeTile('💳 Payment Status', paymentStatus,
                          statusColor(paymentStatus)),
                      buildInfoBadgeTile('📦 Booking Status', bookingStatus,
                          statusColor(bookingStatus)),
                      buildInfoTile('⏰ Booking Time', formattedBookingDate),
                      buildInfoTile('⏰ Entry Time', formattedStartDate),
                      buildInfoTile('⏰ Exit Time', formattedEndDate),
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

  Widget buildInfoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[800],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoBadgeTile(String title, String value, Color badgeColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: badgeColor.withOpacity(0.5)),
              ),
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: badgeColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
