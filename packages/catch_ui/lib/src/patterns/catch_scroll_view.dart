import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Scrolls overflow while short content fills the local viewport height.
///
/// Optional alignment, insets and a content-width cap preserve a caller-owned
/// composition. Page gutters and field paint policy belong to CatchPageBody.
class CatchScrollView extends StatelessWidget {
  const CatchScrollView({
    super.key,
    required this.child,
    this.scrollViewKey,
    this.padding = EdgeInsets.zero,
    this.maxContentWidth,
    this.alignment = Alignment.topCenter,
    this.controller,
    this.physics,
    this.primary,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
  });

  final Widget child;
  final Key? scrollViewKey;
  final EdgeInsetsGeometry padding;
  final double? maxContentWidth;
  final AlignmentGeometry alignment;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool? primary;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      key: scrollViewKey,
      controller: controller,
      physics: physics,
      primary: primary,
      keyboardDismissBehavior: keyboardDismissBehavior,
      clipBehavior: clipBehavior,
      child: Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.hasBoundedHeight ? constraints.maxHeight : 0,
            minWidth: math.min(
              constraints.maxWidth,
              maxContentWidth ?? constraints.maxWidth,
            ),
            maxWidth: maxContentWidth ?? constraints.maxWidth,
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    ),
  );
}
