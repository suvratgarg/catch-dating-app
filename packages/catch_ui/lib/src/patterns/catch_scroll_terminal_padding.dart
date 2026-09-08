import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_tab_viewport_scope.dart';
import 'package:flutter/widgets.dart';

/// Box-native terminal clearance for root scroll views.
class CatchScrollTerminalPadding extends StatelessWidget {
  const CatchScrollTerminalPadding({
    super.key,
    this.extra = CatchSpacing.screenPb,
    this.includeSafeArea = true,
  });

  final double extra;
  final bool includeSafeArea;

  @override
  Widget build(BuildContext context) {
    final height = includeSafeArea
        ? CatchTabViewportScope.scrollTerminalClearanceOf(context, extra: extra)
        : extra;
    return SizedBox(height: height);
  }
}
