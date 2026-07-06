import 'package:catch_dating_app/events/shared/event_tiles/event_date_rail_card.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_tile_atoms.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_tile_data.dart';
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
      kicker: eventTileKickerLabel(data, showClubName: showClubName),
      supportingLabel: eventTileSupportingLabel(
        data,
        showClubName: showClubName,
      ),
      priceLabel: data.priceLabel,
      statusLabel: eventTileCardStatusLabel(data.status, label: badgeLabel),
      onTap: onTap,
    );
  }
}
