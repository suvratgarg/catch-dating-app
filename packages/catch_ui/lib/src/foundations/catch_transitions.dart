import 'package:flutter/services.dart';

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

/// Hero flight tag builder for event/club ticket transitions.
///
/// Construct a consistent Hero tag from a prefix and an id so the card and
/// detail page share the same tag automatically. Use the CatchTicketHeroViewport as the
/// wrapping widget for the shared ticket-Hero animation.
Object catchTicketHeroTag(String prefix, String id) =>
    '$prefix-ticket-hero-$id';
