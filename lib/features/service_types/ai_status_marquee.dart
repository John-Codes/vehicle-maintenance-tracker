import 'package:flutter/material.dart';

/// Auto-scrolling pill text. When the text fits, it sits still; when it
/// overflows (small screens), it scrolls left with pauses at both ends so
/// nothing ever clips.
class AiStatusMarquee extends StatefulWidget {
  final String text;
  final TextStyle style;

  const AiStatusMarquee({super.key, required this.text, required this.style});
  @override
  State<AiStatusMarquee> createState() => _AiStatusMarqueeState();
}

class _AiStatusMarqueeState extends State<AiStatusMarquee>
    with SingleTickerProviderStateMixin {
  late final _scroll = AnimationController(
      vsync: this, duration: const Duration(seconds: 7))
    ..repeat();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  double _offset(double t, double overflow) {
    const pause = 0.18; // hold still at both ends so words stay readable
    if (t < pause) return 0;
    if (t > 1 - pause) return overflow;
    final k = (t - pause) / (1 - 2 * pause);
    return Curves.easeInOutQuad.transform(k) * overflow;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final painter = TextPainter(
            text: TextSpan(text: widget.text, style: widget.style),
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: double.infinity);
          final overflow = painter.width - constraints.maxWidth;
          final text = Text(widget.text, style: widget.style, maxLines: 1);
          if (overflow <= 0) return text;
          return ClipRect(
            child: AnimatedBuilder(
              animation: _scroll,
              builder: (context, child) => Transform.translate(
                offset: Offset(-_offset(_scroll.value, overflow), 0),
                child: text,
              ),
            ),
          );
        },
      );
}
