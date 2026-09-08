import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';

/// Persistent inline error banner for a Riverpod mutation.
///
/// This keeps the repeated `if (mutation.hasError) CatchErrorBanner(...)`
/// pattern in one place while preserving the distinction between persistent
/// inline mutation errors and transient snackbar errors.
class CatchMutationErrorBanner extends StatelessWidget {
  const CatchMutationErrorBanner({
    super.key,
    required this.mutation,
    this.errorContext = AppErrorContext.generic,
    this.onRetry,
  });

  final MutationState<dynamic> mutation;
  final AppErrorContext errorContext;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (!mutation.hasError) return const SizedBox.shrink();
    return CatchLocalizedErrorBanner(
      (mutation as MutationError).error,
      context: errorContext,
      onRetry: onRetry,
    );
  }
}
