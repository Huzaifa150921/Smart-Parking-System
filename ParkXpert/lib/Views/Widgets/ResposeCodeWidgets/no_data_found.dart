import 'package:flutter/material.dart';

class Nodatafound extends StatelessWidget {
  const Nodatafound({super.key});

  @override
  Widget build(BuildContext context) {
    double screenheight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: screenwidth,
        height: screenheight,
        color: Colors.white,
        child: Center(
          child: SizedBox(
            width: screenwidth * 0.6,
            height: screenheight * 0.6,
            child: Image.asset(
              "assets/images/Nodata.avif",
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}
