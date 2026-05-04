import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:flutter/material.dart';

/// A section with a header and a vertical list of items.
///
/// Uses [ListView.separated] with [shrinkWrap] for embedding inside a
/// [CustomScrollView] (via [SliverToBoxAdapter]). This is fine for up to ~50
/// items. To scale beyond that, convert to return slivers directly:
///
/// ```dart
/// List<Widget> buildSlivers(BuildContext context) => [
///   SliverToBoxAdapter(child: SectionHeader(...)),
///   SliverList.separated(
///     itemCount: itemCount,
///     itemBuilder: (_, i) => Padding(
///       padding: EdgeInsets.symmetric(horizontal: CatchSpacing.s5),
///       child: itemBuilder(context, i),
///     ),
///     separatorBuilder: (_, _) => SizedBox(height: spacing),
///   ),
/// ];
/// ```
class CatchVerticalSection extends StatelessWidget {
  const CatchVerticalSection({
    super.key,
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = 14,
  });

  final String title;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
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
        ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s5),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          itemBuilder: (_, i) => itemBuilder(context, i),
          separatorBuilder: (_, _) => SizedBox(height: spacing),
        ),
      ],
    );
  }
}
