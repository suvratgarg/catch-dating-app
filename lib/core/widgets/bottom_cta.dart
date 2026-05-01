import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:flutter/material.dart';

/// Sticky bottom action footer used on Run Detail, Create Run review,
/// onboarding steps, and the swipe screen.
///
/// Renders a white [CatchTokens.surface] bar separated from content by a
/// hairline [CatchTokens.line] border, with bottom safe-area padding.
///
/// Pass [leadingContent] to place price / subtitle text to the left of the
/// primary button (as seen on the Run Detail CTA: "₹299 / incl. coffee").
///
/// Usage:
/// ```dart
/// // Simple full-width button
/// BottomCTA(
///   label: 'Join run — 6 spots left',
///   onPressed: () {},
/// )
///
/// // With price lead-in
/// BottomCTA(
///   label: 'Join run',
///   onPressed: () {},
///   leadingContent: Column(
///     crossAxisAlignment: CrossAxisAlignment.start,
///     children: [
///       Text('₹299', style: CatchTextStyles.titleL(context)),
///       Text('incl. coffee after', style: CatchTextStyles.bodyS(context)),
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
  });

  final String label;
  final VoidCallback? onPressed;

  /// Optional widget placed to the left of the primary button.
  final Widget? leadingContent;

  /// Shows the design-system loading state inside the button when true.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      color: t.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(color: t.line, height: 1, thickness: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(
              CatchSpacing.s4,
              12,
              CatchSpacing.s4,
              12 + bottomPadding,
            ),
            child: Row(
              children: [
                if (leadingContent != null) ...[
                  leadingContent!,
                  const SizedBox(width: 14),
                ],
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
