import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/login_screen.dart';

void main() => runApp(const PsyTechApp());

class PsyTechApp extends StatelessWidget {
  const PsyTechApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'PsyTech Pro',
    theme: ThemeData(
      scaffoldBackgroundColor: C.bg,
      colorScheme: ColorScheme.fromSeed(seedColor: C.teal),
      useMaterial3: true,
    ),
    home: const LoginScreen(),
  );
}
