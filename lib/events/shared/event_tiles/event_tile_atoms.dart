import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_tile_data.dart';
import 'package:flutter/material.dart';

String eventTileKickerLabel(EventTileData data, {required bool showClubName}) {
  final clubName = data.clubName?.trim();
  if (showClubName && clubName != null && clubName.isNotEmpty) {
    return clubName;
  }
  final meetingPoint = data.meetingPoint.trim();
  if (meetingPoint.isNotEmpty) return meetingPoint;
  if (clubName != null && clubName.isNotEmpty) return clubName;
  return data.title;
}

String? eventTileSupportingLabel(
  EventTileData data, {
  required bool showClubName,
}) {
  final activity = data.activitySummaryLabel.trim();
  final meetingPoint = data.meetingPoint.trim();
  if (showClubName && meetingPoint.isNotEmpty) {
    return _joinEventTileLabels([activity, meetingPoint]);
  }
  if (activity.isNotEmpty && activity != data.title.trim()) return activity;
  return null;
}

String eventTileStatusLabel(EventTileStatus status) {
  return switch (status) {
    EventTileStatus.open => 'Open',
    EventTileStatus.joined => "You're in",
    EventTileStatus.saved => 'Saved',
    EventTileStatus.recommended => 'Recommended',
    EventTileStatus.hosted => 'Hosted',
    EventTileStatus.waitlisted => 'Waitlisted',
    EventTileStatus.attended => 'Attended',
    EventTileStatus.past => 'Past',
    EventTileStatus.full => 'Full',
    EventTileStatus.ineligible => 'Not eligible',
    EventTileStatus.cancelled => 'Cancelled',
  };
}

EventTileStatus eventTileStatusForBadge(String? badgeLabel) {
  return switch (badgeLabel?.toUpperCase()) {
    'JOINED' => EventTileStatus.joined,
    'SAVED' => EventTileStatus.saved,
    'PAST' => EventTileStatus.past,
    'WAITLISTED' => EventTileStatus.waitlisted,
    'ATTENDED' => EventTileStatus.attended,
    'HOSTED' => EventTileStatus.hosted,
    'FULL' => EventTileStatus.full,
    _ => EventTileStatus.open,
  };
}

String? eventTileCardStatusLabel(EventTileStatus status, {String? label}) {
  final explicit = label?.trim();
  if (explicit != null && explicit.isNotEmpty) {
    if (explicit.toUpperCase() == 'VIEW') return null;
    return explicit;
  }
  if (status == EventTileStatus.open) return null;
  return eventTileStatusLabel(status);
}

CatchBadgeTone eventTileStatusTone(EventTileStatus status) {
  return switch (status) {
    EventTileStatus.open => CatchBadgeTone.neutral,
    EventTileStatus.joined => CatchBadgeTone.success,
    EventTileStatus.saved => CatchBadgeTone.brand,
    EventTileStatus.recommended => CatchBadgeTone.brand,
    EventTileStatus.hosted => CatchBadgeTone.brand,
    EventTileStatus.waitlisted => CatchBadgeTone.warning,
    EventTileStatus.attended => CatchBadgeTone.success,
    EventTileStatus.past => CatchBadgeTone.neutral,
    EventTileStatus.full => CatchBadgeTone.warning,
    EventTileStatus.ineligible => CatchBadgeTone.danger,
    EventTileStatus.cancelled => CatchBadgeTone.danger,
  };
}

Map<DateTime, List<T>> groupEventDateRailItems<T>(
  Iterable<T> items, {
  required DateTime Function(T item) startTimeOf,
  bool preserveInputOrder = false,
}) {
  final sorted = preserveInputOrder
      ? items.toList(growable: false)
      : (items.toList(growable: false)
          ..sort((a, b) => startTimeOf(a).compareTo(startTimeOf(b))));
  final grouped = <DateTime, List<T>>{};
  for (final item in sorted) {
    final day = DateUtils.dateOnly(startTimeOf(item));
    grouped.putIfAbsent(day, () => <T>[]).add(item);
  }
  return grouped;
}

String eventDateRailDayLabel(DateTime date, DateTime today) {
  if (DateUtils.isSameDay(date, today)) return 'Today';
  return '${EventFormatters.shortWeekday(date)} · ${date.day} ${EventFormatters.shortMonth(date)}';
}

IconData? eventTileStatusIcon(EventTileStatus status) {
  return switch (status) {
    EventTileStatus.joined => CatchIcons.checkRounded,
    EventTileStatus.saved => CatchIcons.bookmarkRounded,
    EventTileStatus.recommended => CatchIcons.autoAwesomeRounded,
    EventTileStatus.hosted => CatchIcons.adminPanelSettingsOutlined,
    EventTileStatus.waitlisted => CatchIcons.scheduleRounded,
    EventTileStatus.attended => CatchIcons.directionsRunRounded,
    EventTileStatus.full => CatchIcons.groupOffOutlined,
    EventTileStatus.ineligible => CatchIcons.blockRounded,
    EventTileStatus.cancelled => CatchIcons.closeRounded,
    EventTileStatus.open || EventTileStatus.past => null,
  };
}

String _joinEventTileLabels(Iterable<String> labels) {
  return labels
      .map((label) => label.trim())
      .where((label) => label.isNotEmpty)
      .join(' · ');
}
