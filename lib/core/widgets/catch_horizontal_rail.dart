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
  });

  final String title;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Widget? trailing;
  final bool showDivider;
  final double height;
  final double spacing;

  static const _headerPadding = EdgeInsets.fromLTRB(
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
          padding: _headerPadding,
        ),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s5),
            itemCount: itemCount + (trailing != null ? 1 : 0),
            separatorBuilder: (_, _) => SizedBox(width: spacing),
            itemBuilder: (context, index) {
              if (index < itemCount) return itemBuilder(context, index);
              return trailing!;
            },
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s5),
            child: Divider(
              color: CatchTokens.of(context).line,
              height: 24,
            ),
          ),
      ],
    );
  }
}
