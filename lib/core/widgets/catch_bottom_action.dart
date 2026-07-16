import 'package:catch_dating_app/core/platform/adaptive_platform.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:flutter/material.dart';

/// Platform-adaptive bottom action surface for a primary screen CTA.
///
/// Cupertino platforms use inset floating chrome. Material platforms use an
/// anchored full-width surface with a top divider. Callers provide one action
/// contract and cannot accidentally choose the wrong platform treatment.
class CatchBottomAction extends StatelessWidget {
  const CatchBottomAction({
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
  final Widget? leadingContent;
  final Key? buttonKey;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? dividerColor;
  final Color? buttonAccentColor;
  final String? catchLine;
  final Color? catchLineAccent;
  final String? footnote;

  static bool floatsFor(BuildContext context) =>
      prefersCupertinoControls(platform: Theme.of(context).platform);

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    if (floatsFor(context)) {
      final radius = BorderRadius.circular(CatchRadius.lg);

      return SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          CatchSpacing.screenPx,
          CatchSpacing.s0,
          CatchSpacing.screenPx,
          CatchSpacing.s2,
        ),
        child: DecoratedBox(
          key: const ValueKey('catch_bottom_action.floating_chrome'),
          decoration: BoxDecoration(
            color: backgroundColor ?? t.surface,
            border: Border.all(color: dividerColor ?? t.line),
            borderRadius: radius,
            boxShadow: CatchElevation.raised,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: CatchBottomActionContent(
              label: label,
              onPressed: onPressed,
              leadingContent: leadingContent,
              buttonKey: buttonKey,
              isLoading: isLoading,
              buttonAccentColor: buttonAccentColor,
              catchLine: catchLine,
              catchLineAccent: catchLineAccent,
              footnote: footnote,
            ),
          ),
        ),
      );
    }

    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      key: const ValueKey('catch_bottom_action.anchored_chrome'),
      color: backgroundColor ?? t.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CatchDivider.section(color: dividerColor),
          CatchBottomActionContent(
            label: label,
            onPressed: onPressed,
            leadingContent: leadingContent,
            buttonKey: buttonKey,
            isLoading: isLoading,
            buttonAccentColor: buttonAccentColor,
            catchLine: catchLine,
            catchLineAccent: catchLineAccent,
            footnote: footnote,
            bottomPadding: CatchSpacing.s3 + bottomPadding,
          ),
        ],
      ),
    );
  }
}

/// Provider-free contents shared by floating and anchored bottom actions.
///
/// Prefer [CatchBottomAction] for screen CTAs. Use this member directly only
/// when an owning surface already provides the appropriate platform chrome.
class CatchBottomActionContent extends StatelessWidget {
  const CatchBottomActionContent({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingContent,
    this.buttonKey,
    this.isLoading = false,
    this.buttonAccentColor,
    this.catchLine,
    this.catchLineAccent,
    this.footnote,
    this.bottomPadding = CatchSpacing.s3,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leadingContent;
  final Key? buttonKey;
  final bool isLoading;
  final Color? buttonAccentColor;
  final String? catchLine;
  final Color? catchLineAccent;
  final String? footnote;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
            bottomPadding,
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
    );
  }
}
