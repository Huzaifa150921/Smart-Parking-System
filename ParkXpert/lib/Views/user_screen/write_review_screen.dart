import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parkxpert/Controller/UserController/user_controller.dart';
import 'package:parkxpert/utils/utils.dart';

class WriteReviewScreen extends StatefulWidget {
  final String bookingId;
  final String ownerId;

  const WriteReviewScreen({
    super.key,
    required this.bookingId,
    required this.ownerId,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitReview() async {
    if (_rating == 0.0 || _commentController.text.trim().isEmpty) {
      Utils.snackBar(
        "Missing Fields",
        "Please provide rating and comment.",
        true,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Utils.snackBar("Error", "User not logged in", true);
        return;
      }

      // Fetch user profile
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userName = userDoc.data()?['name'] ?? 'Anonymous';
      final userProfilePic = userDoc.data()?['profilePic'] ?? '';

      // Get booking info
      final bookingDoc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .get();

      final parkingId = bookingDoc.data()?['parkingId'] ?? '';
      final parkingName = bookingDoc.data()?['parkingName'] ?? 'your parking';
      final plateNo = bookingDoc.data()?['vehiclePlateNumber'] ?? '';

      final review = {
        'bookingId': widget.bookingId,
        'parkingId': parkingId,
        'ownerId': widget.ownerId,
        'userId': user.uid,
        'userName': userName,
        'userProfilePic': userProfilePic,
        'rating': _rating,
        'comment': _commentController.text.trim(),
        'timestamp': Timestamp.now(),
      };

      // Store review in Firestore
      await FirebaseFirestore.instance.collection('reviews').add(review);

      // Mark booking as reviewed
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({'isReviewed': true});

      // Send in-app notification to owner
      final userController = Get.find<UserController>();
      await userController.sendInAppNotification(
        uid: widget.ownerId,
        title: 'Review Received',
        body: "A User left a review on at your parking",
        type: 'review_received',
        data: {
          'bookingId': widget.bookingId,
          'parkingId': parkingId,
          'parkingName': parkingName,
          'plateNo': plateNo,
          'rating': _rating,
        },
      );

      Navigator.pop(context);
    } catch (e) {
      Utils.snackBar("Error", "Failed to submit review.", true);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isButtonEnabled =
        _rating > 0.0 && _commentController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF3F51B5),
        title: Text(
          "Write a Review",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rate your experience",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  double starValue = index + 1.0;
                  IconData icon;

                  if (_rating >= starValue) {
                    icon = Icons.star;
                  } else if (_rating >= starValue - 0.5) {
                    icon = Icons.star_half;
                  } else {
                    icon = Icons.star_border;
                  }

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = starValue;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        icon,
                        size: 40,
                        color: Colors.amber,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Write your comment",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 5,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                hintText: 'Write your comment...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isButtonEnabled && !_isSubmitting ? _submitReview : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF3F51B5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Submit Review",
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
