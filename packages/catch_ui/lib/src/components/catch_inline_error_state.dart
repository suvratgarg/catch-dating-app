import 'package:catch_ui/src/components/catch_error_body.dart';
import 'package:catch_ui/src/components/catch_error_state_mode.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:flutter/material.dart';

class CatchInlineErrorState extends StatelessWidget {
  const CatchInlineErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel,
    this.secondaryAction,
    this.icon = CatchIcons.errorOutlineRounded,
    this.compact = false,
  }) : assert(
         onRetry == null || retryLabel != null,
         'CatchInlineErrorState requires retryLabel when onRetry is provided.',
       );

  final String title;
  final String message;
  final VoidCallback? onRetry;

  /// Caller-resolved label, required when [onRetry] is supplied.
  final String? retryLabel;
  final Widget? secondaryAction;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return CatchErrorBody(
      title: title,
      message: message,
      icon: icon,
      onRetry: onRetry,
      retryLabel: retryLabel,
      secondaryAction: secondaryAction,
      mode: compact ? CatchErrorStateMode.compact : CatchErrorStateMode.inline,
    );
  }
}
