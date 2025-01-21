import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';

Bubble buildBubble({
  required String title,
  required IconData icon,
  required Color color,
  required VoidCallback onPress,
}) {
  return Bubble(
    title: title,
    iconColor: Colors.white,
    bubbleColor: color,
    icon: icon,
    titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
    onPress: onPress,
  );
}
