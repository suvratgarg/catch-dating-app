import 'package:catch_ui/src/components/catch_error_body.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/patterns/catch_sliver_state_viewport.dart';
import 'package:flutter/material.dart';

class CatchSliverErrorState extends StatelessWidget {
  const CatchSliverErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel,
    this.secondaryAction,
    this.icon = CatchIcons.errorOutlineRounded,
    this.fillRemaining = true,
  }) : assert(
         onRetry == null || retryLabel != null,
         'CatchSliverErrorState requires retryLabel when onRetry is provided.',
       );

  final String title;
  final String message;
  final VoidCallback? onRetry;

  /// Caller-resolved label, required when [onRetry] is supplied.
  final String? retryLabel;
  final Widget? secondaryAction;
  final IconData icon;
  final bool fillRemaining;

  @override
  Widget build(BuildContext context) {
    final child = CatchErrorBody(
      title: title,
      message: message,
      icon: icon,
      onRetry: onRetry,
      retryLabel: retryLabel,
      secondaryAction: secondaryAction,
    );

    if (fillRemaining) {
      return CatchSliverStateViewport(child: child);
    }

    return SliverToBoxAdapter(child: child);
  }
}
