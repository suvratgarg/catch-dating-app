import 'dart:math' as math;
import 'dart:ui';

import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Scroll-aware layout for actions that should stay pinned without a dock.
///
/// The body scrolls beneath a soft background-colored fade. Its usable viewport
/// ends above the measured actions and optional metadata, whose backing is fully
/// opaque even for ghost buttons. [CatchInsets.formStepBodyWithBottomActions]
/// provides terminal breathing room above the fade; callers do not calculate
/// control heights or reserve space for text scaling and device safe areas.
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
    return ClipRect(
      child: CustomMultiChildLayout(
        delegate: _BottomActionLayout(actionBottom: actionBottom),
        children: [
          LayoutId(
            id: _BottomActionSlot.body,
            child: KeyedSubtree(
              key: const ValueKey('catch_bottom_action_overlay.body'),
              child: body,
            ),
          ),
          LayoutId(
            id: _BottomActionSlot.scrim,
            child: IgnorePointer(
              child: ClipRect(
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
                            t.bg.withValues(
                              alpha: CatchOpacity.bottomActionScrim,
                            ),
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
          ),
          LayoutId(
            id: _BottomActionSlot.backing,
            child: IgnorePointer(child: ColoredBox(color: t.bg)),
          ),
          if (meta != null)
            LayoutId(
              id: _BottomActionSlot.meta,
              child: KeyedSubtree(
                key: const ValueKey('catch_bottom_action_overlay.notice'),
                child: meta!,
              ),
            ),
          LayoutId(
            id: _BottomActionSlot.actions,
            child: KeyedSubtree(
              key: const ValueKey('catch_bottom_action_overlay.actions'),
              child: actions,
            ),
          ),
        ],
      ),
    );
  }
}

enum _BottomActionSlot { body, scrim, backing, meta, actions }

/// Measure controls before the body in one layout pass. A fixed nominal button
/// height cannot represent wrapping, stacked actions, or multiline metadata.
class _BottomActionLayout extends MultiChildLayoutDelegate {
  _BottomActionLayout({required this.actionBottom});

  final double actionBottom;

  @override
  void performLayout(Size size) {
    final bottom = math.min(actionBottom, size.height);
    final gutter = math.min(
      CatchLayout.bottomActionHorizontalPadding,
      size.width / 2,
    );
    // Like a bottom-positioned Stack child, controls receive an unbounded
    // vertical axis. Center/Align must report their content height, not expand
    // into the space reserved for the form.
    final actions = layoutChild(
      _BottomActionSlot.actions,
      BoxConstraints.tightFor(width: size.width - gutter * 2),
    );
    final actionsTop = size.height - bottom - actions.height;
    positionChild(_BottomActionSlot.actions, Offset(gutter, actionsTop));

    var bodyHeight = actionsTop;
    if (hasChild(_BottomActionSlot.meta)) {
      bodyHeight -= CatchSpacing.s2;
      final meta = layoutChild(
        _BottomActionSlot.meta,
        BoxConstraints.tightFor(width: size.width),
      );
      bodyHeight -= meta.height;
      positionChild(_BottomActionSlot.meta, Offset(0, bodyHeight));
    }
    bodyHeight = math.max(0.0, bodyHeight);
    layoutChild(
      _BottomActionSlot.body,
      BoxConstraints.tight(Size(size.width, bodyHeight)),
    );
    positionChild(_BottomActionSlot.body, Offset.zero);

    final scrimTop = math.max(0.0, bodyHeight - CatchSpacing.s16);
    layoutChild(
      _BottomActionSlot.scrim,
      BoxConstraints.tight(Size(size.width, bodyHeight - scrimTop)),
    );
    positionChild(_BottomActionSlot.scrim, Offset(0, scrimTop));
    layoutChild(
      _BottomActionSlot.backing,
      BoxConstraints.tight(Size(size.width, size.height - bodyHeight)),
    );
    positionChild(_BottomActionSlot.backing, Offset(0, bodyHeight));
  }

  @override
  bool shouldRelayout(_BottomActionLayout oldDelegate) =>
      actionBottom != oldDelegate.actionBottom;
}
