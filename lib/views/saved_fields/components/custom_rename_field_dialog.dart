import 'package:flutter/material.dart';

class CustomRenameFieldDialog extends StatelessWidget {
  const CustomRenameFieldDialog({super.key, this.buttonText, this.voidCallback, this.buttonColor});
  final String? buttonText;
  final VoidCallback? voidCallback;
  final Color? buttonColor;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: voidCallback,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: buttonColor ?? Colors.black,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child:  Text(
          buttonText ?? '',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
