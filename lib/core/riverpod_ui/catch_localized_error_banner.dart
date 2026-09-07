import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Resolves app errors and retry copy at the caller's localization boundary.
class CatchLocalizedErrorBanner extends StatelessWidget {
  const CatchLocalizedErrorBanner(
    this.error, {
    super.key,
    AppErrorContext context = AppErrorContext.generic,
    this.onRetry,
  }) : errorContext = context;

  final Object error;
  final AppErrorContext errorContext;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final descriptor = appErrorDescriptor(
      error,
      l10n: context.l10n,
      context: errorContext,
    );
    return CatchErrorBanner.withRetry(
      message: descriptor.message,
      retryLabel: context.l10n.coreCatchErrorBannerLabelTryAgain,
      onRetry: descriptor.retryable ? onRetry : null,
    );
  }
}
