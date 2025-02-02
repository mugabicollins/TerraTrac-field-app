import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label; // Text inside the button
  final VoidCallback onTap; // Function to execute on tap
  final Color color; // Background color of the button
  final Color textColor; // Text color
  final Color borderColor; // Text color
  final double height; // Button height
  final double width; // Button width
  final double borderRadius; // Border radius
  final TextStyle? textStyle; // Custom text style

  const CustomButton({
    Key? key,
    required this.label,
    required this.onTap,
    this.borderColor=Colors.transparent,
    this.color = Colors.blue,
    this.textColor = Colors.white,
    this.height = 40.0,
    this.width = 100.0,
    this.borderRadius = 8.0,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius), // For ripple effect
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color:borderColor
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: Text(
            label,
            style: textStyle ??
                TextStyle(
                  color: textColor,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}
