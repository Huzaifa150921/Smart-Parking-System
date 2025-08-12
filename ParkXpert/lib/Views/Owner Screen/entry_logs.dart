import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

class EntryLogs extends StatelessWidget {
  final String puid;

  const EntryLogs({super.key, required this.puid});

  Future<Map<String, dynamic>?> _fetchUserInfo(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      return null;
    }
  }

  String _formatTime(dynamic time) {
    try {
      DateTime date;

      if (time is Timestamp) {
        date = time.toDate().toLocal();
      } else if (time is String) {
        final regex = RegExp(
            r'([A-Za-z]+ \d{1,2}, \d{4}) at (\d{1,2}:\d{2}:\d{2} [AP]M) GMT([+-]\d+)');
        final match = regex.firstMatch(time);

        if (match != null) {
          final datePart = match.group(1)!;
          final timePart = match.group(2)!;
          final offsetHours = int.parse(match.group(3)!);

          final dateTimeString = "$datePart $timePart";
          final format = DateFormat("MMMM d, yyyy h:mm:ss a");
          final parsedDate = format.parse(dateTimeString, true);
          date = parsedDate.subtract(Duration(hours: offsetHours)).toLocal();
        } else {
          date = DateTime.tryParse(time)?.toLocal() ?? DateTime.now();
        }
      } else {
        return 'Invalid time';
      }

      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return 'Invalid time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Entry Logs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0081C9),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('entry_logs')
            .where('parkingId', isEqualTo: puid)
            .orderBy('startTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading logs."));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data?.docs ?? [];

          if (logs.isEmpty) {
            return Column(
              children: [
                const Spacer(flex: 1),
                Center(
                  child: Lottie.asset(
                    'assets/animations/No_data.json',
                    height: MediaQuery.of(context).size.height * 0.23,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "No logs found",
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
                const Spacer(flex: 2),
              ],
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "Total Logs: ${logs.length}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: logs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    final log = logs[index].data() as Map<String, dynamic>;
                    final userId = log['userId'] ?? '';
                    final plateNo = log['plateNo'] ?? '';
                    final startTime = log['startTime'];

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _fetchUserInfo(userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: const CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            height: 14,
                                            width: 120,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0081C9)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            "Plate No: $plateNo",
                                            style: const TextStyle(
                                              color: Color(0xFF0081C9),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Entry Time: ${_formatTime(startTime)}",
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final userData = snapshot.data;
                        final userName = userData?['name'] ?? 'Unknown';
                        final profilePicEncoded = userData?['profilePic'] ?? '';

                        ImageProvider imageProvider;
                        try {
                          if (profilePicEncoded.isNotEmpty) {
                            final bytes = base64Decode(profilePicEncoded);
                            imageProvider = MemoryImage(bytes);
                          } else {
                            imageProvider = const AssetImage(
                                'assets/images/default_profile_pic.jfif');
                          }
                        } catch (e) {
                          imageProvider = const AssetImage(
                              'assets/images/default_profile_pic.jfif');
                        }

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundImage: imageProvider,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0081C9)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          "Plate No: $plateNo",
                                          style: const TextStyle(
                                            color: Color(0xFF0081C9),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Entry Time: ${_formatTime(startTime)}",
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
