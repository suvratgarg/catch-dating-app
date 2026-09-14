import 'package:catch_ui/src/patterns/catch_tab_viewport_scope.dart';
import 'package:flutter/widgets.dart';

/// Removes the floating shell obstruction from terminal-state placement.
///
/// The caller owns empty/error content and its alignment. Box and sliver
/// recipes share the same visible viewport; the sliver recipe fills the
/// remaining scroll extent without requesting intrinsic child dimensions.
class CatchStateViewport extends StatelessWidget {
  const CatchStateViewport({
    super.key,
    required this.child,
    this.accountForBottomOverlay = true,
  }) : _sliver = false;

  const CatchStateViewport.sliver({
    super.key,
    required this.child,
    this.accountForBottomOverlay = true,
  }) : _sliver = true;

  final Widget child;
  final bool accountForBottomOverlay;
  final bool _sliver;

  @override
  Widget build(BuildContext context) {
    final bottomOverlayInset = accountForBottomOverlay
        ? CatchTabViewportScope.bottomOverlayInsetOf(context)
        : 0.0;
    final body = Padding(
      padding: EdgeInsets.only(bottom: bottomOverlayInset),
      child: child,
    );
    return _sliver
        ? SliverFillRemaining(
            // State content uses LayoutBuilder and cannot provide intrinsics.
            // ignore: avoid_redundant_argument_values
            hasScrollBody: true,
            child: body,
          )
        : body;
  }
}
