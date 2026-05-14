import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_tiles/run_tile_data.dart';
import 'package:flutter/material.dart';

class RunTileStatusBadge extends StatelessWidget {
  const RunTileStatusBadge({
    super.key,
    required this.status,
    this.label,
    this.uppercase = false,
  });

  final RunTileStatus status;
  final String? label;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    return CatchBadge(
      label: label ?? runTileStatusLabel(status),
      tone: runTileStatusTone(status),
      uppercase: uppercase,
      icon: runTileStatusIcon(status),
    );
  }
}

class RunTileMetaRow extends StatelessWidget {
  const RunTileMetaRow({
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
        ? CatchTextStyles.labelM(context, color: t.ink)
        : CatchTextStyles.bodyS(context, color: t.ink2);

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

class RunTileFactWrap extends StatelessWidget {
  const RunTileFactWrap({
    super.key,
    required this.data,
    this.includePrice = true,
    this.includeSpots = false,
  });

  final RunTileData data;
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

String runTileStatusLabel(RunTileStatus status) {
  return switch (status) {
    RunTileStatus.open => 'Open',
    RunTileStatus.joined => "You're in",
    RunTileStatus.saved => 'Saved',
    RunTileStatus.recommended => 'Recommended',
    RunTileStatus.hosted => 'Hosted',
    RunTileStatus.waitlisted => 'Waitlisted',
    RunTileStatus.attended => 'Attended',
    RunTileStatus.past => 'Past',
    RunTileStatus.full => 'Full',
    RunTileStatus.ineligible => 'Not eligible',
    RunTileStatus.cancelled => 'Cancelled',
  };
}

CatchBadgeTone runTileStatusTone(RunTileStatus status) {
  return switch (status) {
    RunTileStatus.open => CatchBadgeTone.neutral,
    RunTileStatus.joined => CatchBadgeTone.success,
    RunTileStatus.saved => CatchBadgeTone.brand,
    RunTileStatus.recommended => CatchBadgeTone.brand,
    RunTileStatus.hosted => CatchBadgeTone.live,
    RunTileStatus.waitlisted => CatchBadgeTone.warning,
    RunTileStatus.attended => CatchBadgeTone.success,
    RunTileStatus.past => CatchBadgeTone.neutral,
    RunTileStatus.full => CatchBadgeTone.warning,
    RunTileStatus.ineligible => CatchBadgeTone.danger,
    RunTileStatus.cancelled => CatchBadgeTone.danger,
  };
}

IconData? runTileStatusIcon(RunTileStatus status) {
  return switch (status) {
    RunTileStatus.joined => Icons.check_rounded,
    RunTileStatus.saved => Icons.bookmark_rounded,
    RunTileStatus.recommended => Icons.auto_awesome_rounded,
    RunTileStatus.hosted => Icons.admin_panel_settings_outlined,
    RunTileStatus.waitlisted => Icons.schedule_rounded,
    RunTileStatus.attended => Icons.directions_run_rounded,
    RunTileStatus.full => Icons.group_off_outlined,
    RunTileStatus.ineligible => Icons.block_rounded,
    RunTileStatus.cancelled => Icons.close_rounded,
    RunTileStatus.open || RunTileStatus.past => null,
  };
}
