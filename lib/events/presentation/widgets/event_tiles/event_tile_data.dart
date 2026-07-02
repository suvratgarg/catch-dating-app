import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/event_capacity_presenter.dart';

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
  String get meetingPoint => event.locationName;
  String get dateLabel => event.shortDateLabel;
  String get longDateLabel => event.longDateLabel;
  String get timeLabel => EventFormatters.time(event.startTime);
  String get timeRangeLabel => event.timeRangeLabel;
  String get compactTimeRangeLabel => event.compactTimeRangeLabel;
  String get distanceLabel => event.distanceLabel;
  String get paceLabel => event.pace.label;
  String get activitySummaryLabel => event.activitySummaryLabel;
  EventCapacityPresenter get capacity => EventCapacityPresenter(event);
  String get signupLabel => capacity.signedUpFractionLabel;
  String get spotsLabel => capacity.spotsFractionLabel;
  String get capacityLabel => capacity.goingAvailabilityLabel();
  String get attendeeConfirmedLabel => capacity.attendeeConfirmedLabel;
  String get priceLabel => event.priceInPaise <= 0
      ? 'Free'
      : event.effectiveEventPolicy.usesDemandPricing
      ? 'From ${EventFormatters.priceInPaise(event.priceInPaise, currencyCode: event.currency)}'
      : EventFormatters.priceInPaise(
          event.priceInPaise,
          currencyCode: event.currency,
        );
  bool get hasExactStartingPoint => event.hasExactStartingPoint;
}
