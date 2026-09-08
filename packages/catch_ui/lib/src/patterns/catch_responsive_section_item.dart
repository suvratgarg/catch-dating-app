import 'package:catch_ui/src/patterns/catch_responsive_section_lane.dart';
import 'package:flutter/widgets.dart';

@immutable
class CatchResponsiveSectionItem {
  const CatchResponsiveSectionItem({
    required this.child,
    this.lane = CatchResponsiveSectionLane.primary,
  });

  final Widget child;
  final CatchResponsiveSectionLane lane;
}
