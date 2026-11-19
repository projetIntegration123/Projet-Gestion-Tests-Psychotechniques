import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Halo radial décoratif
Widget blob(double s, Color c, double o) => Container(
  width: s,
  height: s,
  decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [c.withOpacity(o), c.withOpacity(0)])),
);

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = C.navy.withOpacity(.035)
      ..strokeWidth = 1;
    for (double x = 0; x < s.width; x += 48) {
      c.drawLine(Offset(x, 0), Offset(x, s.height), p);
    }
    for (double y = 0; y < s.height; y += 48) {
      c.drawLine(Offset(0, y), Offset(s.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

/// Fond « aurore » animé : halos qui dérivent + grille discrète
class AppBg extends StatefulWidget {
  final Widget child;
  final Widget? overlay;
  const AppBg({super.key, required this.child, this.overlay});
  @override
  State<AppBg> createState() => _AppBgState();
}

class _AppBgState extends State<AppBg> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(seconds: 26))..repeat();
  Offset mouse = const Offset(500, 300);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    onHover: (e) => setState(() => mouse = e.localPosition),
    child: Stack(children: [
      Positioned.fill(child: CustomPaint(painter: GridPainter())),
      Positioned.fill(
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) {
              final t = _c.value * 2 * math.pi;
              return Stack(children: [
                Align(
                    alignment: Alignment(-.85 + .3 * math.sin(t), -.9 + .2 * math.cos(t)),
                    child: blob(560, C.teal2, .26)),
                Align(
                    alignment: Alignment(.95 + .2 * math.cos(t * 2), .85 + .2 * math.sin(t)),
                    child: blob(620, C.navy2, .16)),
                Align(
                    alignment: Alignment(.5 * math.sin(t), .2 * math.cos(t * 3)),
                    child: blob(420, const Color(0xFF7C9CFF), .14)),
              ]);
            },
          ),
        ),
      ),
      // projecteur qui suit le curseur
      Positioned.fill(
        child: IgnorePointer(
          child: TweenAnimationBuilder<Offset>(
            tween: Tween(end: mouse),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOut,
            builder: (_, v, __) => Stack(children: [
              Positioned(left: v.dx - 260, top: v.dy - 260, child: blob(520, C.teal2, .22)),
            ]),
          ),
        ),
      ),
      Positioned.fill(child: widget.child),
      if (widget.overlay != null) Positioned.fill(child: IgnorePointer(child: widget.overlay!)),
    ]),
  );
}
