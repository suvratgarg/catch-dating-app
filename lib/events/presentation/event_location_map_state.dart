import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_location_links.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';

class EventLocationMapState {
  const EventLocationMapState._({
    required this.event,
    required this.enableNetworkTiles,
  });

  factory EventLocationMapState.fromEvent(
    Event event, {
    bool enableNetworkTiles = true,
  }) {
    return EventLocationMapState._(
      event: event,
      enableNetworkTiles: enableNetworkTiles,
    );
  }

  final Event event;
  final bool enableNetworkTiles;

  LocationCoordinate get startingPoint => LocationCoordinate(
    event.effectiveStartingPointLat,
    event.effectiveStartingPointLng,
  );

  Uri get directionsUri => directionsUriForEvent(event);

  String get locationName => event.locationName;

  String? get locationNotes {
    final notes = event.locationNotes;
    if (notes == null || notes.isEmpty) return null;
    return notes;
  }
}
