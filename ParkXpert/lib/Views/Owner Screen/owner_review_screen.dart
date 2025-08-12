import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class OwnerReviewScreen extends StatelessWidget {
  const OwnerReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0081C9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reviews',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .where('ownerId', isEqualTo: currentUserId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(
                    flex: 1,
                  ),
                  SizedBox(
                    height: 320,
                    width: 320,
                    child: Lottie.asset('assets/animations/No_data.json'),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'No reviews found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(
                    flex: 2,
                  )
                ],
              ),
            );
          }

          final reviews = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index].data() as Map<String, dynamic>;

              final String name = review['userName'] ?? 'Anonymous';
              final String comment = review['comment'] ?? '';
              final double rating = (review['rating'] ?? 0).toDouble();
              final Timestamp timestamp =
                  review['timestamp'] ?? Timestamp.now();
              final String formattedDate =
                  DateFormat.yMMMMd().format(timestamp.toDate());

              Uint8List? imageBytes;
              if (review['userProfilePic'] != null) {
                try {
                  imageBytes = base64Decode(review['userProfilePic']);
                } catch (_) {}
              }

              return ReviewCard(
                name: name,
                profileBytes: imageBytes,
                rating: rating,
                comment: comment,
                date: formattedDate,
              );
            },
          );
        },
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String name;
  final double rating;
  final String comment;
  final String date;
  final Uint8List? profileBytes;

  const ReviewCard({
    super.key,
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
    this.profileBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
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
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    profileBytes != null ? MemoryImage(profileBytes!) : null,
                child: profileBytes == null
                    ? const Icon(Icons.person, color: Colors.black54)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              _buildRatingStars(rating),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            date,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (i) {
        if (rating >= i + 1) {
          return Icon(Icons.star, size: 18, color: Colors.amber.shade600);
        } else if (rating > i && rating < i + 1) {
          return Icon(Icons.star_half, size: 18, color: Colors.amber.shade600);
        } else {
          return Icon(Icons.star_border,
              size: 18, color: Colors.amber.shade600);
        }
      }),
    );
  }
}
