import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_field_interaction_plane.dart';
import 'package:catch_ui/src/patterns/catch_section_list.dart';
import 'package:flutter/widgets.dart';

/// Design-system `SectionStack`: standard body gutter for handoff sections.
///
/// Section-to-section rhythm belongs to `CatchSection` itself; this
/// wrapper intentionally defaults to no inserted gap.
class CatchSectionStack extends StatelessWidget {
  const CatchSectionStack({
    super.key,
    required this.children,
    this.padding = CatchInsets.pageBody,
    this.gap = 0,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: CatchFieldInteractionPlane(
        padding: padding,
        child: CatchSectionList(
          emptyStateOmitted: true,
          gap: gap,
          children: children,
        ),
      ),
    );
  }
}
