import 'dart:math' as math;

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_divided_field_interaction_scope.dart';
import 'package:catch_ui/src/components/catch_field_interaction_plane_scope.dart';
import 'package:catch_ui/src/components/catch_field_visibility_scope.dart';
import 'package:catch_ui/src/components/catch_responsive_field_interaction_policy.dart';
import 'package:catch_ui/src/patterns/catch_page_body.dart';
import 'package:catch_ui/src/patterns/catch_scroll_terminal_gap.dart';
import 'package:catch_ui/src/patterns/catch_section_list_item.dart';
import 'package:catch_ui/src/patterns/catch_section_list_mode.dart';
import 'package:catch_ui/src/patterns/catch_section_list_placement.dart';
import 'package:catch_ui/src/patterns/catch_tab_viewport_scope.dart';
import 'package:catch_ui/src/patterns/catch_viewport.dart';
import 'package:flutter/widgets.dart';

/// Ordered section rhythm with inset, sliver, responsive and page recipes.
///
/// Sections retain their own delimiters and field geometry. Every constructor
/// requires the caller to declare its empty-content policy. Responsive layouts
/// move complete sections between lanes; page layout delegates scrolling and
/// gutters to the existing screen-body owner.
class CatchSectionList extends StatelessWidget {
  const CatchSectionList({
    super.key,
    required List<Widget> children,
    required bool emptyStateOmitted,
    WidgetBuilder? emptyBuilder,
    double gap = CatchGaps.section,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.stretch,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) : assert(emptyStateOmitted || emptyBuilder != null),
       _sequence = (
         children: children,
         emptyBuilder: emptyBuilder,
         gap: gap,
         crossAxisAlignment: crossAxisAlignment,
         mainAxisSize: mainAxisSize,
         padding: null,
         detailInsets: null,
       ),
       _responsive = null,
       _page = null;

  const CatchSectionList.inset({
    super.key,
    required List<Widget> children,
    required bool emptyStateOmitted,
    WidgetBuilder? emptyBuilder,
    EdgeInsetsGeometry padding = CatchInsets.pageBody,
    double gap = 0,
  }) : assert(emptyStateOmitted || emptyBuilder != null),
       _sequence = (
         children: children,
         emptyBuilder: emptyBuilder,
         gap: gap,
         crossAxisAlignment: CrossAxisAlignment.stretch,
         mainAxisSize: MainAxisSize.max,
         padding: padding,
         detailInsets: null,
       ),
       _responsive = null,
       _page = null;

  const CatchSectionList.sliver({
    super.key,
    required List<Widget> children,
    required bool emptyStateOmitted,
    WidgetBuilder? emptyBuilder,
    double gap = 0,
    double horizontalPadding = CatchLayout.detailScreenHorizontalPadding,
    double topPadding = CatchLayout.detailScreenTopPadding,
    double bottomPadding = CatchLayout.detailScreenBottomPadding,
  }) : assert(emptyStateOmitted || emptyBuilder != null),
       _sequence = (
         children: children,
         emptyBuilder: emptyBuilder,
         gap: gap,
         crossAxisAlignment: CrossAxisAlignment.stretch,
         mainAxisSize: MainAxisSize.max,
         padding: null,
         detailInsets: (
           horizontal: horizontalPadding,
           top: topPadding,
           bottom: bottomPadding,
         ),
       ),
       _responsive = null,
       _page = null;

  const CatchSectionList.responsive({
    super.key,
    required List<CatchSectionListItem> items,
    required bool emptyStateOmitted,
    WidgetBuilder? emptyBuilder,
    CatchSectionListMode mode = CatchSectionListMode.centered,
    double breakpoint = CatchSectionTokens.twoColumnBreakpoint,
    double maxSingleColumnWidth = CatchLayout.maxContentWidth,
    double sectionGap = CatchGaps.section,
    double columnGap = CatchGaps.section,
    CatchResponsiveFieldInteractionPolicy fieldInteractionPolicy =
        const CatchResponsiveFieldInteractionPolicy(),
  }) : assert(emptyStateOmitted || emptyBuilder != null),
       assert(breakpoint >= 0),
       assert(maxSingleColumnWidth > 0),
       assert(sectionGap >= 0),
       assert(columnGap >= 0),
       _sequence = null,
       _responsive = (
         items: items,
         emptyBuilder: emptyBuilder,
         mode: mode,
         breakpoint: breakpoint,
         maxSingleColumnWidth: maxSingleColumnWidth,
         sectionGap: sectionGap,
         columnGap: columnGap,
         fieldInteractionPolicy: fieldInteractionPolicy,
       ),
       _page = null;

  const CatchSectionList.page({
    super.key,
    required List<CatchSectionListItem> items,
    required bool emptyStateOmitted,
    WidgetBuilder? emptyBuilder,
    CatchSectionListMode mode = CatchSectionListMode.centered,
    double? pt,
    ScrollController? controller,
    ScrollPhysics? physics,
    bool? primary,
    double breakpoint = CatchSectionTokens.twoColumnBreakpoint,
    double maxSingleColumnWidth = CatchLayout.maxContentWidth,
    double sectionGap = CatchGaps.section,
    double columnGap = CatchGaps.section,
    double terminalExtra = CatchSpacing.screenPb,
    CatchResponsiveFieldInteractionPolicy fieldInteractionPolicy =
        const CatchResponsiveFieldInteractionPolicy(),
  }) : assert(emptyStateOmitted || emptyBuilder != null),
       assert(breakpoint >= 0),
       assert(maxSingleColumnWidth > 0),
       assert(sectionGap >= 0),
       assert(columnGap >= 0),
       assert(terminalExtra >= 0),
       _sequence = null,
       _responsive = (
         items: items,
         emptyBuilder: emptyBuilder,
         mode: mode,
         breakpoint: breakpoint,
         maxSingleColumnWidth: maxSingleColumnWidth,
         sectionGap: sectionGap,
         columnGap: columnGap,
         fieldInteractionPolicy: fieldInteractionPolicy,
       ),
       _page = (
         pt: pt,
         controller: controller,
         physics: physics,
         primary: primary,
         terminalExtra: terminalExtra,
       );

  final _CatchSectionListSequence? _sequence;
  final _CatchSectionListResponsive? _responsive;
  final ({
    double? pt,
    ScrollController? controller,
    ScrollPhysics? physics,
    bool? primary,
    double terminalExtra,
  })?
  _page;

  @override
  Widget build(BuildContext context) {
    final responsive = _responsive;
    final page = _page;
    if (page != null) {
      final layout = responsive!;
      return CatchFieldVisibilityScope(
        bottomObstruction: CatchTabViewportScope.bottomOverlayInsetOf(context),
        child: CatchPageBody.screen(
          pt: page.pt,
          pb: 0,
          controller: page.controller,
          physics: page.physics,
          primary: page.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CatchSectionList.responsive(
                items: layout.items,
                emptyStateOmitted: layout.emptyBuilder == null,
                emptyBuilder: layout.emptyBuilder,
                mode: layout.mode,
                breakpoint: layout.breakpoint,
                maxSingleColumnWidth: layout.maxSingleColumnWidth,
                sectionGap: layout.sectionGap,
                columnGap: layout.columnGap,
                fieldInteractionPolicy: layout.fieldInteractionPolicy,
              ),
              CatchScrollTerminalGap(extra: page.terminalExtra),
            ],
          ),
        ),
      );
    }
    if (responsive != null) {
      final sections = responsive.items;
      final composition = responsive.mode;
      final breakpoint = responsive.breakpoint;
      final maxSingleColumnWidth = responsive.maxSingleColumnWidth;
      final sectionGap = responsive.sectionGap;
      final columnGap = responsive.columnGap;
      final fieldInteractionPolicy = responsive.fieldInteractionPolicy;
      if (sections.isEmpty) {
        return responsive.emptyBuilder?.call(context) ??
            const SizedBox.shrink();
      }
      final singleColumn = CatchDividedFieldInteractionScope(
        interaction: fieldInteractionPolicy.singleColumn,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.hasBoundedWidth
                ? constraints.maxWidth
                : maxSingleColumnWidth;
            final laneWidth = math.min(availableWidth, maxSingleColumnWidth);
            final laneInset = math.max(0.0, (availableWidth - laneWidth) / 2);
            final inheritedPlane = CatchFieldInteractionPlaneScope.outsetsOf(
              context,
            );
            return CatchFieldInteractionPlaneScope(
              outsets: EdgeInsets.only(
                left: inheritedPlane.left + laneInset,
                right: inheritedPlane.right + laneInset,
              ),
              child: Align(
                alignment: AlignmentDirectional.topCenter,
                child: SizedBox(
                  width: laneWidth,
                  child: CatchSectionList.inset(
                    emptyStateOmitted: true,
                    padding: EdgeInsets.zero,
                    gap: sectionGap,
                    children: [for (final section in sections) section.child],
                  ),
                ),
              ),
            );
          },
        ),
      );
      if (composition == CatchSectionListMode.centered) {
        return singleColumn;
      }
      return CatchViewport.atWidth(
        breakpoint: breakpoint,
        compactBuilder: (_) => singleColumn,
        expandedBuilder: (_) {
          final primary = <Widget>[];
          final secondary = <Widget>[];
          for (final section in sections) {
            if (section.lane == CatchSectionListPlacement.primary) {
              primary.add(section.child);
            } else {
              secondary.add(section.child);
            }
          }
          if (primary.isEmpty || secondary.isEmpty) return singleColumn;
          return CatchDividedFieldInteractionScope(
            interaction: fieldInteractionPolicy.splitPane,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CatchFieldInteractionPlaneScope(
                    outsets: EdgeInsets.zero,
                    child: CatchSectionList.inset(
                      emptyStateOmitted: true,
                      padding: EdgeInsets.zero,
                      gap: sectionGap,
                      children: primary,
                    ),
                  ),
                ),
                SizedBox(width: columnGap),
                Expanded(
                  child: CatchFieldInteractionPlaneScope(
                    outsets: EdgeInsets.zero,
                    child: CatchSectionList.inset(
                      emptyStateOmitted: true,
                      padding: EdgeInsets.zero,
                      gap: sectionGap,
                      children: secondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
    final sequence = _sequence!;
    final children = sequence.children;
    final spacedChildren = <Widget>[];
    for (final child in children) {
      if (spacedChildren.isNotEmpty && sequence.gap > 0) {
        spacedChildren.add(SizedBox(height: sequence.gap));
      }
      spacedChildren.add(child);
    }
    final content = children.isEmpty
        ? sequence.emptyBuilder?.call(context) ?? const SizedBox.shrink()
        : Column(
            mainAxisSize: sequence.mainAxisSize,
            crossAxisAlignment: sequence.crossAxisAlignment,
            children: spacedChildren,
          );
    final padding = sequence.padding;
    if (padding != null) {
      return Padding(
        padding: padding,
        child: CatchFieldInteractionPlaneScope.fromPadding(
          context: context,
          padding: padding,
          child: content,
        ),
      );
    }
    final detailInsets = sequence.detailInsets;
    if (detailInsets != null) {
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(
          detailInsets.horizontal,
          detailInsets.top,
          detailInsets.horizontal,
          detailInsets.bottom,
        ),
        sliver: SliverToBoxAdapter(child: content),
      );
    }
    return content;
  }
}

typedef _CatchSectionListSequence = ({
  List<Widget> children,
  WidgetBuilder? emptyBuilder,
  double gap,
  CrossAxisAlignment crossAxisAlignment,
  MainAxisSize mainAxisSize,
  EdgeInsetsGeometry? padding,
  ({double horizontal, double top, double bottom})? detailInsets,
});

typedef _CatchSectionListResponsive = ({
  List<CatchSectionListItem> items,
  WidgetBuilder? emptyBuilder,
  CatchSectionListMode mode,
  double breakpoint,
  double maxSingleColumnWidth,
  double sectionGap,
  double columnGap,
  CatchResponsiveFieldInteractionPolicy fieldInteractionPolicy,
});
