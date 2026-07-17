import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Anchored bottom utility surface for chat inputs, compact action strips, and
/// other controls that sit above the device safe area.
class CatchBottomDock extends StatelessWidget {
  const CatchBottomDock({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      CatchSpacing.s4,
      CatchSpacing.s3,
      CatchSpacing.s4,
      CatchSpacing.s3,
    ),
    this.includeSafeArea = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool includeSafeArea;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final dock = DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.line)),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (!includeSafeArea) return dock;
    return SafeArea(top: false, child: dock);
  }
}
