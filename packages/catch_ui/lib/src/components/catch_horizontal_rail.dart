import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_horizontal_rail_body.dart';
import 'package:catch_ui/src/components/catch_section_header.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_divider.dart';
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
/// A specified [height] uses a lazy horizontal list. A null height sizes the
/// rail to its content using a horizontally scrolling row. [itemWidth] resolves
/// item widths against the available viewport before applying its bounds.
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
            builder: (context, constraints) => CatchHorizontalRailBody(
              itemCount: itemCount,
              itemBuilder: itemBuilder,
              trailing: trailing,
              height: height,
              spacing: spacing,
              listPadding: listPadding,
              itemWidth: widthPolicy.resolve(constraints.maxWidth),
            ),
          )
        else
          CatchHorizontalRailBody(
            itemCount: itemCount,
            itemBuilder: itemBuilder,
            trailing: trailing,
            height: height,
            spacing: spacing,
            listPadding: listPadding,
          ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: CatchSpacing.screenPx),
            child: CatchDivider.section(),
          ),
      ],
    );
  }
}
