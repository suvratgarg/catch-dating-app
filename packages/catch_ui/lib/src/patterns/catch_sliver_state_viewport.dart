import 'package:catch_ui/src/patterns/catch_state_viewport.dart';
import 'package:flutter/material.dart';

/// Sliver-native viewport for terminal empty and error states.
///
/// Reuses [CatchStateViewport] so box and sliver screen states share the same
/// floating-shell optical-center geometry.
class CatchSliverStateViewport extends StatelessWidget {
  const CatchSliverStateViewport({
    super.key,
    required this.child,
    this.accountForBottomOverlay = true,
  });

  final Widget child;
  final bool accountForBottomOverlay;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      // This must stay true: CatchEmptyState uses LayoutBuilder and cannot
      // participate in SliverFillRemaining's intrinsic-height pass.
      // ignore: avoid_redundant_argument_values
      hasScrollBody: true,
      child: CatchStateViewport(
        accountForBottomOverlay: accountForBottomOverlay,
        child: child,
      ),
    );
  }
}
