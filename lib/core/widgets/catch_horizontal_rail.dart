import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:flutter/material.dart';

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
    this.showDivider = true,
    this.height = 92,
    this.spacing = 12,
    this.headerPadding = _defaultHeaderPadding,
    this.listPadding = const EdgeInsets.symmetric(horizontal: CatchSpacing.s5),
  });

  final String title;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Widget? trailing;
  final bool showDivider;
  final double? height;
  final double spacing;
  final EdgeInsets headerPadding;
  final EdgeInsetsGeometry listPadding;

  static const _defaultHeaderPadding = EdgeInsets.fromLTRB(
    CatchSpacing.s5,
    14,
    CatchSpacing.s5,
    8,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          uppercase: false,
          titleStyle: CatchTextStyles.titleL(context),
          padding: headerPadding,
        ),
        _buildRail(context),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s5),
            child: Divider(color: CatchTokens.of(context).line, height: 24),
          ),
      ],
    );
  }

  Widget _buildRail(BuildContext context) {
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
              _itemAt(context, index),
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
        itemBuilder: _itemAt,
      ),
    );
  }

  Widget _itemAt(BuildContext context, int index) {
    if (index < itemCount) return itemBuilder(context, index);
    return trailing!;
  }
}
