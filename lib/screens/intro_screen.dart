import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/routes.dart';
import '../widgets/widgets.dart';
import 'countdown_screen.dart';
import '../services/api_service.dart';

class IntroScreen extends StatelessWidget {
  final CandidateSession session;
  final ApiService api;
  const IntroScreen({super.key, required this.session, required this.api});

  Widget _stat(IconData icon, String label, String value) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: C.bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.border)),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(gradient: gradTeal, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11, color: C.muted)),
            Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: C.navy)),
          ]),
        ),
      ]),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const TopBar(),
    body: AppBg(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Reveal(child: Eyebrow('Avant de commencer')),
              const SizedBox(height: 8),
              Reveal(
                  delay: 80,
                  child: Text(session.candidateName.isEmpty ? 'Votre évaluation' : 'Bonjour ${session.candidateName}',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: C.navy))),
              const SizedBox(height: 8),
              const Reveal(
                  delay: 140,
                  child: Text('Prenez un instant pour découvrir le test avant de le démarrer.',
                      style: TextStyle(fontSize: 14, color: C.muted))),
              const SizedBox(height: 26),
              Reveal(
                delay: 220,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: C.border.withOpacity(.7)),
                      boxShadow: softShadow(.08)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: const BoxDecoration(gradient: gradNavy),
                      child: Stack(children: [
                        const Positioned.fill(child: ParticleField()),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Eyebrow('Test psychotechnique', color: C.teal2),
                          const SizedBox(height: 10),
                          Text(session.title,
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 10),
                          if (session.description.isNotEmpty)
                          Text(
                              session.description,
                              style: const TextStyle(fontSize: 13.5, color: Colors.white70, height: 1.55)),
                        ]),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(26),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          _stat(Icons.schedule_rounded, 'Durée du test', '${session.durationMin} minutes'),
                          const SizedBox(width: 12),
                          _stat(Icons.checklist_rounded, 'Questions', '${session.questionCount} questions'),
                        ]),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: C.tealLight.withOpacity(.6),
                              borderRadius: BorderRadius.circular(14),
                              border: const Border(left: BorderSide(color: C.teal, width: 4))),
                          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('À savoir avant de démarrer',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: C.navy)),
                            SizedBox(height: 6),
                            Text(
                                'Une seule réponse est possible par question. Vous pouvez revenir aux questions précédentes avant de soumettre le test. Le chronomètre est géré par le serveur : il démarre dès que vous commencez et le test est soumis automatiquement à la fin du temps. Vos réponses sont enregistrées au fur et à mesure.',
                                style: TextStyle(fontSize: 12.5, color: C.muted, height: 1.55)),
                          ]),
                        ),
                        const SizedBox(height: 24),
                        Row(children: [
                          const Expanded(
                              child: Text('Installez-vous au calme,\npuis lancez-vous.',
                                  style: TextStyle(fontSize: 12, color: C.muted, height: 1.4))),
                          GradBtn('Démarrer le test',
                              icon: Icons.arrow_forward_rounded,
                              onPressed: () => Navigator.pushReplacement(context, fadeRoute(CountdownScreen(session: session, api: api)))),
                        ]),
                      ]),
                    ),
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
