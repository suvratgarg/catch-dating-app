import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_field_visibility_scope.dart';
import 'package:catch_ui/src/components/catch_responsive_field_interaction_policy.dart';
import 'package:catch_ui/src/patterns/catch_responsive_section_composition.dart';
import 'package:catch_ui/src/patterns/catch_responsive_section_item.dart';
import 'package:catch_ui/src/patterns/catch_responsive_section_layout.dart';
import 'package:catch_ui/src/patterns/catch_screen_body.dart';
import 'package:catch_ui/src/patterns/catch_scroll_terminal_padding.dart';
import 'package:catch_ui/src/patterns/catch_tab_viewport_scope.dart';
import 'package:flutter/widgets.dart';

/// Standard scrolling page body for responsive section-based routes.
///
/// This composes [CatchScreenBody], [CatchResponsiveSectionLayout], and
/// [CatchScrollTerminalPadding] so the route gets one page gutter, one scroll
/// owner, and correct terminal clearance for floating, anchored, side, or absent
/// shell navigation. It also publishes the floating bottom obstruction to
/// expanding `CatchField` controls so their commit actions remain revealable.
class CatchResponsiveSectionPage extends StatelessWidget {
  const CatchResponsiveSectionPage({
    super.key,
    required this.sections,
    this.composition = CatchResponsiveSectionComposition.centered,
    this.pt,
    this.controller,
    this.physics,
    this.primary,
    this.breakpoint = CatchSectionTokens.twoColumnBreakpoint,
    this.maxSingleColumnWidth = CatchLayout.maxContentWidth,
    this.sectionGap = CatchGaps.section,
    this.columnGap = CatchGaps.section,
    this.terminalExtra = CatchSpacing.screenPb,
    this.fieldInteractionPolicy = const CatchResponsiveFieldInteractionPolicy(),
  }) : assert(terminalExtra >= 0);

  final List<CatchResponsiveSectionItem> sections;
  final CatchResponsiveSectionComposition composition;
  final double? pt;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool? primary;
  final double breakpoint;
  final double maxSingleColumnWidth;
  final double sectionGap;
  final double columnGap;
  final double terminalExtra;
  final CatchResponsiveFieldInteractionPolicy fieldInteractionPolicy;

  @override
  Widget build(BuildContext context) {
    final bottomObstruction = CatchTabViewportScope.bottomOverlayInsetOf(
      context,
    );
    return CatchFieldVisibilityScope(
      bottomObstruction: bottomObstruction,
      child: CatchScreenBody(
        pt: pt,
        pb: 0,
        controller: controller,
        physics: physics,
        primary: primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CatchResponsiveSectionLayout(
              sections: sections,
              composition: composition,
              breakpoint: breakpoint,
              maxSingleColumnWidth: maxSingleColumnWidth,
              sectionGap: sectionGap,
              columnGap: columnGap,
              fieldInteractionPolicy: fieldInteractionPolicy,
            ),
            CatchScrollTerminalPadding(extra: terminalExtra),
          ],
        ),
      ),
    );
  }
}
