import 'package:flutter/material.dart';

/// SafePrevent brand lockup: shield mark + wordmark, sized for headers.
class BrandHeader extends StatelessWidget {
  final double markSize;
  final double fontSize;

  const BrandHeader({super.key, this.markSize = 84, this.fontSize = 42});

  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    Image.asset('assets/safeprevent_mark.png',
        width: markSize, height: markSize, filterQuality: FilterQuality.medium),
    const SizedBox(width: 18),
    RichText(textScaler: TextScaler.noScaling, text: TextSpan(children: [
      TextSpan(text: 'Safe', style: TextStyle(
          fontSize: fontSize, fontWeight: FontWeight.w800,
          color: Colors.white, letterSpacing: -0.5)),
      TextSpan(text: 'Prevent', style: TextStyle(
          fontSize: fontSize, fontWeight: FontWeight.w300,
          color: const Color(0xff1fddb9), letterSpacing: -0.5)),
    ])),
  ]);
}
