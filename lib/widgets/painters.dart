import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Anneau de progression dégradé
class RingPainter extends CustomPainter {
  final double value, stroke;
  final List<Color> colors;
  final Color? track;
  RingPainter(this.value, {this.stroke = 10, this.colors = const [C.teal, C.teal2], this.track});
  @override
  void paint(Canvas c, Size s) {
    final r = Rect.fromLTWH(stroke / 2, stroke / 2, s.width - stroke, s.height - stroke);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    c.drawArc(r, 0, 2 * math.pi, false, p..color = track ?? C.border.withOpacity(.8));
    if (value > 0) {
      p.shader = SweepGradient(colors: colors, transform: const GradientRotation(-math.pi / 2))
          .createShader(r);
      c.drawArc(r, -math.pi / 2, 2 * math.pi * value.clamp(0.0, 1.0), false, p..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(RingPainter o) => true;
}

/// Motif de points décoratif
class DotsPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = Colors.white.withOpacity(.07);
    for (double x = 0; x < s.width; x += 28) {
      for (double y = 0; y < s.height; y += 28) {
        c.drawCircle(Offset(x, y), 1.6, p);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
