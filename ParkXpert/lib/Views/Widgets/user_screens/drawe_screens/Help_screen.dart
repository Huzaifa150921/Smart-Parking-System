// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF3F51B5),
        title: Text(
          'Help Center',
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _helpCard(
            icon: Icons.school,
            iconColor: Colors.blueAccent,
            title: 'How to Use the App?',
            description:
                'Learn how to search, book parking, navigate maps, and more.',
          ),
          const SizedBox(height: 18),
          _helpCard(
            icon: Icons.payment_rounded,
            iconColor: Colors.green,
            title: 'Payment Help',
            description:
                'Issues with payments, refunds or receipts? Start here.',
          ),
          const SizedBox(height: 18),
          _helpCard(
            icon: Icons.lock_outline,
            iconColor: Colors.orange,
            title: 'Privacy & Data',
            description:
                'Understand our privacy policy and data safety measures.',
          ),
          const SizedBox(height: 18),
          _helpCard(
            icon: Icons.directions_car_filled_outlined,
            iconColor: Colors.teal,
            title: 'Parking Slot Issues',
            description:
                'Can’t find a slot or got wrong directions? Let us guide you.',
          ),
          const SizedBox(height: 18),
          _helpCard(
            icon: Icons.notifications_active_outlined,
            iconColor: Colors.redAccent,
            title: 'Booking Alerts',
            description:
                'Enable or troubleshoot booking and reminder notifications.',
          ),
          const SizedBox(height: 18),
          _helpCard(
            icon: Icons.settings_suggest_rounded,
            iconColor: Colors.purpleAccent,
            title: 'App Settings',
            description:
                'Change language, units, app behavior and notification settings.',
          ),
          const SizedBox(height: 18),
          _helpCard(
            icon: Icons.headset_mic_rounded,
            iconColor: Colors.deepPurple,
            title: 'Contact Support',
            description:
                'Need direct help? Reach out to our 24/7 support team.',
          ),
        ],
      ),
    );
  }

  Widget _helpCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
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
