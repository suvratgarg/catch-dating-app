import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchMetricStripDivider extends StatelessWidget {
  const CatchMetricStripDivider({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: CatchStroke.hairline,
      height: CatchSpacing.s9,
      color: color ?? CatchTokens.of(context).line,
    );
  }
}
