// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RulesAndTerms extends StatelessWidget {
  const RulesAndTerms({super.key});

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
          'Rules & Terms',
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
          _sectionCard(
            title: 'General Rules',
            content:
                '• Respect other users and property.\n• Do not park in unauthorized areas.\n• Follow all in-app instructions.',
          ),
          const SizedBox(height: 20),
          _sectionCard(
            title: 'Payment Terms',
            content:
                '• All payments are processed securely.\n• Refunds are subject to our refund policy.\n• Late cancellation may result in charges.',
          ),
          const SizedBox(height: 20),
          _sectionCard(
            title: 'Privacy Policy',
            content:
                '• Your data is encrypted and stored securely.\n• We never share your data with third parties without consent.',
          ),
          const SizedBox(height: 20),
          _sectionCard(
            title: 'Liability Disclaimer',
            content:
                '• The app is not liable for any loss or damage.\n• Parking is at the user’s own risk.',
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required String content}) {
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
          ),
        ],
      ),
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
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
