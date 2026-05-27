import 'package:catch_dating_app/events/domain/event.dart';

enum EventDetailRouteTransition { platform, mapSelectedCard }

class EventDetailRouteExtra {
  const EventDetailRouteExtra({
    this.initialEvent,
    this.transition = EventDetailRouteTransition.platform,
  });

  final Event? initialEvent;
  final EventDetailRouteTransition transition;
}

String eventPhotoHeroTag(String eventId) => 'event-photo-$eventId';
