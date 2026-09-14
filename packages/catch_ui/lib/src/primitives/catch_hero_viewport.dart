import 'package:catch_ui/src/foundations/catch_transitions.dart';
import 'package:catch_ui/src/primitives/catch_reveal_viewport.dart';
import 'package:flutter/material.dart';

/// Shared Hero viewport for card flights with transparent Material chrome.
class CatchHeroViewport extends StatelessWidget {
  const CatchHeroViewport({
    super.key,
    required Object this._tag,
    required this.child,
    this._flightShuttleBuilder,
  }) : _ticketPrefix = null,
       _ticketId = null;

  /// Shared ticket tag and spring-backed flight, with transparent Material.
  const CatchHeroViewport.ticket({
    super.key,
    required String prefix,
    required String id,
    required this.child,
  }) : _tag = null,
       _flightShuttleBuilder = null,
       _ticketPrefix = prefix,
       _ticketId = id;

  final Object? _tag;
  final String? _ticketPrefix;
  final String? _ticketId;
  final Widget child;
  final HeroFlightShuttleBuilder? _flightShuttleBuilder;

  Object get tag => _tag ?? catchTicketHeroTag(_ticketPrefix!, _ticketId!);

  HeroFlightShuttleBuilder? get flightShuttleBuilder =>
      _flightShuttleBuilder ??
      (_ticketPrefix == null
          ? null
          : (context, animation, direction, from, to) =>
                CatchRevealViewport.flight(
                  animation: animation,
                  child: Material(
                    type: MaterialType.transparency,
                    child: child,
                  ),
                ));

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
