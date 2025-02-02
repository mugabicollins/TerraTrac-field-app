import 'dart:ui';

import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?, String?)? validator;
  final TextStyle style;
  final TextStyle hintStyle;
  final TextStyle labelStyle;
  final Color cursorColor;
  final Color fillColor;
  final String? callerContext;
  final Widget? suffixIconWidget;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  const CustomTextFormField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.fillColor = Colors.transparent,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.style = const TextStyle(
        color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
    this.hintStyle = const TextStyle(color: Colors.grey, fontSize: 14),
    this.labelStyle = const TextStyle(color: Colors.white),
    this.cursorColor = Colors.black,
    this.callerContext,
    this.suffixIconWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: TextFormField(
        selectionHeightStyle: BoxHeightStyle.includeLineSpacingMiddle,
        controller: controller,
        style: style,
        cursorColor: cursorColor,
        cursorHeight: 16,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle,
          labelStyle: labelStyle,
          fillColor: fillColor,
          suffixIcon: suffixIconWidget,
          
          filled: true,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
            borderSide: BorderSide(
              color: Colors.black,
            )
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
            borderSide: BorderSide(
              color: Colors.black,
              width: 1.0,
            ),
          ),
        ),
        validator: (value) {
          if (validator != null) {
            return validator!(value, callerContext);
          }
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          // Default regex for email validation
          String pattern =
              r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}\b';
          RegExp regex = RegExp(pattern);
          if (!regex.hasMatch(value)) {
            return 'Please enter a valid email';
          }
          return null;
        },
        onFieldSubmitted: onSubmitted,
        onChanged: onChanged,
      ),
    );
  }
}
