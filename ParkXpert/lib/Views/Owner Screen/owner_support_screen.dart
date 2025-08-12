import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerSupportScreen extends StatelessWidget {
  const OwnerSupportScreen({super.key});

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: GoogleFonts.nunito(color: const Color(0xFF0081C9)),
        ),
        content: Text(
          message,
          style: GoogleFonts.nunito(color: Colors.black87),
        ),
        actions: [
          TextButton(
            child: const Text("OK", style: TextStyle(color: Color(0xFF0081C9))),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0081C9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Support",
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How can we help you?",
              style: GoogleFonts.nunito(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Email
            SupportCard(
              icon: Icons.email_outlined,
              title: "Email Us",
              subtitle: "support@parkxpert.com",
              color: const Color(0xFF0081C9),
              onTap: () => _showDialog(
                context,
                "Email Support",
                "You can reach us at:\nsupport@parkxpert.com",
              ),
            ),
            const SizedBox(height: 16),

            // Phone
            SupportCard(
              icon: Icons.phone_in_talk_outlined,
              title: "Call Us",
              subtitle: "+123 456 7890",
              color: Colors.green,
              onTap: () => _showDialog(
                context,
                "Call Support",
                "Please call us at:\n+123 456 7890",
              ),
            ),
            const SizedBox(height: 16),

            // Live Chat
            SupportCard(
              icon: Icons.chat_bubble_outline,
              title: "Live Chat",
              subtitle: "Chat with our team",
              color: Colors.orange,
              onTap: () => _showDialog(
                context,
                "Live Chat",
                "Chat feature coming soon!",
              ),
            ),
            const SizedBox(height: 30),

            Text(
              "Frequently Asked",
              style: GoogleFonts.nunito(
                color: const Color(0xFF0081C9),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            faqTile("How to register parking?",
                "Go to 'Register Parking' in the menu."),
            faqTile(
                "How to update profile?", "Visit 'Profile' from the drawer."),
            faqTile(
                "How to contact support?", "Use any method above to reach us."),
          ],
        ),
      ),
    );
  }

  Widget faqTile(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        collapsedTextColor: Colors.black87,
        textColor: const Color(0xFF0081C9),
        iconColor: const Color(0xFF0081C9),
        collapsedIconColor: Colors.black54,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        title: Text(
          question,
          style: GoogleFonts.nunito(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              answer,
              style: GoogleFonts.nunito(color: Colors.black54, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class SupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const SupportCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 25,
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
