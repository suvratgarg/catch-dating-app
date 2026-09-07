import 'package:flutter/material.dart';

/// Selects a rail's content or trailing slot and applies its resolved width.
class CatchHorizontalRailItem extends StatelessWidget {
  const CatchHorizontalRailItem({
    super.key,
    required this.index,
    required this.itemCount,
    required this.itemBuilder,
    this.trailing,
    this.width,
  });

  final int index;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Widget? trailing;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final item = index < itemCount ? itemBuilder(context, index) : trailing!;
    return width == null ? item : SizedBox(width: width, child: item);
  }
}
