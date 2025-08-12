import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserDataShow extends StatelessWidget {
  const UserDataShow({
    super.key,
    required this.text,
    this.subtext,
    this.onPressed,
    this.icon,
    required this.color,
  });

  final String text;
  final String? subtext;
  final void Function()? onPressed;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.022,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 129, 171, 206),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Text block
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                if (subtext != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      subtext!,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
            // Icon (if provided)
            if (icon != null)
              Icon(
                icon,
                size: screenWidth * 0.06,
                color: Colors.blue.shade500,
              ),
          ],
        ),
      ),
    );
  }
}
