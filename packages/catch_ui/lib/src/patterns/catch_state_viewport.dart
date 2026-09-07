import 'package:catch_ui/src/patterns/catch_tab_viewport_scope.dart';
import 'package:flutter/material.dart';

/// Box-native viewport for terminal empty and error states.
///
/// A floating app-shell tab bar overlays the scaffold body instead of reducing
/// its constraints. Centering directly in the body therefore lands below the
/// optical center of the visible region. This primitive owns that shell
/// geometry once for both empty and error content.
class CatchStateViewport extends StatelessWidget {
  const CatchStateViewport({
    super.key,
    required this.child,
    this.accountForBottomOverlay = true,
  });

  final Widget child;
  final bool accountForBottomOverlay;

  @override
  Widget build(BuildContext context) {
    final bottomOverlayInset = accountForBottomOverlay
        ? CatchTabViewportScope.bottomOverlayInsetOf(context)
        : 0.0;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomOverlayInset),
      child: child,
    );
  }
}
