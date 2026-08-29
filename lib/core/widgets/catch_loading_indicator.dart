import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchLoadingIndicator extends StatelessWidget {
  const CatchLoadingIndicator({
    super.key,
    this.strokeWidth = CatchStroke.progressIndicator,
    this.color,
  });

  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(strokeWidth: strokeWidth, color: color),
    );
  }
}
