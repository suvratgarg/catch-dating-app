import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_button.dart';
import 'package:flutter/material.dart';

class CatchTopBarTextAction extends StatelessWidget {
  const CatchTopBarTextAction({
    super.key,
    required this.label,
    this.onPressed,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchButton.text(
      label: label,
      onPressed: onPressed,
      foregroundColor: foregroundColor ?? t.primary,
    );
  }
}
