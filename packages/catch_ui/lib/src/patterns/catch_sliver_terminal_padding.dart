import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_scroll_terminal_padding.dart';
import 'package:flutter/widgets.dart';

/// Sliver-native terminal clearance for root scroll views.
///
/// Use this as the final sliver when a screen owns a full-height
/// [CustomScrollView] and needs enough room for home-indicator safe area plus
/// Catch's standard bottom breathing space.
class CatchSliverTerminalPadding extends StatelessWidget {
  const CatchSliverTerminalPadding({
    super.key,
    this.extra = CatchSpacing.screenPb,
    this.includeSafeArea = true,
  });

  final double extra;
  final bool includeSafeArea;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: CatchScrollTerminalPadding(
        extra: extra,
        includeSafeArea: includeSafeArea,
      ),
    );
  }
}
