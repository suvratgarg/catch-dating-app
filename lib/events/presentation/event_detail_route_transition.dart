import 'package:catch_dating_app/events/domain/event.dart';

enum EventDetailRouteTransition {
  platform,
  mapSelectedCard,
  ticketCard,
  spotlightCard,
}

enum EventDetailPresentationMode { standard, ticket, spotlightDark }

class EventDetailRouteExtra {
  const EventDetailRouteExtra({
    this.initialEvent,
    this.transition = EventDetailRouteTransition.platform,
    this.presentationMode = EventDetailPresentationMode.standard,
    this.heroTag,
  });

  final Event? initialEvent;
  final EventDetailRouteTransition transition;
  final EventDetailPresentationMode presentationMode;
  final Object? heroTag;
}

String eventPhotoHeroTag(String eventId) => 'event-photo-$eventId';

String eventTicketHeroTag(String eventId, String source) =>
    'event-ticket-${_heroSource(source)}-$eventId';

String eventSpotlightHeroTag(String eventId, String source) =>
    'event-spotlight-${_heroSource(source)}-$eventId';

String _heroSource(String source) {
  return source.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
}
