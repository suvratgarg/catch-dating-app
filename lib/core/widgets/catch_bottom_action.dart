import 'dart:ui';

import 'package:catch_dating_app/core/platform/adaptive_platform.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Scroll-aware layout for actions that should stay pinned without a dock.
///
/// The body remains visually connected to the page and passes beneath a soft
/// background-colored fade. The action row stays crisp above that fade. Pair
/// scrollable bodies with [CatchInsets.formStepBodyWithBottomActions] so their
/// final content can clear the controls without breaking the visual overlap.
class CatchBottomActionOverlay extends StatelessWidget {
  const CatchBottomActionOverlay({
    super.key,
    required this.body,
    required this.actions,
    this.notice,
  });

  final Widget body;
  final Widget actions;
  final Widget? notice;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final actionBottom =
        safeBottom > CatchLayout.bottomActionMinimumBottomPadding
        ? safeBottom
        : CatchLayout.bottomActionMinimumBottomPadding;
    final bodyBottomInset = CatchLayout.buttonLgHeight + actionBottom;
    final scrimExtent =
        bodyBottomInset > CatchLayout.bottomActionOverlayScrimHeight
        ? bodyBottomInset
        : CatchLayout.bottomActionOverlayScrimHeight;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: KeyedSubtree(
            key: const ValueKey('catch_bottom_action_overlay.body'),
            child: body,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: scrimExtent,
          child: IgnorePointer(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      CatchTokens.editorialBlack.withValues(
                        alpha: CatchOpacity.none,
                      ),
                      CatchTokens.editorialBlack,
                    ],
                    stops: const [0, 0.72],
                  ).createShader(bounds),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: CatchLayout.bottomActionBlurSigma,
                      sigmaY: CatchLayout.bottomActionBlurSigma,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                DecoratedBox(
                  key: const ValueKey('catch_bottom_action_overlay.scrim'),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        t.bg.withValues(alpha: CatchOpacity.none),
                        t.bg.withValues(alpha: CatchOpacity.bottomActionScrim),
                        t.bg,
                      ],
                      stops: const [0, 0.52, 1],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (notice != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: bodyBottomInset,
            child: KeyedSubtree(
              key: const ValueKey('catch_bottom_action_overlay.notice'),
              child: notice!,
            ),
          ),
        Positioned(
          left: CatchLayout.bottomActionHorizontalPadding,
          right: CatchLayout.bottomActionHorizontalPadding,
          bottom: actionBottom,
          child: KeyedSubtree(
            key: const ValueKey('catch_bottom_action_overlay.actions'),
            child: actions,
          ),
        ),
      ],
    );
  }
}

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
