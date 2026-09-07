import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_inline_message_surface.dart';
import 'package:catch_ui/src/components/catch_text_button.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

/// Persistent inline error feedback with caller-resolved copy.
class CatchErrorBanner extends StatelessWidget {
  const CatchErrorBanner({super.key, required this.message})
    : onRetry = null,
      retryLabel = null;

  /// A retry-capable recipe requires its caller-owned label even when the
  /// callback is temporarily absent. No app localization is read here.
  const CatchErrorBanner.withRetry({
    super.key,
    required this.message,
    required String this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

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
            label: retryLabel!,
            onPressed: onRetry,
            foregroundColor: colorScheme.error,
            minimumSize: const Size(CatchSpacing.s0, CatchSpacing.s8),
            padding: EdgeInsets.zero,
          ),
      ],
    );
  }
}
