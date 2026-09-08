import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

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
