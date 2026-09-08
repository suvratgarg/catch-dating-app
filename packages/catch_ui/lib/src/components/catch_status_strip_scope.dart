import 'package:catch_ui/src/components/catch_status_strip_data.dart';
import 'package:flutter/widgets.dart';

/// Publishes context without drawing it. Canonical screen owners consume this
/// scope once, below their title and optional primary rail, and clear it for
/// nested content. The app publishes connectivity above the route navigator;
/// route-specific rehearsal context is supplied to its scaffold's typed slot.
class CatchStatusStripScope extends InheritedWidget {
  const CatchStatusStripScope({
    super.key,
    required this.statuses,
    required super.child,
  });

  final List<CatchStatusStripData> statuses;

  static List<CatchStatusStripData> of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<CatchStatusStripScope>()
          ?.statuses ??
      const [];

  @override
  bool updateShouldNotify(CatchStatusStripScope oldWidget) =>
      statuses != oldWidget.statuses;
}
