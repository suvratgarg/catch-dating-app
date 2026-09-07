import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/widgets.dart';

/// Centers one sliver around a semantic content lane on wide viewports while
/// leaving compact layouts direct and full width.
class CatchSliverContentWidth extends StatelessWidget {
  const CatchSliverContentWidth({
    super.key,
    required this.sliver,
    this.maxExtent = CatchLayout.screenPageMaxExtent,
  }) : assert(maxExtent > 0);

  final Widget sliver;
  final double maxExtent;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        if (constraints.crossAxisExtent <= maxExtent) return sliver;
        return SliverCrossAxisGroup(
          slivers: [
            const SliverCrossAxisExpanded(
              flex: 1,
              sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            SliverConstrainedCrossAxis(maxExtent: maxExtent, sliver: sliver),
            const SliverCrossAxisExpanded(
              flex: 1,
              sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
          ],
        );
      },
    );
  }
}
