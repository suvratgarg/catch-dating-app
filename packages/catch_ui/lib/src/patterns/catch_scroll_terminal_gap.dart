import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_tab_viewport_scope.dart';
import 'package:flutter/widgets.dart';

/// Terminal breathing room plus the space obstructed by shell or safe area.
///
/// Box and sliver recipes use one clearance calculation. Anchored navigation
/// already reduces the viewport; floating navigation publishes its full inset.
class CatchScrollTerminalGap extends StatelessWidget {
  const CatchScrollTerminalGap({
    super.key,
    this.extra = CatchSpacing.screenPb,
    this.includeSafeArea = true,
  }) : _sliver = false;

  const CatchScrollTerminalGap.sliver({
    super.key,
    this.extra = CatchSpacing.screenPb,
    this.includeSafeArea = true,
  }) : _sliver = true;

  final double extra;
  final bool includeSafeArea;
  final bool _sliver;

  @override
  Widget build(BuildContext context) {
    final height = includeSafeArea
        ? CatchTabViewportScope.scrollTerminalClearanceOf(context, extra: extra)
        : extra;
    final gap = SizedBox(height: height);
    return _sliver ? SliverToBoxAdapter(child: gap) : gap;
  }
}
