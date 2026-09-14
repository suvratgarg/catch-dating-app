import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Subscribe during a Consumer build, in the branch that owns these actions.
///
/// Riverpod replaces build subscriptions and disposes them with the caller.
/// Mutation handles keep their scope keys; repeated handles subscribe once.
/// Only a pending-to-error transition publishes, so rebuilds never replay an
/// existing failure. Persistent errors use CatchLocalizedErrorBanner.mutation.
void listenToCatchMutationErrors(
  BuildContext context,
  WidgetRef ref, {
  required List<Mutation<dynamic>> mutations,
  AppErrorContext errorContext = AppErrorContext.generic,
}) {
  for (final mutation in mutations.toSet()) {
    ref.listen(mutation, (previous, current) {
      if (previous?.isPending == true && current is MutationError) {
        showCatchErrorSnackBar(
          context,
          current.error,
          errorContext: errorContext,
        );
      }
    });
  }
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
    // Explicit caller recovery is authoritative, as for persistent banners.
    action: onRetry != null
        ? SnackBarAction(label: descriptor.retryLabel, onPressed: onRetry)
        : null,
  );
}
