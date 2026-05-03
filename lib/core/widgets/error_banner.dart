import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// A styled inline error banner for displaying mutation or async errors.
///
/// Use [ErrorBanner] for errors that appear within existing page content
/// (below a form, above a footer). For transient errors from bottom sheets
/// or non-blocking actions, prefer [RunMutationSnackbarListener].
///
/// An optional [onRetry] callback adds a "Try again" button to the banner.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          CatchSpacing.s4,
          8,
          CatchSpacing.s4,
          0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withAlpha(120),
          borderRadius: BorderRadius.circular(CatchRadius.md),
          border: Border.all(
            color: colorScheme.error.withAlpha(60),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 16,
              color: colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: CatchTextStyles.bodyS(context, color: colorScheme.error),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Try again',
                  style: CatchTextStyles.bodyS(
                    context,
                    color: colorScheme.error,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
