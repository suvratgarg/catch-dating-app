import 'package:flutter/widgets.dart';

/// Session-scoped startup state shared with route-owned welcome surfaces.
///
/// The consumer cold-start reel and [WelcomePage] use the same visual scene.
/// This scope prevents the route from replaying that reel after bootstrap.
class CatchStartupAnimationScope extends InheritedWidget {
  const CatchStartupAnimationScope({
    required this.consumerWelcomeReelPlayed,
    required super.child,
    super.key,
  });

  final bool consumerWelcomeReelPlayed;

  static CatchStartupAnimationScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CatchStartupAnimationScope>();
  }

  @override
  bool updateShouldNotify(CatchStartupAnimationScope oldWidget) {
    return consumerWelcomeReelPlayed != oldWidget.consumerWelcomeReelPlayed;
  }
}
