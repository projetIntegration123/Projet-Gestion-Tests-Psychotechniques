import 'package:flutter/material.dart';
import '../core/theme.dart';

class Logo extends StatelessWidget {
  final double size;
  final bool light;
  const Logo({super.key, this.size = 22, this.light = false});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
          gradient: light ? null : gradTeal,
          color: light ? Colors.white.withOpacity(.15) : null,
          borderRadius: BorderRadius.circular(10)),
      child: Icon(Icons.psychology_alt_rounded, color: Colors.white, size: size),
    ),
    const SizedBox(width: 10),
    Text('PsyTech',
        style: TextStyle(
            fontSize: size, fontWeight: FontWeight.w800, color: light ? Colors.white : C.navy)),
    Text(' Pro',
        style: TextStyle(
            fontSize: size, fontWeight: FontWeight.w300, color: light ? C.teal2 : C.teal)),
  ]);
}
