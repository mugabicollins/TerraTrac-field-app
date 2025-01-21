import 'package:flutter/material.dart';

class CustomDialogButton extends StatelessWidget {
  const CustomDialogButton({super.key, this.buttonText, this.voidCallback});
  final String? buttonText;
  final VoidCallback? voidCallback;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: voidCallback,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black,
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
