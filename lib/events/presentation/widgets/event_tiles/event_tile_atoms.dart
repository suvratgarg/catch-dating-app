import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tile_data.dart';
import 'package:flutter/material.dart';

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
    EventTileStatus.hosted => CatchBadgeTone.live,
    EventTileStatus.waitlisted => CatchBadgeTone.warning,
    EventTileStatus.attended => CatchBadgeTone.success,
    EventTileStatus.past => CatchBadgeTone.neutral,
    EventTileStatus.full => CatchBadgeTone.warning,
    EventTileStatus.ineligible => CatchBadgeTone.danger,
    EventTileStatus.cancelled => CatchBadgeTone.danger,
  };
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
