import 'package:catch_ui/src/patterns/catch_section_list_placement.dart';
import 'package:flutter/widgets.dart';

@immutable
class CatchSectionListItem {
  const CatchSectionListItem({
    required this.child,
    this.lane = CatchSectionListPlacement.primary,
  });

  final Widget child;
  final CatchSectionListPlacement lane;
}
