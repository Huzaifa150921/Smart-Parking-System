import 'package:double_tap_exit/double_tap_exit.dart';
import 'package:flutter/material.dart';

class DoubleTapExitFeature extends StatelessWidget {
  const DoubleTapExitFeature(
      {super.key,
      required this.child,
      required this.bgColor,
      required this.textColor});
  final Widget child;
  final Color bgColor;
  final Color textColor;
  @override
  Widget build(BuildContext context) {
    return DoubleTap(
      message: "Double tap to exit app!",
      waitForSecondBackPress: 2,
      background: bgColor,
      backgroundRadius: 20,
      textStyle: TextStyle(
          fontSize: 15,
          color: textColor,
          letterSpacing: 1,
          fontWeight: FontWeight.w500),
      child: child,
    );
  }
}
