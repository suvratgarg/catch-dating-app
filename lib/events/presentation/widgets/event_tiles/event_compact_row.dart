import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_meta_row.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_capacity_presenter.dart';
import 'package:flutter/material.dart';

const double _chevronIconSize = CatchSpacing.s5;
const double _datePillWidth = CatchLayout.eventCompactDatePillWidth;
const double _datePillHeight = CatchLayout.eventCompactDatePillHeight;

class EventCompactRow extends StatelessWidget {
  const EventCompactRow({
    super.key,
    required this.event,
    this.title,
    this.subtitle,
    this.statusLabel,
    this.metaEntries,
    this.onTap,
  });

  final Event event;
  final String? title;
  final String? subtitle;
  final String? statusLabel;
  final List<CatchMetaEntry>? metaEntries;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = eventActivityVisual(event.activityKind, context: context);
    final capacity = EventCapacityPresenter(event);
    final effectiveStatus = statusLabel?.trim();
    final entries =
        metaEntries ??
        [
          CatchMetaEntry(
            icon: CatchIcons.clock,
            label:
                '${EventFormatters.shortDate(event.startTime)} · ${event.compactTimeRangeLabel}',
          ),
          CatchMetaEntry(
            icon: activityKindGlyph(event.activityKind),
            label: event.activitySummaryLabel,
          ),
          CatchMetaEntry(
            icon: CatchIcons.group,
            label: capacity.goingAvailabilityLabel(),
          ),
        ];

    return CatchSurface(
      onTap: onTap,
      borderColor: t.line,
      backgroundColor: t.surface,
      padding: CatchInsets.contentDense,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EventCompactDatePill(date: event.startTime, accent: visual.accent),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title ?? event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.sectionTitle(
                          context,
                          color: t.ink,
                        ),
                      ),
                    ),
                    if (effectiveStatus != null &&
                        effectiveStatus.isNotEmpty) ...[
                      gapW8,
                      CatchBadge(label: effectiveStatus),
                    ],
                  ],
                ),
                gapH4,
                Text(
                  subtitle ?? event.locationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
                gapH8,
                CatchMetaDotRow(entries: entries),
              ],
            ),
          ),
          gapW8,
          Icon(
            CatchIcons.chevronRightRounded,
            size: _chevronIconSize,
            color: t.ink3,
          ),
        ],
      ),
    );
  }
}

class _EventCompactDatePill extends StatelessWidget {
  const _EventCompactDatePill({required this.date, required this.accent});

  final DateTime date;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      width: _datePillWidth,
      height: _datePillHeight,
      radius: CatchRadius.md,
      backgroundColor: accent.withValues(alpha: CatchOpacity.subtleFill),
      borderColor: accent.withValues(alpha: CatchOpacity.subtleBorder),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            EventFormatters.shortMonth(date).toUpperCase(),
            style: CatchTextStyles.labelS(context, color: accent),
          ),
          gapH2,
          Text(
            '${date.day}',
            style: CatchTextStyles.titleL(context, color: t.ink),
          ),
        ],
      ),
    );
  }
}
