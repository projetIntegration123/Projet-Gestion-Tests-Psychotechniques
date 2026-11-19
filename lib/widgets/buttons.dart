import 'package:flutter/material.dart';
import '../core/theme.dart';

class GradBtn extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final bool expand;
  const GradBtn(this.label,
      {super.key, this.icon, this.onPressed, this.gradient = gradTeal, this.expand = false});
  @override
  State<GradBtn> createState() => _GradBtnState();
}

class _GradBtnState extends State<GradBtn> with SingleTickerProviderStateMixin {
  bool hover = false;
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.onPressed != null;
    return MouseRegion(
      cursor: on ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedScale(
        scale: hover && on ? 1.04 : 1,
        duration: const Duration(milliseconds: 160),
        child: Opacity(
          opacity: on ? 1 : .4,
          child: GestureDetector(
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.expand ? double.infinity : null,
              decoration: BoxDecoration(
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: on
                    ? [BoxShadow(color: C.teal.withOpacity(hover ? .5 : .3), blurRadius: hover ? 30 : 18, offset: const Offset(0, 8))]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                    child: Row(
                        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.label,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5)),
                          if (widget.icon != null) ...[
                            const SizedBox(width: 8),
                            Icon(widget.icon, size: 17, color: Colors.white)
                          ],
                        ]),
                  ),
                  if (on)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _c,
                          builder: (_, __) {
                            final x = -2 + 4 * _c.value;
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(x - .5, -.4),
                                  end: Alignment(x + .5, .4),
                                  colors: [
                                    Colors.white.withOpacity(0),
                                    Colors.white.withOpacity(.3),
                                    Colors.white.withOpacity(0)
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OutlineBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expand;
  const OutlineBtn(this.label, {super.key, this.icon, this.onPressed, this.expand = false});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: expand ? double.infinity : null,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: C.navy,
        backgroundColor: Colors.white,
        side: const BorderSide(color: C.border, width: 1.4),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 8)],
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
      ]),
    ),
  );
}
