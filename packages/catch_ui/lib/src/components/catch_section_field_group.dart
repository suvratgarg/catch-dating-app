import 'package:flutter/widgets.dart';

/// One labelled field-row group inside a shared contained section perimeter.
///
/// Use through `CatchSection.containedFieldGroups` when several related choice
/// groups form one collection. The section owns each group header, boundary,
/// sibling divider, clip, and active-state geometry; callers provide only the
/// semantic label, optional metadata, rows, and row callbacks.
class CatchSectionFieldGroup {
  const CatchSectionFieldGroup({
    required this.title,
    required this.children,
    this.count,
    this.trailing,
  }) : assert(title.length > 0);

  final String title;
  final List<Widget> children;
  final Object? count;
  final Widget? trailing;
}
