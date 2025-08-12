import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountAsker extends StatelessWidget {
  const AccountAsker({
    super.key,
    required this.maintet,
    required this.subtext,
    this.func,
  });

  final String maintet;
  final String subtext;
  final Function()? func;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            maintet,
            style: GoogleFonts.nobile(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
              letterSpacing: 1,
            ),
          ),
          SizedBox(width: screenWidth * 0.012),
          GestureDetector(
            onTap: func,
            child: Text(
              subtext,
              style: GoogleFonts.nobile(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
