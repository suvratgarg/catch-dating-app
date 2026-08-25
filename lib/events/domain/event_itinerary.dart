import 'package:catch_dating_app/events/domain/event_meeting_location.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_itinerary.freezed.dart';
part 'event_itinerary.g.dart';

enum EventItineraryKind {
  gather,
  activity,
  stop,
  breakTime,
  transition,
  finish,
}

String _itineraryKindToJson(EventItineraryKind value) =>
    value == EventItineraryKind.breakTime ? 'break' : value.name;

EventItineraryKind _itineraryKindFromJson(String value) => value == 'break'
    ? EventItineraryKind.breakTime
    : EventItineraryKind.values.byName(value);

/// One public entry in an event's persisted run of show.
///
/// [offsetMinutes] is relative to the event start so rescheduling an event does
/// not require rewriting its itinerary.
@freezed
abstract class EventItineraryItem with _$EventItineraryItem {
  const EventItineraryItem._();

  const factory EventItineraryItem({
    required String id,
    @JsonKey(fromJson: _itineraryKindFromJson, toJson: _itineraryKindToJson)
    required EventItineraryKind kind,
    required int offsetMinutes,
    int? durationMinutes,
    required String title,
    String? description,
    EventMeetingLocation? location,
    int? routeDistanceMeters,
  }) = _EventItineraryItem;

  factory EventItineraryItem.fromJson(Map<String, dynamic> json) =>
      _$EventItineraryItemFromJson(json);

  DateTime startsAt(DateTime eventStart) =>
      eventStart.add(Duration(minutes: offsetMinutes));
}
