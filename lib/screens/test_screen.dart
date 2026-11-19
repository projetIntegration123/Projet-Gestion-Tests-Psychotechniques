import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../core/routes.dart';
import '../models/question.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';
import 'submit_dialog.dart';
import 'result_screen.dart';

class TestScreen extends StatefulWidget {
  final CandidateSession session;
  final ApiService api;
  const TestScreen({super.key, required this.session, required this.api});
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int totalSeconds = 1;
  int remaining = 0;
  String title = '';
  List<Question> questions = [];
  bool loading = true;
  bool submitting = false;
  String? loadError;
  int current = 0;
  final Map<int, int> answers = {};
  Timer? timer;
  DateTime? deadline; // échéance calculée depuis `resteSecondes` du serveur
  Future<void> _saveQueue = Future.value(); // enregistre les réponses dans l'ordre

  @override
  void initState() {
    super.initState();
    title = widget.session.title;
    totalSeconds = widget.session.durationMin * 60;
    remaining = totalSeconds;
    _loadQuestions();
  }

  void _toLogin(String message) {
    timer?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _loadQuestions() async {
    setState(() { loading = true; loadError = null; });
    try {
      // /demarrer lance le chrono une seule fois ; rappelé, il reprend le test en cours.
      final c = await widget.api.start();
      if (!mounted) return;
      deadline = DateTime.now().add(Duration(seconds: c.remainingSeconds));
      setState(() {
        title = c.title.isNotEmpty ? c.title : title;
        questions = c.questions;
        answers..clear()..addAll(c.answers);
        totalSeconds = c.durationMinutes * 60;
        remaining = c.remainingSeconds;
        loading = false;
      });
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.status == 401) return _toLogin('Session expirée, reconnectez-vous.');
      if (e.status == 409 || e.status == 410) {
        // test déjà terminé / temps écoulé : on affiche le résultat s'il existe
        try {
          final r = await widget.api.result();
          if (mounted) Navigator.pushReplacement(context, fadeRoute(ResultScreen(result: r)));
          return;
        } catch (_) {}
      }
      setState(() { loading = false; loadError = e.message; });
    }
  }

  void _tick() {
    if (deadline == null || !mounted) return;
    final left = deadline!.difference(DateTime.now()).inSeconds;
    setState(() => remaining = left < 0 ? 0 : left);
    if (left <= 0) _finish();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  /// Sélection d'une réponse : affichage immédiat, puis envoi au serveur (PUT).
  void _answer(int qIndex, int choice) {
    final q = questions[qIndex];
    final previous = answers[qIndex];
    setState(() => answers[qIndex] = choice);
    _saveQueue = _saveQueue.then((_) async {
      try {
        await widget.api.saveAnswer(q.id, choice);
      } on ApiException catch (e) {
        if (!mounted) return;
        if (e.status == 401) return _toLogin('Session expirée, reconnectez-vous.');
        if (e.status == 409 || e.status == 410) return _finish(); // temps écoulé côté serveur
        // échec réseau : on annule l'affichage pour ne pas laisser croire que c'est enregistré
        setState(() => previous == null ? answers.remove(qIndex) : answers[qIndex] = previous);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Réponse non enregistrée : ${e.message}')));
      }
    });
  }

  String get clock =>
      '${(remaining ~/ 60).toString().padLeft(2, '0')}:${(remaining % 60).toString().padLeft(2, '0')}';

  Future<void> _finish() async {
    if (submitting || questions.isEmpty) return;
    submitting = true;
    final answered = answers.length;
    try {
      await _saveQueue; // laisse partir la dernière réponse avant de corriger
      TestResult result;
      try {
        result = await widget.api.submit();
      } on ApiException catch (e) {
        // 409/410: le serveur a déjà clos le test (temps écoulé) -> on lit simplement le résultat
        if (e.status != 409 && e.status != 410) rethrow;
        result = await widget.api.result();
      }
      timer?.cancel();
      if (mounted) {
        Navigator.pushReplacement(
            context, fadeRoute(ResultScreen(result: result, answered: answered, total: questions.length)));
      }
    } on ApiException catch (e) {
      submitting = false;
      if (!mounted) return;
      if (e.status == 401) return _toLogin('Session expirée, reconnectez-vous.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Soumission impossible : ${e.message}')));
    }
  }

  Future<void> _confirmSubmit() async {
    final ok = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'fermer',
      barrierColor: C.navy.withOpacity(.45),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => SubmitDialog(answered: answers.length, total: questions.length, title: title),
      transitionBuilder: (_, a, __, child) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6 * a.value, sigmaY: 6 * a.value),
        child: FadeTransition(
          opacity: a,
          child: ScaleTransition(
              scale: Tween(begin: .9, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
              child: child),
        ),
      ),
    );
    if (ok == true) await _finish();
  }

  // ── Colonne latérale : chrono + navigateur ──
  Widget _sidebar() {
    final urgent = remaining < 300;
    return Column(children: [
      AppCard(
        padding: const EdgeInsets.all(22),
        child: Column(children: [
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(alignment: Alignment.center, children: [
              CustomPaint(
                  size: const Size(140, 140),
                  painter: RingPainter(totalSeconds == 0 ? 0 : remaining / totalSeconds,
                      stroke: 10, colors: urgent ? const [C.red, Color(0xFFFF8A65)] : const [C.teal, C.teal2])),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.timer_outlined, size: 16, color: urgent ? C.red : C.muted),
                const SizedBox(height: 2),
                Text(clock,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: urgent ? C.red : C.navy,
                        fontFeatures: const [FontFeature.tabularFigures()])),
                const Text('Temps restant', style: TextStyle(fontSize: 10.5, color: C.muted)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Text('${answers.length} / ${questions.length} répondues',
                style: const TextStyle(fontSize: 11.5, color: C.muted)),
            const Spacer(),
            Text('${(answers.length * 100 / questions.length).round()} %',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: C.teal)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: answers.length / questions.length),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                  value: v, minHeight: 8, backgroundColor: C.border, color: C.teal),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Navigation',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: C.navy)),
          const SizedBox(height: 14),
          Wrap(spacing: 7, runSpacing: 7, children: [
            for (int i = 0; i < questions.length; i++)
              GestureDetector(
                onTap: () => setState(() => current = i),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 31,
                    height: 31,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: i == current ? gradNavy : null,
                      color: i == current ? null : (answers.containsKey(i) ? C.tealLight : Colors.white),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                          color: i == current ? C.navy : (answers.containsKey(i) ? C.teal.withOpacity(.4) : C.border)),
                    ),
                    child: Text('${i + 1}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: i == current ? Colors.white : (answers.containsKey(i) ? C.teal : C.muted))),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 16),
          const Row(children: [
            _Legend(C.navy, 'Actuelle'),
            SizedBox(width: 14),
            _Legend(C.teal, 'Répondue'),
            SizedBox(width: 14),
            _Legend(C.border, 'Vide'),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      OutlineBtn('Soumettre le test', icon: Icons.send_rounded, expand: true, onPressed: _confirmSubmit),
    ]);
  }

  // ── Carte question ──
  Widget _questionCard() {
    final q = questions[current];
    final last = current == questions.length - 1;
    final picked = answers[current];
    return AppCard(
      padding: const EdgeInsets.all(26),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: C.tealLight, borderRadius: BorderRadius.circular(20)),
            child: Text('Question ${current + 1} sur ${questions.length}',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: C.teal)),
          ),
          const Spacer(),
          const Icon(Icons.touch_app_outlined, size: 14, color: C.muted),
          const SizedBox(width: 5),
          const Text('Une seule réponse possible', style: TextStyle(fontSize: 11.5, color: C.muted)),
        ]),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (c, a) => FadeTransition(
              opacity: a,
              child: SlideTransition(
                  position: Tween(begin: const Offset(.04, 0), end: Offset.zero).animate(a), child: c)),
          child: Column(
            key: ValueKey(current),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Text(q.text,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: C.navy)),
              if (q.sequence.isNotEmpty) ...[
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 12),
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [C.tealLight.withOpacity(.7), C.bg]),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: C.border)),
                child: Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, spacing: 10, runSpacing: 10, children: [
                  for (final n in q.sequence) ...[
                    Container(
                      width: 62,
                      height: 62,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: softShadow(.07)),
                      child: Text(n, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.navy)),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: C.muted),
                  ],
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 62,
                    height: 62,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        gradient: picked != null ? gradTeal : null,
                        color: picked != null ? null : C.tealLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: C.teal, width: 2),
                        boxShadow: [BoxShadow(color: C.teal.withOpacity(.3), blurRadius: 18)]),
                    child: Text(picked != null ? q.options[picked] : '?',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800, color: picked != null ? Colors.white : C.teal)),
                  ),
                ]),
              ),
              ],
              const SizedBox(height: 20),
              LayoutBuilder(builder: (_, box) {
                final w = box.maxWidth > 440 ? (box.maxWidth - 12) / 2 : box.maxWidth;
                return Wrap(spacing: 12, runSpacing: 12, children: [
                  for (int i = 0; i < q.options.length; i++)
                    SizedBox(
                      width: w,
                      child: OptionTile(
                        letter: String.fromCharCode(65 + i),
                        label: q.options[i],
                        selected: picked == i,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _answer(current, i);
                        },
                      ),
                    ),
                ]);
              }),
            ],
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(height: 1, color: C.border)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          OutlineBtn('Précédent',
              icon: Icons.arrow_back_rounded, onPressed: current > 0 ? () => setState(() => current--) : null),
          GradBtn(last ? 'Terminer' : 'Suivant',
              icon: last ? Icons.check_rounded : Icons.arrow_forward_rounded,
              onPressed: last ? _confirmSubmit : () => setState(() => current++)),
        ]),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (loadError != null || questions.isEmpty) {
      return Scaffold(
        appBar: const TopBar(),
        body: AppBg(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline_rounded, size: 44, color: C.red),
                const SizedBox(height: 14),
                Text(loadError ?? 'Ce test ne contient aucune question.',
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: C.navy)),
                const SizedBox(height: 18),
                GradBtn('Réessayer', icon: Icons.refresh_rounded, onPressed: _loadQuestions),
              ]),
            ),
          ),
        ),
      );
    }
    final wide = MediaQuery.of(context).size.width > 980;
    return Scaffold(
      appBar: const TopBar(),
      body: AppBg(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Eyebrow('Test en cours'),
                const SizedBox(height: 6),
                Text(title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: C.navy)),
                const SizedBox(height: 22),
                if (wide)
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Reveal(child: _questionCard())),
                    const SizedBox(width: 22),
                    SizedBox(width: 300, child: Reveal(delay: 120, child: _sidebar())),
                  ])
                else ...[
                  Reveal(child: _questionCard()),
                  const SizedBox(height: 18),
                  _sidebar(),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend(this.color, this.label);
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 9, height: 9, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 5),
    Text(label, style: const TextStyle(fontSize: 10.5, color: C.muted)),
  ]);
}

class OptionTile extends StatefulWidget {
  final String letter, label;
  final bool selected;
  final VoidCallback onTap;
  const OptionTile(
      {super.key, required this.letter, required this.label, required this.selected, required this.onTap});
  @override
  State<OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<OptionTile> {
  bool hover = false;
  @override
  Widget build(BuildContext context) {
    final s = widget.selected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, hover && !s ? -2 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: s ? C.tealLight : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: s ? C.teal : (hover ? C.teal.withOpacity(.4) : C.border), width: s ? 2 : 1.4),
            boxShadow: s
                ? [BoxShadow(color: C.teal.withOpacity(.22), blurRadius: 20, offset: const Offset(0, 8))]
                : (hover ? softShadow(.06) : null),
          ),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  gradient: s ? gradTeal : null, color: s ? null : C.bg, borderRadius: BorderRadius.circular(9)),
              child: Text(widget.letter,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: s ? Colors.white : C.muted)),
            ),
            const SizedBox(width: 14),
            Text(widget.label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: C.navy)),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: s
                  ? const Icon(Icons.check_circle_rounded, key: ValueKey(1), size: 22, color: C.teal)
                  : const Icon(Icons.circle_outlined, key: ValueKey(0), size: 22, color: C.border),
            ),
          ]),
        ),
      ),
    );
  }
}
