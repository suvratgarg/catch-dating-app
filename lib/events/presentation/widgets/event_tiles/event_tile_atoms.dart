import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tile_data.dart';
import 'package:flutter/material.dart';

class EventTileStatusBadge extends StatelessWidget {
  const EventTileStatusBadge({
    super.key,
    required this.status,
    this.label,
    this.uppercase = false,
  });

  final EventTileStatus status;
  final String? label;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    return CatchBadge(
      label: label ?? eventTileStatusLabel(status),
      tone: eventTileStatusTone(status),
      uppercase: uppercase,
      icon: eventTileStatusIcon(status),
    );
  }
}

class EventTileMetaRow extends StatelessWidget {
  const EventTileMetaRow({
    super.key,
    required this.icon,
    required this.label,
    this.maxLines = 1,
    this.emphasize = false,
    this.iconSize = 16,
  });

  final IconData icon;
  final String label;
  final int maxLines;
  final bool emphasize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final style = emphasize
        ? CatchTextStyles.statusLabel(context, color: t.ink)
        : CatchTextStyles.supporting(context, color: t.ink2);

    return Row(
      crossAxisAlignment: maxLines == 1
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Icon(icon, size: iconSize, color: t.ink3),
        gapW6,
        Expanded(
          child: Text(
            label,
            style: style,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class EventTileFactWrap extends StatelessWidget {
  const EventTileFactWrap({
    super.key,
    required this.data,
    this.includePrice = true,
    this.includeSpots = false,
  });

  final EventTileData data;
  final bool includePrice;
  final bool includeSpots;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s1,
      runSpacing: CatchSpacing.s1,
      children: [
        CatchBadge(label: data.distanceLabel, tone: CatchBadgeTone.brand),
        CatchBadge(label: data.paceLabel, tone: CatchBadgeTone.neutral),
        if (includePrice)
          CatchBadge(label: data.priceLabel, tone: CatchBadgeTone.neutral),
        if (includeSpots)
          CatchBadge(label: data.spotsLabel, tone: CatchBadgeTone.neutral),
      ],
    );
  }
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
