import 'package:catch_ui/src/components/catch_horizontal_rail_item.dart';
import 'package:flutter/material.dart';

/// Horizontal rail viewport with bounded or content-driven height.
class CatchHorizontalRailBody extends StatelessWidget {
  const CatchHorizontalRailBody({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.height,
    required this.spacing,
    required this.listPadding,
    this.trailing,
    this.itemWidth,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Widget? trailing;
  final double? height;
  final double spacing;
  final EdgeInsetsGeometry listPadding;
  final double? itemWidth;

  @override
  Widget build(BuildContext context) {
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
              CatchHorizontalRailItem(
                index: index,
                itemCount: itemCount,
                itemBuilder: itemBuilder,
                trailing: trailing,
                width: itemWidth,
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
        itemBuilder: (context, index) => CatchHorizontalRailItem(
          index: index,
          itemCount: itemCount,
          itemBuilder: itemBuilder,
          trailing: trailing,
          width: itemWidth,
        ),
      ),
    );
  }
}
