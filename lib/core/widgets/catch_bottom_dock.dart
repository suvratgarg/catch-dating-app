import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:flutter/material.dart';

enum CatchBottomDockVariant { custom, cta }

/// Anchored bottom utility surface for chat inputs, compact action strips, and
/// other controls that sit above the device safe area.
class CatchBottomDock extends StatelessWidget {
  const CatchBottomDock({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      CatchSpacing.s3,
      CatchSpacing.s2,
      CatchSpacing.s3,
      CatchSpacing.s3,
    ),
    this.includeSafeArea = true,
  }) : variant = CatchBottomDockVariant.custom,
       label = null,
       onPressed = null,
       leadingContent = null,
       buttonKey = null,
       isLoading = false,
       backgroundColor = null,
       dividerColor = null,
       buttonAccentColor = null,
       catchLine = null,
       catchLineAccent = null,
       footnote = null;

  const CatchBottomDock.cta({
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
  }) : variant = CatchBottomDockVariant.cta,
       child = null,
       padding = EdgeInsets.zero,
       includeSafeArea = false;

  final CatchBottomDockVariant variant;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final bool includeSafeArea;
  final String? label;
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

  @override
  Widget build(BuildContext context) {
    if (variant == CatchBottomDockVariant.cta) {
      return CatchBottomDockCta(
        label: label!,
        onPressed: onPressed,
        leadingContent: leadingContent,
        buttonKey: buttonKey,
        isLoading: isLoading,
        backgroundColor: backgroundColor,
        dividerColor: dividerColor,
        buttonAccentColor: buttonAccentColor,
        catchLine: catchLine,
        catchLineAccent: catchLineAccent,
        footnote: footnote,
      );
    }

    final t = CatchTokens.of(context);
    final dock = DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.line)),
      ),
      child: Padding(padding: padding, child: child!),
    );

    if (!includeSafeArea) return dock;
    return SafeArea(top: false, child: dock);
  }
}

class CatchBottomDockCta extends StatelessWidget {
  const CatchBottomDockCta({
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

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: backgroundColor ?? t.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CatchDivider.section(color: dividerColor),
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
