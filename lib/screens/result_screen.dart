import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/widgets.dart';
import '../services/api_service.dart';

class ResultScreen extends StatelessWidget {
  final TestResult result;
  final int? answered, total; // connus seulement juste après la soumission
  const ResultScreen({super.key, required this.result, this.answered, this.total});

  Widget _mini(Color c, String v, String l) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.border)),
      child: Column(children: [
        Text(v, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: c)),
        const SizedBox(height: 2),
        Text(l, style: const TextStyle(fontSize: 10.5, color: C.muted)),
      ]),
    ),
  );

  Widget _scoreRing(int score, int max) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: score.toDouble()),
    duration: const Duration(milliseconds: 1800),
    curve: Curves.easeOutCubic,
    builder: (_, v, __) => SizedBox(
      width: 200,
      height: 200,
      child: Stack(alignment: Alignment.center, children: [
        CustomPaint(size: const Size(200, 200), painter: RingPainter(max == 0 ? 0 : v / max, stroke: 16)),
        Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Votre score final', style: TextStyle(fontSize: 11, color: C.muted)),
          Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                ShaderMask(
                  shaderCallback: (r) => gradTeal.createShader(r),
                  child: Text('${v.round()}',
                      style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
                ),
                Text(' / $max', style: const TextStyle(fontSize: 20, color: C.teal)),
              ]),
          const Text('points', style: TextStyle(fontSize: 11, color: C.muted)),
        ]),
      ]),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const TopBar(),
    body: AppBg(
      overlay: const ConfettiBurst(),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(children: [
              GlowBadge(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.elasticOut,
                  builder: (_, v, c) => Transform.scale(scale: v, child: c),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                        gradient: gradTeal,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: C.teal.withOpacity(.4), blurRadius: 30, spreadRadius: 4)]),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 34),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Reveal(
                  delay: 150,
                  child: Text('Votre test est terminé.',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: C.navy))),
              const SizedBox(height: 10),
              Reveal(
                delay: 230,
                child: Text(result.scoreVisible
                    ? 'Vos réponses ont bien été soumises. Vous pouvez maintenant consulter votre score final.'
                    : 'Vos réponses ont bien été soumises. Un email de confirmation vous a été envoyé : l’entreprise reviendra vers vous.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: C.muted, height: 1.55)),
              ),
              const SizedBox(height: 28),
              Reveal(
                delay: 320,
                child: AppCard(
                  tilt: true,
                  padding: const EdgeInsets.all(26),
                  child: Column(children: [
                    const Eyebrow('Résultat de votre évaluation'),
                    const SizedBox(height: 8),
                    Text(result.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: C.navy)),
                    const SizedBox(height: 22),
                    if (result.scoreVisible && result.score != null && result.scoreMax != null)
                      _scoreRing(result.score!, result.scoreMax!)
                    else
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(color: C.bg, shape: BoxShape.circle, border: Border.all(color: C.border)),
                        child: const Icon(Icons.lock_outline_rounded, size: 52, color: C.muted),
                      ),
                    if (answered != null && total != null) ...[
                      const SizedBox(height: 22),
                      Row(children: [
                        _mini(C.teal, '$answered', 'Répondues'),
                        const SizedBox(width: 10),
                        _mini(C.muted, '${total! - answered!}', 'Sans réponse'),
                      ]),
                    ],
                    const SizedBox(height: 18),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(result.scoreVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 14, color: C.muted),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                            result.scoreVisible
                                ? 'La consultation de votre score est autorisée.'
                                : 'L’entreprise n’a pas activé l’affichage du score.',
                            style: const TextStyle(fontSize: 11, color: C.muted)),
                      ),
                    ]),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    ),
  );
}
