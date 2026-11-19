import 'package:flutter/material.dart';

/// Apparition progressive (fade + glissement) avec délai
class Reveal extends StatelessWidget {
  final Widget child;
  final int delay;
  const Reveal({super.key, required this.child, this.delay = 0});
  @override
  Widget build(BuildContext context) {
    final total = 700 + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: Curves.easeOutCubic),
      builder: (_, v, c) => Opacity(
          opacity: v, child: Transform.translate(offset: Offset(0, 28 * (1 - v)), child: c)),
      child: child,
    );
  }
}
