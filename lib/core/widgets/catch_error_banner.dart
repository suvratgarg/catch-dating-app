import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/src/catch_inline_message_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';

/// A styled inline error banner for displaying mutation or async errors.
///
/// Use [CatchErrorBanner] for errors that appear within existing page content
/// (below a form, above a footer). For transient errors from bottom sheets
/// or non-blocking actions, prefer [CatchMutationErrorListener].
///
/// An optional [onRetry] callback adds a "Try again" button to the banner.
class CatchErrorBanner extends StatelessWidget {
  const CatchErrorBanner({super.key, required this.message, this.onRetry});

  factory CatchErrorBanner.fromError(
    Object error, {
    Key? key,
    AppErrorContext context = AppErrorContext.generic,
    VoidCallback? onRetry,
  }) {
    final descriptor = appErrorDescriptor(error, context: context);
    return CatchErrorBanner(
      key: key,
      message: descriptor.message,
      onRetry: descriptor.retryable ? onRetry : null,
    );
  }

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CatchInlineMessageSurface(
      message: message,
      icon: CatchIcons.errorOutlineRounded,
      iconColor: colorScheme.error,
      iconSize: CatchIcon.xs,
      iconTopPadding: CatchSpacing.s0,
      outerColor: colorScheme.surface,
      margin: const EdgeInsets.fromLTRB(
        CatchSpacing.s4,
        CatchSpacing.s2,
        CatchSpacing.s4,
        CatchSpacing.s0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s3,
        vertical: CatchSpacing.micro10,
      ),
      backgroundColor: colorScheme.errorContainer.withValues(
        alpha: CatchOpacity.errorContainerFill,
      ),
      borderColor: colorScheme.error.withValues(
        alpha: CatchOpacity.errorContainerBorder,
      ),
      messageStyle: CatchTextStyles.supporting(
        context,
        color: colorScheme.error,
      ),
      actions: [
        if (onRetry != null)
          CatchTextButton(
            label: 'Try again',
            onPressed: onRetry,
            foregroundColor: colorScheme.error,
            minimumSize: const Size(CatchSpacing.s0, CatchSpacing.s8),
            padding: EdgeInsets.zero,
          ),
      ],
    );
  }
}

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
    return CatchErrorBanner.fromError(
      (mutation as MutationError).error,
      context: errorContext,
      onRetry: onRetry,
    );
  }
}
