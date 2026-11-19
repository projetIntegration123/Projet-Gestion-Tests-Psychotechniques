import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'logo.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(68);
  @override
  Widget build(BuildContext context) => ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(.85),
            border: const Border(bottom: BorderSide(color: C.border))),
        child: Row(children: [
          const Logo(size: 18),
          const SizedBox(width: 16),
          if (MediaQuery.of(context).size.width > 600) ...[
            Container(width: 1, height: 20, color: C.border),
            const SizedBox(width: 16),
            const Text('Tests psychotechniques', style: TextStyle(fontSize: 12, color: C.muted)),
          ],
          const Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
            decoration: BoxDecoration(
                color: C.bg, borderRadius: BorderRadius.circular(30), border: Border.all(color: C.border)),
            child: Row(children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(gradient: gradTeal, shape: BoxShape.circle),
                child: const Icon(Icons.person_rounded, size: 15, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text('Espace candidat',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: C.navy)),
            ]),
          ),
        ]),
      ),
    ),
  );
}
