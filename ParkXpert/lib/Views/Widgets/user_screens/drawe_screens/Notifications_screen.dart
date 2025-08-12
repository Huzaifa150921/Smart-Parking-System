// ignore_for_file: file_names

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:parkxpert/Controller/UserController/user_controller.dart';
import 'package:parkxpert/Views/Widgets/user_screens/drawe_screens/notification_detail_screen.dart';
import 'package:shimmer/shimmer.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final userController = Get.find<UserController>();
  bool _showShimmer = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showShimmer = false);
      }
    });
  }

  Stream<List<Map<String, dynamic>>> getNotificationStream() {
    final uid = userController.currentUser.value?.uid;
    if (uid == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('notifications')
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF3F51B5),
        title: Text(
          'Notifications',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getNotificationStream(),
        builder: (context, snapshot) {
          if (_showShimmer ||
              snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmer();
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading notifications'));
          }

          final notifications = snapshot.data;
          if (notifications == null || notifications.isEmpty) {
            return _buildNoData();
          }

          return _buildNotificationList(notifications);
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.white, radius: 25),
              title: Container(height: 10, color: Colors.white),
              subtitle: Container(
                  height: 60,
                  margin: const EdgeInsets.only(top: 5),
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoData() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: Lottie.asset('assets/animations/No_data.json'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No Notifications Found",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationList(List<Map<String, dynamic>> notifications) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final timestamp = notification['timestamp']?.toDate();
        final isRead = notification['isread'] == true;

        return GestureDetector(
          onTap: () => _handleNotificationTap(notification),
          child: Container(
            decoration: BoxDecoration(
              color: isRead ? Colors.white : const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!isRead)
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade100,
                ),
                child:
                    const Icon(Icons.notifications_active, color: Colors.blue),
              ),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      notification['title'] ?? '',
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                        fontSize: 15,
                        color: isRead ? Colors.black54 : Colors.black87,
                      ),
                    ),
                  ),
                  if (timestamp != null)
                    Text(
                      _formatTime(timestamp),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  notification['body'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: isRead ? Colors.black45 : Colors.black87,
                    fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    final docId = notification['id'];
    final isAlreadyRead = notification['isread'] == true;

    if (!isAlreadyRead) {
      FirebaseFirestore.instance
          .collection('notifications')
          .doc(docId)
          .update({'isread': true});
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationDetailScreen(docId: docId),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  }
}
