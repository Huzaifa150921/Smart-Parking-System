import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationDetailScreen extends StatefulWidget {
  final String docId;

  const NotificationDetailScreen({super.key, required this.docId});

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  Map<String, dynamic>? notificationData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotification();
  }

  Future<void> fetchNotification() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('notifications')
          .doc(widget.docId)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          notificationData = doc.data();
          isLoading = false;
        });
      } else {
        throw Exception('Notification not found');
      }
    } catch (e) {
      print('Error fetching notification: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      case 'active':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: getStatusColor(status).withOpacity(0.1),
        border: Border.all(color: getStatusColor(status)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: getStatusColor(status),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildColoredBox(String message, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: getStatusColor(status).withOpacity(0.05),
        border: Border.all(color: getStatusColor(status).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 16,
          color: getStatusColor(status),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget buildCustomMessage() {
    final type = notificationData?['type'];
    final data = notificationData?['data'] ?? {};

    if (type == 'verification_status' || type == 'parking_status') {
      final firstName = data['firstName'] ?? '';
      final lastName = data['lastName'] ?? '';
      final ownerName = '$firstName $lastName'.trim().isEmpty
          ? 'Unknown Owner'
          : '$firstName $lastName';

      final parkingName = data['parkingName'] ?? 'Unknown Parking';
      final status = data['status'] ?? 'updated';

      final sentence =
          'Your registration request on owner name $ownerName with parking $parkingName has been ${status.toLowerCase()}.';

      return buildColoredBox(sentence, status);
    }

    if ((type == 'user_cancel' || type == 'owner_cancel') &&
        data['bookingId'] != null) {
      final bookingId = data['bookingId'];

      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .get(),
        builder: (context, bookingSnapshot) {
          if (bookingSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!bookingSnapshot.hasData || !bookingSnapshot.data!.exists) {
            return const Text('Booking details not found.');
          }

          final booking = bookingSnapshot.data!.data() as Map<String, dynamic>;
          final slotId = booking['slotid'] ?? 'N/A';
          final plateNo = booking['plateNo'] ?? 'N/A';
          final parkingId = booking['parkingId'];
          final userId = booking['userId'];

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('parkings')
                .doc(parkingId)
                .get(),
            builder: (context, parkingSnapshot) {
              final parkingName =
                  parkingSnapshot.data?.get('parkingName') ?? 'Unknown';

              if (type == 'user_cancel') {
                final message =
                    "Your booking at '$parkingName' for vehicle '$plateNo' in slot '$slotId' has been cancelled.";
                return buildColoredBox(message, 'cancelled');
              } else {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get(),
                  builder: (context, userSnapshot) {
                    final message =
                        "A user has cancelled their booking at '$parkingName' in slot '$slotId' for vehicle '$plateNo'.";
                    return buildColoredBox(message, 'cancelled');
                  },
                );
              }
            },
          );
        },
      );
    }

    if (type == 'auto_completed_no_show' && data['bookingId'] != null) {
      final bookingId = data['bookingId'];
      final slotId = data['slotId'] ?? 'N/A';

      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .get(),
        builder: (context, bookingSnapshot) {
          if (bookingSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!bookingSnapshot.hasData || !bookingSnapshot.data!.exists) {
            return const Text('Booking details not found.');
          }

          final booking = bookingSnapshot.data!.data() as Map<String, dynamic>;
          final plateNo = booking['plateNo'] ?? 'N/A';
          final parkingId = booking['parkingId'] ?? '';

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('parkings')
                .doc(parkingId)
                .get(),
            builder: (context, parkingSnapshot) {
              final parkingName =
                  parkingSnapshot.data?.get('parkingName') ?? 'Unknown';

              final message =
                  "Your booking at '$parkingName' in slot '$slotId' for vehicle '$plateNo' was marked as completed because you did not arrive on time.";

              return buildColoredBox(message, 'completed');
            },
          );
        },
      );
    }

    if (type == 'booking' && data['bookingId'] != null) {
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('bookings')
            .doc(data['bookingId'])
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text('Booking details not found.');
          }

          final booking = snapshot.data!.data() as Map<String, dynamic>;
          final parkingName = booking['parkingName'] ?? 'N/A';
          final plateNo = booking['plateNo'] ?? 'N/A';
          final duration = booking['durationInDays'] ?? 'N/A';
          final price = booking['price'] ?? 'N/A';
          final status = booking['status'] ?? 'N/A';
          final slotId = booking['slotid'] ?? 'N/A';

          final statement =
              "You booked a slot at '$parkingName' Slot ID: $slotId for vehicle no '$plateNo'. "
              "The booking is valid for $duration day(s), with a total amount of Rs. $price. ";

          return buildColoredBox(statement, status);
        },
      );
    }

    if (type == 'booking_alert' && data['bookingId'] != null) {
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('bookings')
            .doc(data['bookingId'])
            .get(),
        builder: (context, bookingSnapshot) {
          if (bookingSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!bookingSnapshot.hasData || !bookingSnapshot.data!.exists) {
            return const Text('Booking details not found.');
          }

          final booking = bookingSnapshot.data!.data() as Map<String, dynamic>;
          final parkingName = booking['parkingName'] ?? 'N/A';
          final plateNo = booking['plateNo'] ?? 'N/A';
          final duration = booking['durationInDays'] ?? 'N/A';
          final price = booking['price'] ?? 'N/A';
          final status = booking['status'] ?? 'N/A';
          final slotId = booking['slotid'] ?? 'N/A';
          final userId = booking['userId'] ?? '';

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get(),
            builder: (context, userSnapshot) {
              final statement =
                  "A user has booked a slot at your parking space named '$parkingName'. "
                  "The vehicle with plate number '$plateNo' will occupy slot no $slotId for $duration day(s). "
                  "The total amount paid is Rs. $price.";

              return buildColoredBox(statement, status);
            },
          );
        },
      );
    }

    if (type == 'booking_expiry') {
      final parkingName = data['parkingName'] ?? 'N/A';
      final slotId = data['slotId'] ?? 'N/A';
      final plateNo = data['plateNo'] ?? 'N/A';
      final expiryTimeStr = data['expiryTime'] ?? '';

      final uid = notificationData?['uid'] ?? '';

      DateTime? expiryTime;
      try {
        expiryTime = DateTime.parse(expiryTimeStr);
      } catch (_) {}

      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, userSnapshot) {
          final message =
              "Your booking at '$parkingName' Slot ID: $slotId for plate no '$plateNo' is expiring "
              "${expiryTime != null ? 'at ${DateFormat('dd MMM yyyy, hh:mm a').format(expiryTime)}' : 'soon'}.";

          return buildColoredBox(message, 'active');
        },
      );
    }

    if (type == 'review_reminder' && data['bookingId'] != null) {
      final bookingId = data['bookingId'];
      final parkingName = data['parkingName'] ?? 'N/A';
      final plateNo = data['plateNo'] ?? 'N/A';

      final statement =
          "Your booking has been completed Please take a moment to rate your experience at '$parkingName' for your vehicle '$plateNo'. "
          "Your feedback helps us improve and provide better service.";

      return buildColoredBox(statement, 'completed');
    }

    if (type == 'review_received') {
      final parkingName = data['parkingName'] ?? 'your parking';

      // Safely extract and format rating
      final rawRating = data['rating'];
      final rating = (rawRating is num) ? rawRating.toStringAsFixed(1) : 'N/A';

      final message =
          "A user submitted a review with $rating star(s) for $parkingName parking";
      return buildColoredBox(message, 'completed');
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Notification Details"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationData == null
              ? const Center(child: Text("No data found"))
              : Stack(
                  children: [
                    Container(
                      height: 200,
                      decoration: const BoxDecoration(
                        color: Colors.indigo,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(40),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 15,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notificationData!['title'] ?? 'No Title',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                buildCustomMessage(),
                                const SizedBox(height: 10),
                                if (notificationData!['timestamp'] != null)
                                  Text(
                                    formatTimestamp(
                                        notificationData!['timestamp']),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
