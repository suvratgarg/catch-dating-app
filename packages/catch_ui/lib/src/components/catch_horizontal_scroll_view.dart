import 'package:flutter/material.dart';

/// Bounded or fractional widths for items in a horizontal section viewport.
class CatchRailItemWidth {
  const CatchRailItemWidth.fractional({
    required double fraction,
    required this.min,
    required this.max,
  }) : fraction = fraction;

  const CatchRailItemWidth.fixed(double width)
    : fraction = null,
      min = width,
      max = width;

  final double? fraction;
  final double min;
  final double max;

  double resolve(double availableWidth) => fraction == null
      ? min
      : (availableWidth * fraction!).clamp(min, max).toDouble();
}

/// Horizontal item viewport with lazy bounded-height and intrinsic-height forms.
///
/// The containing section owns its heading, gutters and divider. [footer] is
/// the final scrollable item; it receives the same width and spacing policy.
class CatchHorizontalScrollView extends StatelessWidget {
  const CatchHorizontalScrollView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.height,
    required this.spacing,
    required this.listPadding,
    this.footer,
    this.itemWidth,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Widget? footer;
  final double? height;
  final double spacing;
  final EdgeInsetsGeometry listPadding;
  final CatchRailItemWidth? itemWidth;

  @override
  Widget build(BuildContext context) {
    if (itemWidth case final policy? when policy.fraction != null) {
      return LayoutBuilder(
        builder: (context, constraints) => CatchHorizontalScrollView(
          itemCount: itemCount,
          itemBuilder: itemBuilder,
          footer: footer,
          height: height,
          spacing: spacing,
          listPadding: listPadding,
          itemWidth: CatchRailItemWidth.fixed(
            policy.resolve(constraints.maxWidth),
          ),
        ),
      );
    }
    final width = itemWidth?.min;
    final count = itemCount + (footer != null ? 1 : 0);
    if (height == null) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: listPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < count; index += 1) ...[
              if (index > 0) SizedBox(width: spacing),
              Builder(
                builder: (context) {
                  final item = index < itemCount
                      ? itemBuilder(context, index)
                      : footer!;
                  return width == null
                      ? item
                      : SizedBox(width: width, child: item);
                },
              ),
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
        itemBuilder: (context, index) => Builder(
          builder: (context) {
            final item = index < itemCount
                ? itemBuilder(context, index)
                : footer!;
            return width == null ? item : SizedBox(width: width, child: item);
          },
        ),
      ),
    );
  }
}
