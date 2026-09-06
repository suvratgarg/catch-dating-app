import 'package:catch_dating_app/core/widgets/catch_section_header.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class CatchRailItemWidth {
  const CatchRailItemWidth.fractional({
    required this.fraction,
    required this.min,
    required this.max,
  });

  final double fraction;
  final double min;
  final double max;

  double resolve(double availableWidth) =>
      (availableWidth * fraction).clamp(min, max).toDouble();
}

/// A section with a header and a horizontally-scrolling rail of items.
///
/// Uses [ListView.separated] with [shrinkWrap] for embedding inside a
/// [CustomScrollView] (via [SliverToBoxAdapter]). Fine for up to ~50 items.
/// To scale beyond that, convert the rail body to [SliverToBoxAdapter] for the
/// header and a horizontal [SliverList] for the items.
class CatchHorizontalRail extends StatelessWidget {
  const CatchHorizontalRail({
    super.key,
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    this.trailing,
    this.fullBleed = false,
    bool? showDivider,
    this.height = CatchLayout.horizontalRailHeight,
    this.spacing = CatchSpacing.s3,
    this.itemWidth,
    EdgeInsets? headerPadding,
    EdgeInsetsGeometry? listPadding,
  }) : showDivider = showDivider ?? fullBleed,
       headerPadding =
           headerPadding ??
           (fullBleed ? CatchInsets.sectionHeader : EdgeInsets.zero),
       listPadding =
           listPadding ??
           (fullBleed ? CatchInsets.pageHorizontal : EdgeInsets.zero);

  final String title;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Widget? trailing;
  final bool fullBleed;
  final bool showDivider;
  final double? height;
  final double spacing;
  final CatchRailItemWidth? itemWidth;
  final EdgeInsets headerPadding;
  final EdgeInsetsGeometry listPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchSectionHeader(
          title: title,
          titleStyle: CatchTextStyles.titleL(context),
          padding: headerPadding,
        ),
        if (itemWidth case final widthPolicy?)
          LayoutBuilder(
            builder: (context, constraints) => _buildRail(
              context,
              resolvedItemWidth: widthPolicy.resolve(constraints.maxWidth),
            ),
          )
        else
          _buildRail(context),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: CatchSpacing.screenPx),
            child: CatchDivider.section(),
          ),
      ],
    );
  }

  Widget _buildRail(BuildContext context, {double? resolvedItemWidth}) {
    final count = itemCount + (trailing != null ? 1 : 0);
    if (height == null) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: listPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < count; index += 1) ...[
              if (index > 0) SizedBox(width: spacing),
              _itemAt(context, index, resolvedItemWidth: resolvedItemWidth),
            ],
          ],
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: listPadding,
        itemCount: count,
        separatorBuilder: (_, _) => SizedBox(width: spacing),
        itemBuilder: (context, index) =>
            _itemAt(context, index, resolvedItemWidth: resolvedItemWidth),
      ),
    );
  }

  Widget _itemAt(BuildContext context, int index, {double? resolvedItemWidth}) {
    final item = index < itemCount ? itemBuilder(context, index) : trailing!;
    return resolvedItemWidth == null
        ? item
        : SizedBox(width: resolvedItemWidth, child: item);
  }
}
