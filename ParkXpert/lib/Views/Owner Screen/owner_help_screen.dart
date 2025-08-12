import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerHelpScreen extends StatelessWidget {
  const OwnerHelpScreen({super.key});

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
          "Help Center",
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "Welcome to Help Center 👋",
            style: GoogleFonts.nunito(
              color: const Color(0xFF0081C9),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Here are some frequently asked questions to assist you:",
            style: GoogleFonts.nunito(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          HelpCard(
            question: "How do I register my parking spot?",
            answer:
                "Go to the drawer → 'Register Parking'. Fill out the required form and submit.",
          ),
          HelpCard(
            question: "How can I update my profile?",
            answer:
                "Navigate to 'Profile' from the drawer and click the edit icon to make changes.",
          ),
          HelpCard(
            question: "Where can I see reviews for my parking?",
            answer:
                "Open 'Reviews' from the drawer to see user feedback and ratings.",
          ),
          HelpCard(
            question: "Can I switch to User mode?",
            answer:
                "Yes, just tap the 'User mode' button in the drawer to explore user features.",
          ),
          HelpCard(
            question: "What if I need technical support?",
            answer:
                "Use the 'Support' option in the drawer to contact us via email, call, or chat.",
          ),
          const SizedBox(height: 30),
          Center(
            child: Text(
              "Still need help? Contact Support.",
              style: GoogleFonts.nunito(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpCard extends StatefulWidget {
  final String question;
  final String answer;

  const HelpCard({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<HelpCard> createState() => _HelpCardState();
}

class _HelpCardState extends State<HelpCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0081C9).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: GoogleFonts.nunito(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF0081C9),
                ),
              ],
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                widget.answer,
                style: GoogleFonts.nunito(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
