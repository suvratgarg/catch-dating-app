import 'package:catch_ui/src/components/catch_error_body.dart';
import 'package:catch_ui/src/components/catch_error_state_mode.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:flutter/material.dart';

class CatchErrorState extends StatelessWidget {
  const CatchErrorState({
    super.key,
    required this.title,
    required this.message,
    this.icon = CatchIcons.errorOutlineRounded,
    this.onRetry,
    this.retryLabel,
    this.secondaryAction,
    this.mode = CatchErrorStateMode.fullScreen,
  }) : assert(
         onRetry == null || retryLabel != null,
         'CatchErrorState requires retryLabel when onRetry is provided.',
       );

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  /// Caller-resolved label, required when [onRetry] is supplied.
  final String? retryLabel;
  final Widget? secondaryAction;
  final CatchErrorStateMode mode;

  @override
  Widget build(BuildContext context) {
    return CatchErrorBody(
      title: title,
      message: message,
      icon: icon,
      onRetry: onRetry,
      retryLabel: retryLabel,
      secondaryAction: secondaryAction,
      mode: mode,
    );
  }
}
