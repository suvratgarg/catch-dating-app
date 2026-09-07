import 'dart:math' as math;

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_divided_field_interaction_scope.dart';
import 'package:catch_ui/src/components/catch_field_interaction_plane_scope.dart';
import 'package:catch_ui/src/components/catch_responsive_field_interaction_policy.dart';
import 'package:catch_ui/src/patterns/catch_responsive_section_composition.dart';
import 'package:catch_ui/src/patterns/catch_responsive_section_item.dart';
import 'package:catch_ui/src/patterns/catch_responsive_section_lane.dart';
import 'package:catch_ui/src/patterns/catch_section_stack.dart';
import 'package:catch_ui/src/patterns/catch_viewport_breakpoint.dart';
import 'package:flutter/widgets.dart';

/// Responsive layout for pages composed from complete `CatchSection` blocks.
///
/// Compact layout always follows [sections] order in one centered, capped lane.
/// When [composition] allows two columns and the component's remaining local
/// width reaches [breakpoint], complete sections move into their declared
/// lanes. Individual sections and fields are never split across columns.
class CatchResponsiveSectionLayout extends StatelessWidget {
  const CatchResponsiveSectionLayout({
    super.key,
    required this.sections,
    this.composition = CatchResponsiveSectionComposition.centered,
    this.breakpoint = CatchSectionTokens.twoColumnBreakpoint,
    this.maxSingleColumnWidth = CatchLayout.maxContentWidth,
    this.sectionGap = CatchGaps.section,
    this.columnGap = CatchGaps.section,
    this.fieldInteractionPolicy = const CatchResponsiveFieldInteractionPolicy(),
  }) : assert(breakpoint >= 0),
       assert(maxSingleColumnWidth > 0),
       assert(sectionGap >= 0),
       assert(columnGap >= 0);

  final List<CatchResponsiveSectionItem> sections;
  final CatchResponsiveSectionComposition composition;
  final double breakpoint;
  final double maxSingleColumnWidth;
  final double sectionGap;
  final double columnGap;
  final CatchResponsiveFieldInteractionPolicy fieldInteractionPolicy;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) return const SizedBox.shrink();
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
                child: CatchSectionStack(
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
    if (composition == CatchResponsiveSectionComposition.centered) {
      return singleColumn;
    }
    return CatchViewportBreakpoint(
      breakpoint: breakpoint,
      compactBuilder: (_) => singleColumn,
      expandedBuilder: (_) {
        final primary = <Widget>[];
        final secondary = <Widget>[];
        for (final section in sections) {
          if (section.lane == CatchResponsiveSectionLane.primary) {
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
                  child: CatchSectionStack(
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
                  child: CatchSectionStack(
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
}
