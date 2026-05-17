import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';

enum EventTileStatus {
  open,
  joined,
  saved,
  recommended,
  hosted,
  waitlisted,
  attended,
  past,
  full,
  ineligible,
  cancelled,
}

class EventTileData {
  const EventTileData({
    required this.event,
    required this.status,
    this.clubName,
    this.reasonLabel,
    this.positionLabel,
  });

  factory EventTileData.fromEvent({
    required Event event,
    EventTileStatus status = EventTileStatus.open,
    String? clubName,
    String? reasonLabel,
    String? positionLabel,
  }) {
    return EventTileData(
      event: event,
      status: status,
      clubName: clubName,
      reasonLabel: reasonLabel,
      positionLabel: positionLabel,
    );
  }

  final Event event;
  final EventTileStatus status;
  final String? clubName;
  final String? reasonLabel;
  final String? positionLabel;

  String get clubId => event.clubId;
  String get eventId => event.id;
  String get title => event.title;
  String get meetingPoint => event.meetingPoint;
  String get dateLabel => event.shortDateLabel;
  String get longDateLabel => event.longDateLabel;
  String get timeLabel => EventFormatters.time(event.startTime);
  String get timeRangeLabel => event.timeRangeLabel;
  String get compactTimeRangeLabel => event.compactTimeRangeLabel;
  String get distanceLabel => event.distanceLabel;
  String get paceLabel => event.pace.label;
  String get signupLabel =>
      '${event.signedUpCount}/${event.capacityLimit} signed up';
  String get spotsLabel =>
      '${event.signedUpCount}/${event.capacityLimit} spots';
  String get priceLabel => event.priceInPaise <= 0
      ? 'Free'
      : EventFormatters.priceInPaise(event.priceInPaise);
  bool get hasExactStartingPoint => event.hasExactStartingPoint;
}
