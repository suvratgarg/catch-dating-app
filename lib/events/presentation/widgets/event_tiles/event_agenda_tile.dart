import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_date_rail_card.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tile_atoms.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tile_data.dart';
import 'package:flutter/material.dart';

class EventAgendaTile extends StatelessWidget {
  const EventAgendaTile({
    super.key,
    required this.data,
    this.onTap,
    this.showClubName = false,
    this.badgeLabel,
  });

  final EventTileData data;
  final VoidCallback? onTap;
  final bool showClubName;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    return EventDateRailCard(
      event: data.event,
      kicker: _kickerFor(data, showClubName: showClubName),
      priceLabel: data.priceLabel,
      statusLabel: _statusLabelFor(data, badgeLabel),
      onTap: onTap,
    );
  }
}

String _kickerFor(EventTileData data, {required bool showClubName}) {
  final clubName = data.clubName?.trim();
  if (showClubName && clubName != null && clubName.isNotEmpty) {
    return clubName;
  }
  final meetingPoint = data.meetingPoint.trim();
  if (meetingPoint.isNotEmpty) return meetingPoint;
  if (clubName != null && clubName.isNotEmpty) return clubName;
  return data.title;
}

String? _statusLabelFor(EventTileData data, String? badgeLabel) {
  return eventTileCardStatusLabel(data.status, label: badgeLabel);
}
