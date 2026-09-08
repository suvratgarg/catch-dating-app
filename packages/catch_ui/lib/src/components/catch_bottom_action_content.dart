import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_button.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:flutter/material.dart';

/// Provider-free contents shared by floating and anchored bottom actions.
///
/// Prefer `CatchBottomAction` for screen CTAs. Use this member directly only
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
    this.buttonShape = CatchButtonShape.pill,
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
  final CatchButtonShape buttonShape;
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
                      shape: buttonShape,
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
