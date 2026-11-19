import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/routes.dart';
import '../widgets/widgets.dart';
import 'intro_screen.dart';
import 'test_screen.dart';
import 'result_screen.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final keyController = TextEditingController();
  final api = ApiService();
  bool loading = false;
  String? errorMessage;

  Future<void> _connect() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() { loading = true; errorMessage = null; });
    if (keyController.text.trim().isEmpty) {
      setState(() { loading = false; errorMessage = 'Saisissez votre clé candidat.'; });
      return;
    }
    try {
      final session = await api.access(keyController.text);
      if (!mounted) return;
      // Le serveur indique où en est le candidat : on reprend au bon écran.
      switch (session.status) {
        case 'termine':
          final r = await api.result();
          if (mounted) Navigator.push(context, fadeRoute(ResultScreen(result: r)));
        case 'en_cours':
          Navigator.push(context, fadeRoute(TestScreen(session: session, api: api)));
        default:
          Navigator.push(context, fadeRoute(IntroScreen(session: session, api: api)));
      }
    } on ApiException catch (error) {
      if (mounted) setState(() => errorMessage = error.message);
    } catch (_) {
      if (mounted) setState(() => errorMessage = 'Une erreur est survenue. Réessayez.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() { keyController.dispose(); super.dispose(); }

  Widget _feature(IconData i, String t) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(i, size: 16, color: C.teal2),
      ),
      const SizedBox(width: 12),
      Text(t, style: const TextStyle(color: Colors.white70, fontSize: 13)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 860;
    return Scaffold(
      body: Row(children: [
        if (wide)
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(gradient: gradNavy),
              child: Stack(children: [
                const Positioned.fill(child: ParticleField()),
                Positioned(
                    bottom: -120,
                    right: -120,
                    child: Container(
                      width: 420,
                      height: 420,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [C.teal2.withOpacity(.45), C.teal2.withOpacity(0)])),
                    )),
                Padding(
                  padding: const EdgeInsets.all(44),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Logo(light: true, size: 18),
                    const Spacer(),
                    Reveal(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.1), borderRadius: BorderRadius.circular(20)),
                        child: const Text('ESPACE CANDIDAT',
                            style: TextStyle(color: C.teal2, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Reveal(
                      delay: 120,
                      child: Typewriter('Plateforme de gestion\ndes tests\npsychotechniques',
                          style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800, height: 1.15)),
                    ),
                    const SizedBox(height: 28),
                    Reveal(delay: 260, child: _feature(Icons.lock_rounded, 'Accès individuel et sécurisé')),
                    Reveal(delay: 340, child: _feature(Icons.timer_rounded, 'Chronomètre intégré et suivi en direct')),
                    Reveal(delay: 420, child: _feature(Icons.insights_rounded, 'Résultats consultables immédiatement')),
                    const Spacer(),
                    const Text('© PsyTech Pro', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ]),
                ),
              ]),
            ),
          ),
        Expanded(
          flex: 5,
          child: AppBg(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Reveal(
                    child: AppCard(
                      tilt: true,
                      padding: const EdgeInsets.all(34),
                      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Logo(size: 18),
                        const SizedBox(height: 30),
                        const Text('Accéder à mon espace candidat',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: C.navy, height: 1.2)),
                        const SizedBox(height: 10),
                        const Text('Saisissez votre clé candidat pour accéder à votre évaluation psychotechnique.',
                            style: TextStyle(fontSize: 13, color: C.muted, height: 1.5)),
                        const SizedBox(height: 26),
                        const Text('Clé candidat',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: C.navy)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: keyController,
                          textCapitalization: TextCapitalization.characters,
                          autocorrect: false,
                          onSubmitted: (_) => loading ? null : _connect(),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1),
                          decoration: InputDecoration(
                            hintText: 'Ex. : PSY-XXXXXX',
                            hintStyle: const TextStyle(color: Colors.black26, fontSize: 14, letterSpacing: 0),
                            prefixIcon: const Icon(Icons.vpn_key_rounded, size: 18, color: C.muted),
                            filled: true,
                            fillColor: C.bg,
                            contentPadding: const EdgeInsets.symmetric(vertical: 17),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.border)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.teal, width: 2)),
                          ),
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(errorMessage!, style: const TextStyle(color: C.red, fontSize: 12)),
                        ],
                        const SizedBox(height: 18),
                        GradBtn('Se connecter',
                            icon: Icons.arrow_forward_rounded,
                            expand: true,
                            onPressed: loading ? null : _connect),
                        const SizedBox(height: 20),
                        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.verified_user_outlined, size: 14, color: C.muted),
                          SizedBox(width: 6),
                          Text('Un accès individuel et sécurisé à votre évaluation.',
                              style: TextStyle(fontSize: 11, color: C.muted)),
                        ]),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
