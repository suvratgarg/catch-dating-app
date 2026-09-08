import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/widgets.dart';

/// Vertical layout primitive for semantically distinct sections.
///
/// Use this instead of manually interleaving section widgets with spacer
/// widgets. The caller chooses a semantic gap token, and this widget owns the
/// mechanics of placing that gap between sections.
class CatchSectionList extends StatelessWidget {
  const CatchSectionList({
    super.key,
    required this.children,
    required this.emptyStateOmitted,
    this.emptyBuilder,
    this.gap = CatchGaps.section,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisSize = MainAxisSize.max,
  }) : assert(
         emptyStateOmitted || emptyBuilder != null,
         'CatchSectionList requires emptyBuilder or emptyStateOmitted: true.',
       );

  final List<Widget> children;
  final bool emptyStateOmitted;
  final WidgetBuilder? emptyBuilder;
  final double gap;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return emptyBuilder?.call(context) ?? const SizedBox.shrink();
    }
    final spacedChildren = <Widget>[];
    for (final child in children) {
      if (spacedChildren.isNotEmpty && gap > 0) {
        spacedChildren.add(SizedBox(height: gap));
      }
      spacedChildren.add(child);
    }

    return Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: spacedChildren,
    );
  }
}
