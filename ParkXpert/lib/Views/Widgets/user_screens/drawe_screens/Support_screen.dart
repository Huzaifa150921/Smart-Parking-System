// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FD),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF3F51B5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Support',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _supportTile(
            icon: Icons.question_answer_rounded,
            title: "FAQs",
            subtitle: "Find answers to common questions.",
            color: Colors.blueAccent,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _supportTile(
            icon: Icons.chat_bubble_outline,
            title: "Live Chat",
            subtitle: "Talk to a support agent instantly.",
            color: Colors.green,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _supportTile(
            icon: Icons.email_outlined,
            title: "Email Support",
            subtitle: "Reach out via email for any help.",
            color: Colors.deepPurple,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _supportTile(
            icon: Icons.feedback_outlined,
            title: "Send Feedback",
            subtitle: "Tell us what you think of our app.",
            color: Colors.orange,
            onTap: () {},
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                // Implement feedback or contact action
              },
              icon: const Icon(Icons.support_agent, color: Colors.white),
              label: Text(
                'Contact Support',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _supportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              // ignore: deprecated_member_use
              backgroundColor: color.withOpacity(0.15),
              // ignore: sort_child_properties_last
              child: Icon(icon, color: color, size: 26),
              radius: 26,
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}
