import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:flutter/material.dart';

/// Sticky bottom action footer used on Event Detail, Create Event review,
/// onboarding steps, and the swipe screen.
///
/// Renders a white [CatchTokens.surface] bar separated from content by a
/// hairline [CatchTokens.line] border, with bottom safe-area padding.
///
/// Pass [leadingContent] to place price / subtitle text to the left of the
/// primary button (as seen on the Event Detail CTA: "₹299 / incl. coffee").
///
/// Usage:
/// ```dart
/// // Simple full-width button
/// BottomCTA(
///   label: 'Join event — 6 spots left',
///   onPressed: () {},
/// )
///
/// // With price lead-in
/// BottomCTA(
///   label: 'Join event',
///   onPressed: () {},
///   leadingContent: Column(
///     crossAxisAlignment: CrossAxisAlignment.start,
///     children: [
///       Text('₹299', style: CatchTextStyles.titleL(context)),
///       Text('incl. coffee after', style: CatchTextStyles.supporting(context)),
///     ],
///   ),
/// )
///
/// // Disabled state
/// BottomCTA(label: 'Continue', onPressed: null)
/// ```
class BottomCTA extends StatelessWidget {
  const BottomCTA({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingContent,
    this.isLoading = false,
    this.backgroundColor,
    this.dividerColor,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Optional widget placed to the left of the primary button.
  final Widget? leadingContent;

  /// Shows the design-system loading state inside the button when true.
  final bool isLoading;
  final Color? backgroundColor;
  final Color? dividerColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: backgroundColor ?? t.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(color: dividerColor ?? t.line, height: 1, thickness: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(
              CatchSpacing.s4,
              CatchSpacing.s3,
              CatchSpacing.s4,
              CatchSpacing.s3 + bottomPadding,
            ),
            child: Row(
              children: [
                if (leadingContent != null) ...[leadingContent!, gapW14],
                Expanded(
                  child: CatchButton(
                    label: label,
                    onPressed: onPressed,
                    size: CatchButtonSize.lg,
                    isLoading: isLoading,
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
