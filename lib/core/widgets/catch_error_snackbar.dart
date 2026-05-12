import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:flutter/material.dart';

void showCatchErrorSnackBar(
  BuildContext context,
  Object error, {
  AppErrorContext errorContext = AppErrorContext.generic,
  VoidCallback? onRetry,
}) {
  final descriptor = appErrorDescriptor(error, context: errorContext);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(descriptor.message),
      action: onRetry != null && descriptor.retryable
          ? SnackBarAction(label: descriptor.retryLabel, onPressed: onRetry)
          : null,
    ),
  );
}
