import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

void showCatchErrorSnackBar(
  BuildContext context,
  Object error, {
  AppErrorContext errorContext = AppErrorContext.generic,
  VoidCallback? onRetry,
}) {
  final descriptor = appErrorDescriptor(error, context: errorContext);
  final t = CatchTokens.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        descriptor.message,
        style: CatchTextStyles.labelL(context, color: t.bg),
      ),
      action: onRetry != null && descriptor.retryable
          ? SnackBarAction(label: descriptor.retryLabel, onPressed: onRetry)
          : null,
    ),
  );
}
