import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_section_list.dart';
import 'package:flutter/widgets.dart';

/// Sliver-native detail body wrapper with Catch's detail-screen page insets.
///
/// Defaults to no inserted gap so `CatchSection` owns its delimiter and
/// top rhythm in sliver-native detail pages too.
class CatchDetailSliverSectionList extends StatelessWidget {
  const CatchDetailSliverSectionList({
    super.key,
    required this.sections,
    this.gap = 0,
    this.horizontalPadding = CatchLayout.detailScreenHorizontalPadding,
    this.topPadding = CatchLayout.detailScreenTopPadding,
    this.bottomPadding = CatchLayout.detailScreenBottomPadding,
  });

  final List<Widget> sections;
  final double gap;
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topPadding,
        horizontalPadding,
        bottomPadding,
      ),
      sliver: SliverToBoxAdapter(
        child: CatchSectionList(
          emptyStateOmitted: true,
          gap: gap,
          children: sections,
        ),
      ),
    );
  }
}
