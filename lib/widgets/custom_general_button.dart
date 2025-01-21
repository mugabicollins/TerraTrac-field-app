import 'package:flutter/material.dart';
import 'package:terrapipe/utilities/app_text_style.dart';

class GeneralTextButton extends StatelessWidget {
  const GeneralTextButton({
    Key? key,
    required this.buttonText,
    required this.buttonColor,
   this.textColor,
    this.borderColor = Colors.transparent,
    this.angle = 10.0,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.bold,
    this.horizontal = 5,
    this.vertical = 5,
    this.buttonWidth,
    required this.onTap,
  }) : super(key: key);

  final String buttonText;
  final Function() onTap;
  final Color buttonColor;
  final Color borderColor;
  final Color? textColor;
  final double angle;
  final double fontSize;
  final FontWeight fontWeight;
  final double horizontal;
  final double vertical;
  final double? buttonWidth;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  buttonWidth ?? MediaQuery.of(context).size.width * 0.9 / 2,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: buttonColor,
          padding:
              EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColor),
            borderRadius: BorderRadius.circular(angle),
          ),
        ),
        child: Text(
          buttonText,
          style: textColor != null ? TextStyle(color: textColor) : AppTextStyles.labelLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}