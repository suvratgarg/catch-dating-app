import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
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

void showCatchErrorSnackBar(
  BuildContext context,
  Object error, {
  AppErrorContext errorContext = AppErrorContext.generic,
  VoidCallback? onRetry,
}) {
  final descriptor = appErrorDescriptor(
    error,
    l10n: context.l10n,
    context: errorContext,
  );
  showCatchSnackBar(
    context,
    descriptor.message,
    action: onRetry != null && descriptor.retryable
        ? SnackBarAction(label: descriptor.retryLabel, onPressed: onRetry)
        : null,
  );
}
