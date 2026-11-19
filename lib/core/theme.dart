import 'package:flutter/material.dart';

class C {
  static const navy = Color(0xFF14213D);
  static const navy2 = Color(0xFF27407A);
  static const teal = Color(0xFF0E8C84);
  static const teal2 = Color(0xFF22C7B8);
  static const tealLight = Color(0xFFE3F5F3);
  static const bg = Color(0xFFF4F7FB);
  static const border = Color(0xFFE3E8F0);
  static const muted = Color(0xFF64748B);
  static const red = Color(0xFFE5484D);
  static const amber = Color(0xFFF5A524);
}

const gradTeal = LinearGradient(
    colors: [C.teal, C.teal2], begin: Alignment.topLeft, end: Alignment.bottomRight);
const gradRed = LinearGradient(colors: [C.red, Color(0xFFFF8A65)]);
const gradNavy = LinearGradient(
    colors: [C.navy, C.navy2], begin: Alignment.topLeft, end: Alignment.bottomRight);

List<BoxShadow> softShadow([double o = .06]) => [
  BoxShadow(color: C.navy.withOpacity(o), blurRadius: 30, offset: const Offset(0, 12)),
  BoxShadow(color: C.navy.withOpacity(o / 2), blurRadius: 4, offset: const Offset(0, 1)),
];
