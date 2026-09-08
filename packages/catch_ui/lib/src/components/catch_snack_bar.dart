import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

void showCatchSnackBar(
  BuildContext context,
  String message, {
  SnackBarAction? action,
}) {
  final t = CatchTokens.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: t.ink,
      content: Text(
        message,
        style: CatchTextStyles.labelL(context, color: t.bg),
      ),
      action: action,
    ),
  );
}
