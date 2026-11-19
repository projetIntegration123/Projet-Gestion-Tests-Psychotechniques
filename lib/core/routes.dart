import 'package:flutter/material.dart';

Route<T> fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
  pageBuilder: (_, __, ___) => page,
  transitionDuration: const Duration(milliseconds: 550),
  transitionsBuilder: (_, a, __, child) => FadeTransition(
    opacity: a,
    child: SlideTransition(
      position: Tween(begin: const Offset(0, .03), end: Offset.zero)
          .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: child,
    ),
  ),
);
