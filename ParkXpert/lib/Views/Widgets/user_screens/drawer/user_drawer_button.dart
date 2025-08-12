import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:google_fonts/google_fonts.dart';

class UserDrawerButton extends StatelessWidget {
  const UserDrawerButton(
      {super.key, required this.text, required this.icon, this.func});
  final String text;
  final IconData icon;
  final void Function()? func;
  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;

    return GFButton(
      onPressed: func,
      fullWidthButton: true,
      shape: GFButtonShape.square,
      size: 60,
      color: const Color.fromARGB(255, 24, 24, 24),
      hoverColor: Colors.blue[700],
      splashColor: Colors.blue[800],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: screenwidth * 0.04),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 88, 88, 88),
            ),
          ),
          SizedBox(
            width: screenwidth * 0.04,
          ),
          Text(
            text,
            style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.white,
                letterSpacing: 1,
                fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}
