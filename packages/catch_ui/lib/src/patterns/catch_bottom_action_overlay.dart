import 'dart:ui';

import 'package:catch_tokens/catch_tokens.dart';
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
    this.meta,
  });

  final Widget body;
  final Widget actions;
  final Widget? meta;

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
        if (meta != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: bodyBottomInset,
            child: KeyedSubtree(
              key: const ValueKey('catch_bottom_action_overlay.notice'),
              child: meta!,
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
