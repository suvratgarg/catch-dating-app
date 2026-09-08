import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_field_interaction_plane.dart';
import 'package:flutter/widgets.dart';

/// Design-system `ScreenBody`: the scrolling/content body owns the app gutter.
///
/// Use this as the standard middle region under full-bleed chrome. It owns the
/// app-wide horizontal gutter, scrolls vertically by default, and lets screens
/// override only the top/bottom rhythm without rebuilding the side insets.
class CatchScreenBody extends StatelessWidget {
  const CatchScreenBody({
    super.key,
    required this.child,
    this.gutter = true,
    this.pt,
    this.pb,
    this.padding,
    this.scrollable = true,
    this.controller,
    this.physics,
    this.primary,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.onDrag,
    this.clipBehavior = Clip.hardEdge,
  });

  final Widget child;
  final bool gutter;
  final double? pt;
  final double? pb;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool? primary;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = _effectivePadding();
    final paddedChild = Padding(
      padding: effectivePadding,
      child: CatchFieldInteractionPlane(
        padding: effectivePadding,
        child: SizedBox(width: double.infinity, child: child),
      ),
    );

    if (!scrollable) return paddedChild;

    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : 0.0;

        return SingleChildScrollView(
          controller: controller,
          physics: physics,
          primary: primary,
          keyboardDismissBehavior: keyboardDismissBehavior,
          clipBehavior: clipBehavior,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: paddedChild,
          ),
        );
      },
    );
  }

  EdgeInsetsGeometry _effectivePadding() {
    final padding = this.padding;
    if (padding != null) return padding;

    final horizontal = gutter ? CatchSpacing.screenPx : CatchSpacing.s0;
    return EdgeInsets.fromLTRB(
      horizontal,
      pt ?? CatchSpacing.screenPt,
      horizontal,
      pb ?? CatchSpacing.screenPb,
    );
  }
}
