import 'package:flutter/material.dart';

class TextFeildInput extends StatefulWidget {
  const TextFeildInput({
    super.key,
    required this.labeltext,
    required this.hinttext,
    required this.icon,
    this.hide = false,
    required this.inputtpe,
    this.controller,
    this.validator,
    this.onChanged,
  });

  final String labeltext;
  final String hinttext;
  final IconData icon;
  final bool? hide;
  final TextInputType inputtpe;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  @override
  // ignore: library_private_types_in_public_api
  _TextFeildInputState createState() => _TextFeildInputState();
}

class _TextFeildInputState extends State<TextFeildInput> {
  bool _isPasswordHidden = true;

  @override
  void initState() {
    super.initState();
    _isPasswordHidden = widget.hide ?? true;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _isPasswordHidden,
        keyboardType: widget.inputtpe,
        validator: widget.validator,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: widget.labeltext,
          hintText: widget.hinttext,
          prefixIcon: Icon(
            widget.icon,
            color: Colors.tealAccent,
            size: screenWidth * 0.06,
          ),
          suffixIcon: widget.inputtpe == TextInputType.visiblePassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                    color: Colors.tealAccent,
                    size: screenWidth * 0.06,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordHidden = !_isPasswordHidden;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            borderSide: BorderSide(
              color: Colors.grey.shade600,
              width: screenWidth * 0.005,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            borderSide: BorderSide(
              color: Colors.tealAccent,
              width: screenWidth * 0.006,
            ),
          ),
          filled: true,
          fillColor: Colors.grey.shade900,
          labelStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: screenWidth * 0.045,
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: screenWidth * 0.04,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.015,
            horizontal: screenWidth * 0.04,
          ),
        ),
        style: TextStyle(
          fontSize: screenWidth * 0.05,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
