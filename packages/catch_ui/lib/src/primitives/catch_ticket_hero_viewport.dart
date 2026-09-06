import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/foundations/catch_transitions.dart';
import 'package:catch_ui/src/primitives/catch_hero_viewport.dart';
import 'package:flutter/material.dart';

/// Wraps [child] in a [Hero] with a ticket-flight tag derived from [prefix]
/// and [id]. The spring-backed flight uses the shared `CatchMotion.springCurve`
/// for a bouncy, editorial-feeling transition between card and detail.
class CatchTicketHeroViewport extends StatelessWidget {
  const CatchTicketHeroViewport({
    super.key,
    required this.prefix,
    required this.id,
    required this.child,
  });

  final String prefix;
  final String id;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CatchHeroViewport(
      tag: catchTicketHeroTag(prefix, id),
      flightShuttleBuilder:
          (
            BuildContext flightContext,
            Animation<double> animation,
            HeroFlightDirection flightDirection,
            BuildContext fromHeroContext,
            BuildContext toHeroContext,
          ) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: CatchMotion.springCurve,
              reverseCurve: CatchMotion.standardCurve,
            );
            return ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
              child: Material(type: MaterialType.transparency, child: child),
            );
          },
      child: child,
    );
  }
}
