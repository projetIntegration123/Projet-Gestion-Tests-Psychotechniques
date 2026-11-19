import 'package:flutter/material.dart';
import '../core/theme.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final bool tilt;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(28), this.tilt = false});
  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  Offset o = Offset.zero;
  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(1.4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, C.teal2.withOpacity(.45), C.border, Colors.white]),
        boxShadow: [
          ...softShadow(.08),
          BoxShadow(color: C.teal.withOpacity(.06), blurRadius: 60, offset: const Offset(0, 20)),
        ],
      ),
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22.6)),
        child: widget.child,
      ),
    );
    if (!widget.tilt) return card;
    return MouseRegion(
      onHover: (e) {
        final s = (context.findRenderObject() as RenderBox).size;
        setState(() => o = Offset(e.localPosition.dx / s.width - .5, e.localPosition.dy / s.height - .5));
      },
      onExit: (_) => setState(() => o = Offset.zero),
      child: TweenAnimationBuilder<Offset>(
        tween: Tween(end: o),
        duration: const Duration(milliseconds: 180),
        builder: (_, v, c) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, .0012)
            ..rotateX(-v.dy * .1)
            ..rotateY(v.dx * .1),
          child: c,
        ),
        child: card,
      ),
    );
  }
}
