import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable page-transition and tap-feedback helpers that encode the Catch
/// motion personality (spring + haptic) so signature motion isn't limited to
/// the Explore surface.
///
/// See: `docs/design_language.md` §7, `docs/ui_elevation_implementation.md` §1c.

/// Light tap-feedback haptic — used for button taps, filter toggles, and row
/// selections. Mirrors the Explore filter-rail pattern but is surface-agnostic.
void catchSelectionHaptic() {
  HapticFeedback.selectionClick();
}

/// Medium-impact haptic for gesture-driven transitions (sheet reveals,
/// map snap, momentum-driven state changes).
void catchTransitionHaptic() {
  HapticFeedback.lightImpact();
}

/// Standard detail-route transition for surfaces that expand from cards,
/// tickets, or list rows. Keep route chrome calm: fade first, then a small
/// spring-scale settle.
Widget catchFadeScalePageTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final curvedAnimation = CurvedAnimation(
    parent: animation,
    curve: CatchMotion.standardCurve,
    reverseCurve: CatchMotion.easeInCubicCurve,
  );
  final scale = Tween<double>(begin: 0.985, end: 1).animate(curvedAnimation);
  return FadeTransition(
    opacity: curvedAnimation,
    child: ScaleTransition(scale: scale, child: child),
  );
}

/// Shared Hero wrapper for editorial card/ticket flights. Use this instead of
/// ad-hoc `Hero` wrappers so all ticket-like transitions keep gesture support
/// and transparent Material chrome consistent.
Widget catchHeroSurface({
  required Object tag,
  required Widget child,
  HeroFlightShuttleBuilder? flightShuttleBuilder,
}) {
  return Hero(
    tag: tag,
    transitionOnUserGestures: true,
    flightShuttleBuilder: flightShuttleBuilder,
    child: Material(type: MaterialType.transparency, child: child),
  );
}

/// Hero flight tag builder for event/club ticket transitions.
///
/// Construct a consistent [Hero] tag from a prefix and an id so the card and
/// detail page share the same tag automatically. Use [CatchTicketHero] as the
/// wrapping widget for the shared ticket-Hero animation.
Object catchTicketHeroTag(String prefix, String id) =>
    '$prefix-ticket-hero-$id';

/// Wraps [child] in a [Hero] with a ticket-flight tag derived from [prefix]
/// and [id]. The spring-backed flight uses the shared `CatchMotion.springCurve`
/// for a bouncy, editorial-feeling transition between card and detail.
class CatchTicketHero extends StatelessWidget {
  const CatchTicketHero({
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
    return catchHeroSurface(
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
