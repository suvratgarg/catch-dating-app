import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
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
/// CatchBottomCta(
///   label: 'Join event — 6 spots left',
///   onPressed: () {},
/// )
///
/// // With price lead-in
/// CatchBottomCta(
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
/// CatchBottomCta(label: 'Continue', onPressed: null)
/// ```
class CatchBottomCta extends StatelessWidget {
  const CatchBottomCta({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingContent,
    this.buttonKey,
    this.isLoading = false,
    this.backgroundColor,
    this.dividerColor,
    this.buttonAccentColor,
    this.catchLine,
    this.catchLineAccent,
    this.footnote,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Optional widget placed to the left of the primary button.
  final Widget? leadingContent;
  final Key? buttonKey;

  /// Shows the design-system loading state inside the button when true.
  final bool isLoading;
  final Color? backgroundColor;
  final Color? dividerColor;
  final Color? buttonAccentColor;

  /// Optional whispered line above the dock (design-system BookingDock
  /// catch-line, e.g. "Matching opens for everyone who goes") — a sparkle in
  /// [catchLineAccent] followed by tracked mono caps.
  final String? catchLine;
  final Color? catchLineAccent;

  /// Optional centered mono note rendered under the primary button.
  final String? footnote;

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
          if (catchLine != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.s4,
                CatchSpacing.s2,
                CatchSpacing.s4,
                CatchSpacing.s0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CatchIcons.sparkle,
                    size: CatchIcon.xs,
                    color: catchLineAccent ?? t.ink2,
                  ),
                  const SizedBox(width: CatchSpacing.micro6),
                  Flexible(
                    child: Text(
                      catchLine!.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: CatchTextStyles.monoLabel(context, color: t.ink2),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              CatchSpacing.s4,
              CatchSpacing.s3,
              CatchSpacing.s4,
              CatchSpacing.s3 + bottomPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (leadingContent != null) ...[leadingContent!, gapW14],
                    Expanded(
                      child: CatchButton(
                        key: buttonKey,
                        label: label,
                        onPressed: onPressed,
                        size: CatchButtonSize.lg,
                        isLoading: isLoading,
                        fullWidth: true,
                        accentColor: buttonAccentColor,
                      ),
                    ),
                  ],
                ),
                if (footnote != null) ...[
                  const SizedBox(height: CatchSpacing.s2),
                  Text(
                    footnote!,
                    textAlign: TextAlign.center,
                    style: CatchTextStyles.monoLabelS(context, color: t.ink3),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
