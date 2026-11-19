import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/widgets.dart';

class SubmitDialog extends StatelessWidget {
  final int answered, total;
  final String title;
  const SubmitDialog({super.key, required this.answered, required this.total, required this.title});

  Widget _row(IconData i, Color c, String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Icon(i, size: 16, color: c),
      const SizedBox(width: 10),
      Text(l, style: const TextStyle(fontSize: 12.5, color: C.muted)),
      const Spacer(),
      Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: C.navy)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final missing = total - answered;
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                    gradient: gradTeal,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: C.teal.withOpacity(.35), blurRadius: 16, offset: const Offset(0, 6))]),
                child: const Icon(Icons.send_rounded, size: 22, color: Colors.white),
              ),
              const Spacer(),
              SizedBox(
                width: 62,
                height: 62,
                child: Stack(alignment: Alignment.center, children: [
                  CustomPaint(size: const Size(62, 62), painter: RingPainter(total == 0 ? 0 : answered / total, stroke: 6)),
                  Text('${total == 0 ? 0 : (answered * 100 / total).round()}%',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: C.navy)),
                ]),
              ),
            ]),
            const SizedBox(height: 20),
            const Text('Soumettre votre test ?',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: C.navy)),
            const SizedBox(height: 8),
            Text(
                'Après confirmation, vous ne pourrez plus modifier vos réponses au test « $title ».',
                style: TextStyle(fontSize: 13, color: C.muted, height: 1.5)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                  color: C.bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.border)),
              child: Column(children: [
                _row(Icons.check_circle_rounded, C.teal, 'Questions répondues', '$answered sur $total'),
                const Divider(height: 1, color: C.border),
                _row(Icons.radio_button_unchecked_rounded, missing > 0 ? C.amber : C.muted,
                    'Questions sans réponse', '$missing'),
              ]),
            ),
            if (missing > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: C.amber.withOpacity(.12), borderRadius: BorderRadius.circular(12)),
                child: const Row(children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: C.amber),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text('Certaines questions restent sans réponse.',
                          style: TextStyle(fontSize: 12, color: C.navy))),
                ]),
              ),
            ],
            const SizedBox(height: 22),
            Row(children: [
              Expanded(child: OutlineBtn('Revenir au test', onPressed: () => Navigator.pop(context, false))),
              const SizedBox(width: 12),
              Expanded(child: GradBtn('Confirmer', icon: Icons.check_rounded, onPressed: () => Navigator.pop(context, true))),
            ]),
          ]),
        ),
      ),
    );
  }
}
