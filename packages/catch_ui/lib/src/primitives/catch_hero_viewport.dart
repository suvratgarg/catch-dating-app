import 'package:flutter/material.dart';

/// Shared Hero viewport for card flights with transparent Material chrome.
class CatchHeroViewport extends StatelessWidget {
  const CatchHeroViewport({
    super.key,
    required this.tag,
    required this.child,
    this.flightShuttleBuilder,
  });

  final Object tag;
  final Widget child;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      transitionOnUserGestures: true,
      flightShuttleBuilder: flightShuttleBuilder,
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}
