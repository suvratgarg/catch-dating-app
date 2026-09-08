import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Full-row disclosure sibling below a `CatchField` header.
class CatchFieldDisclosureDrawer extends StatelessWidget {
  const CatchFieldDisclosureDrawer({
    super.key,
    required this.open,
    required this.offstage,
    required this.control,
    required this.startPadding,
    required this.endPadding,
    required this.bottomPadding,
    required this.revealDuration,
    required this.opacityDuration,
    required this.onRevealEnd,
    this.actionBar,
    this.revealTargetKey,
  });

  final bool open;
  final bool offstage;
  final Widget control;
  final Widget? actionBar;
  final double startPadding;
  final double endPadding;
  final double bottomPadding;
  final Duration revealDuration;
  final Duration opacityDuration;
  final VoidCallback onRevealEnd;
  final Key? revealTargetKey;

  @override
  Widget build(BuildContext context) {
    final animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations == true;
    final resolvedRevealDuration = animationsDisabled
        ? Duration.zero
        : revealDuration;
    final resolvedOpacityDuration = animationsDisabled
        ? Duration.zero
        : opacityDuration;
    final revealedContent = KeyedSubtree(
      key: revealTargetKey,
      child: GestureDetector(
        key: const ValueKey('catch-field-control-tap-barrier'),
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: startPadding,
            end: endPadding,
            top: CatchFieldTokens.controlTopGap,
            bottom: bottomPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              control,
              if (actionBar != null) ...[
                const SizedBox(height: CatchFieldTokens.actionBarTopGap),
                actionBar!,
              ],
            ],
          ),
        ),
      ),
    );

    return ExcludeSemantics(
      excluding: !open,
      child: ExcludeFocus(
        excluding: !open,
        child: IgnorePointer(
          ignoring: !open,
          child: TweenAnimationBuilder<double>(
            key: const ValueKey('catch-field-expansion'),
            duration: resolvedRevealDuration,
            curve: CatchMotion.standardCurve,
            tween: Tween<double>(end: open ? 1 : 0),
            onEnd: onRevealEnd,
            child: revealedContent,
            builder: (context, reveal, child) => Offstage(
              offstage: offstage || (!open && reveal == 0),
              child: ClipRect(
                clipper: const _CatchFieldDisclosureClipper(),
                child: AnimatedOpacity(
                  key: const ValueKey('catch-field-control-opacity'),
                  duration: resolvedOpacityDuration,
                  curve: CatchMotion.standardCurve,
                  opacity: open ? 1 : 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: reveal,
                    child: Transform.translate(
                      key: const ValueKey('catch-field-control-slide'),
                      offset: Offset(0, CatchSpacing.s2 * (1 - reveal)),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CatchFieldDisclosureClipper extends CustomClipper<Rect> {
  const _CatchFieldDisclosureClipper();

  @override
  Rect getClip(Size size) => Rect.fromLTRB(
    0,
    0,
    size.width,
    size.height +
        CatchFieldTokens.focusRingOffset +
        CatchFieldTokens.focusRingWidth,
  );

  @override
  bool shouldReclip(_CatchFieldDisclosureClipper oldClipper) => false;
}
