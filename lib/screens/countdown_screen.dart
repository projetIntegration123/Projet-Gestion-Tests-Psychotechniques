import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../core/routes.dart';
import '../widgets/widgets.dart';
import 'test_screen.dart';
import '../services/api_service.dart';

class CountdownScreen extends StatefulWidget {
  final CandidateSession session;
  final ApiService api;
  const CountdownScreen({super.key, required this.session, required this.api});
  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  int n = 3;
  Timer? t;
  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    t = Timer.periodic(const Duration(seconds: 1), (tm) {
      setState(() => n--);
      HapticFeedback.lightImpact();
      if (n == 0) {
        tm.cancel();
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) Navigator.pushReplacement(context, fadeRoute(TestScreen(session: widget.session, api: widget.api)));
        });
      }
    });
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: gradNavy),
      child: Stack(children: [
        const Positioned.fill(child: ParticleField()),
        Center(child: blob(800, C.teal2, .28)),
        Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Eyebrow('Préparez-vous', color: C.teal2),
            const SizedBox(height: 28),
            SizedBox(
              width: 280,
              height: 280,
              child: Stack(alignment: Alignment.center, children: [
                TweenAnimationBuilder<double>(
                  key: ValueKey(n),
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1000),
                  builder: (_, v, __) => CustomPaint(
                      size: const Size(280, 280),
                      painter: RingPainter(n == 0 ? 1 : v,
                          stroke: 8, colors: const [C.teal2, Colors.white], track: Colors.white12)),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (c, a) => FadeTransition(
                      opacity: a,
                      child: ScaleTransition(
                          scale: Tween(begin: .4, end: 1.0)
                              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
                          child: c)),
                  child: Text(n > 0 ? '$n' : 'GO',
                      key: ValueKey(n),
                      style: const TextStyle(
                          fontSize: 112, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
                ),
              ]),
            ),
            const SizedBox(height: 32),
            Text(n > 0 ? 'Le chronomètre démarre dans $n…' : 'Bonne chance !',
                style: const TextStyle(fontSize: 15, color: Colors.white70)),
          ]),
        ),
      ]),
    ),
  );
}
