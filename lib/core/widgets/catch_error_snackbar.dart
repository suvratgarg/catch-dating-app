import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
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

/// Visual tone for non-error confirmation snackbars.
enum CatchSnackBarTone { success, info, warning }

/// Shows a tone-styled confirmation snackbar (success / info / warning).
///
/// Use this instead of constructing a raw [SnackBar] so confirmation messaging
/// stays consistent with the design system. The dark default snackbar surface
/// is kept for guaranteed contrast; the tone is conveyed by a leading colored
/// icon rather than re-tinting the whole bar.
void showCatchSnackBar(
  BuildContext context,
  String message, {
  CatchSnackBarTone tone = CatchSnackBarTone.info,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final t = CatchTokens.of(context);
  final (IconData icon, Color iconColor) = switch (tone) {
    CatchSnackBarTone.success => (CatchIcons.checkCircleRounded, t.success),
    CatchSnackBarTone.warning => (CatchIcons.warningAmberRounded, t.warning),
    CatchSnackBarTone.info => (CatchIcons.infoOutlineRounded, t.accent),
  };
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: CatchTextStyles.labelL(context, color: t.bg),
            ),
          ),
        ],
      ),
      action: actionLabel != null && onAction != null
          ? SnackBarAction(label: actionLabel, onPressed: onAction)
          : null,
    ),
  );
}

/// Convenience wrapper for a success-toned confirmation snackbar.
void showCatchSuccessSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) => showCatchSnackBar(
  context,
  message,
  tone: CatchSnackBarTone.success,
  actionLabel: actionLabel,
  onAction: onAction,
);

/// Convenience wrapper for an informational snackbar.
void showCatchInfoSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) => showCatchSnackBar(
  context,
  message,
  tone: CatchSnackBarTone.info,
  actionLabel: actionLabel,
  onAction: onAction,
);

/// Convenience wrapper for a warning-toned snackbar.
void showCatchWarningSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) => showCatchSnackBar(
  context,
  message,
  tone: CatchSnackBarTone.warning,
  actionLabel: actionLabel,
  onAction: onAction,
);
