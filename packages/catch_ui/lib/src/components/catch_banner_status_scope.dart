import 'package:catch_ui/src/components/catch_banner_status.dart';
import 'package:flutter/widgets.dart';

/// Publishes context without drawing it. Canonical screen owners consume this
/// scope once, below their title and optional primary rail, and clear it for
/// nested content. The app publishes connectivity above the route navigator;
/// route-specific rehearsal context is supplied to its scaffold's typed slot.
class CatchBannerStatusScope extends InheritedWidget {
  const CatchBannerStatusScope({
    super.key,
    required this.statuses,
    required super.child,
  });

  final List<CatchBannerStatus> statuses;

  static List<CatchBannerStatus> of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<CatchBannerStatusScope>()
          ?.statuses ??
      const [];

  @override
  bool updateShouldNotify(CatchBannerStatusScope oldWidget) =>
      statuses != oldWidget.statuses;
}
