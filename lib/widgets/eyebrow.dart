import 'package:flutter/material.dart';
import '../core/theme.dart';

class Eyebrow extends StatelessWidget {
  final String text;
  final Color color;
  const Eyebrow(this.text, {super.key, this.color = C.teal});
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: TextStyle(fontSize: 10.5, letterSpacing: 1.4, fontWeight: FontWeight.w800, color: color));
}
