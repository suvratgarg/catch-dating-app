import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_bottom_action_content.dart';
import 'package:catch_ui/src/components/catch_button.dart';
import 'package:catch_ui/src/foundations/catch_adaptive_platform.dart';
import 'package:catch_ui/src/primitives/catch_divider.dart';
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
    this.buttonShape = CatchButtonShape.pill,
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
  final CatchButtonShape buttonShape;
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
              buttonShape: buttonShape,
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
            buttonShape: buttonShape,
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
