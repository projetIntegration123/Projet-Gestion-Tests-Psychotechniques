import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Réseau de particules reliées entre elles (thème « neurones »)
class ParticleField extends StatefulWidget {
  const ParticleField({super.key});
  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(seconds: 600))..repeat();
  final _rnd = math.Random(7);
  late final List<List<double>> _p = List.generate(
      46,
          (_) => [
        _rnd.nextDouble(),
        _rnd.nextDouble(),
        (_rnd.nextDouble() - .5) * .012,
        (_rnd.nextDouble() - .5) * .012,
        1 + _rnd.nextDouble() * 2.2
      ]);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => CustomPaint(painter: _ParticlePainter(_p, _c.value * 600)),
  );
}

class _ParticlePainter extends CustomPainter {
  final List<List<double>> p;
  final double t;
  _ParticlePainter(this.p, this.t);
  @override
  void paint(Canvas c, Size s) {
    final pts = [
      for (final q in p) Offset(((q[0] + q[2] * t) % 1.0) * s.width, ((q[1] + q[3] * t) % 1.0) * s.height)
    ];
    final line = Paint()..strokeWidth = 1;
    for (int i = 0; i < pts.length; i++) {
      for (int j = i + 1; j < pts.length; j++) {
        final d = (pts[i] - pts[j]).distance;
        if (d < 130) {
          line.color = C.teal2.withOpacity((1 - d / 130) * .35);
          c.drawLine(pts[i], pts[j], line);
        }
      }
    }
    for (int i = 0; i < pts.length; i++) {
      c.drawCircle(pts[i], p[i][4] * 1.4, Paint()..color = Colors.white.withOpacity(.55));
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

class _Piece {
  final double angle, speed, size, spin;
  final Color color;
  final bool round;
  _Piece(this.angle, this.speed, this.size, this.spin, this.color, this.round);
}

/// Explosion de confettis à l'ouverture de l'écran de résultat
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key});
  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 4200))..forward();
  final _rnd = math.Random(3);
  late final List<_Piece> _p = List.generate(
      120,
          (_) => _Piece(
        -math.pi / 2 + (_rnd.nextDouble() - .5) * 2.6,
        380 + _rnd.nextDouble() * 560,
        6 + _rnd.nextDouble() * 7,
        (_rnd.nextDouble() - .5) * 14,
        [C.teal, C.teal2, C.amber, C.navy2, const Color(0xFFFF8A65), const Color(0xFF7C9CFF)][_rnd.nextInt(6)],
        _rnd.nextBool(),
      ));
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => CustomPaint(size: Size.infinite, painter: _ConfettiPainter(_p, _c.value * 4.2)),
  );
}

class _ConfettiPainter extends CustomPainter {
  final List<_Piece> ps;
  final double t;
  _ConfettiPainter(this.ps, this.t);
  @override
  void paint(Canvas c, Size s) {
    final ox = s.width / 2, oy = s.height * .26;
    final fade = (1 - (t - 2.8) / 1.4).clamp(0.0, 1.0);
    for (final p in ps) {
      final d = p.speed * (1 - math.exp(-2.5 * t)) / 2.5;
      final x = ox + math.cos(p.angle) * d;
      final y = oy + math.sin(p.angle) * d + 260 * t * t;
      c.save();
      c.translate(x, y);
      c.rotate(p.spin * t);
      final paint = Paint()..color = p.color.withOpacity(fade);
      if (p.round) {
        c.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        c.drawRRect(
            RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * .5), const Radius.circular(2)),
            paint);
      }
      c.restore();
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

/// Texte tapé lettre par lettre avec curseur
class Typewriter extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int delayMs;
  const Typewriter(this.text, {super.key, required this.style, this.delayMs = 400});
  @override
  Widget build(BuildContext context) {
    final total = delayMs + text.length * 42;
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: text.length),
      duration: Duration(milliseconds: total),
      curve: Interval(delayMs / total, 1),
      builder: (_, v, __) => Stack(children: [
        Text(text, style: style.copyWith(color: Colors.transparent)),
        Text(text.substring(0, v) + (v < text.length ? '▌' : ''), style: style),
      ]),
    );
  }
}

/// Rayons lumineux qui tournent derrière le badge de réussite
class GlowBadge extends StatefulWidget {
  final Widget child;
  const GlowBadge({super.key, required this.child});
  @override
  State<GlowBadge> createState() => _GlowBadgeState();
}

class _GlowBadgeState extends State<GlowBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = C.teal2.withOpacity(.38), b = C.teal.withOpacity(.0);
    return SizedBox(
      height: 96,
      child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
        IgnorePointer(
          child: OverflowBox(
            maxWidth: 360,
            maxHeight: 360,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (r) =>
                  const RadialGradient(colors: [Colors.white, Colors.transparent], stops: [.2, 1]).createShader(r),
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, __) => Transform.rotate(
                  angle: _c.value * 2 * math.pi,
                  child: Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(colors: [b, a, b, a, b, a, b, a, b])),
                  ),
                ),
              ),
            ),
          ),
        ),
        widget.child,
      ]),
    );
  }
}
