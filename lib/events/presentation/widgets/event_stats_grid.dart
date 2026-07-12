import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/widgets/catch_metric_strip.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_surface_style.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class EventStatsGrid extends StatelessWidget {
  const EventStatsGrid({super.key, required this.event, this.surfaceStyle});

  final Event event;
  final EventDetailSurfaceStyle? surfaceStyle;

  @override
  Widget build(BuildContext context) {
    final style = surfaceStyle;
    return CatchMetricStrip(
      items: _statsFor(event, context.l10n),
      backgroundColor: style?.surfaceBackground,
      borderColor: style?.borderColor,
      dividerColor: style?.dividerColor,
      valueColor: style?.headingColor,
      unitColor: style?.bodyColor,
      labelColor: style?.mutedColor,
    );
  }
}

List<CatchMetricStripItem> _statsFor(Event event, AppLocalizations l10n) {
  return [
    if (event.eventFormat.isDistanceBased)
      CatchMetricStripItem(
        value: event.distanceValueLabel,
        unit: l10n.eventsEventStatsGridVisiblecopyKm,
        label: l10n.eventsEventStatsGridLabelDistance,
      )
    else
      CatchMetricStripItem(
        value: event.eventFormat.label,
        label: l10n.eventsEventStatsGridLabelActivity,
      ),
    CatchMetricStripItem(
      value: event.pace.label,
      label: _levelLabelFor(event.activityKind, l10n),
    ),
    CatchMetricStripItem(
      value: event.spotsLabel,
      label: l10n.eventsEventStatsGridLabelSpotsTaken,
    ),
  ];
}

String _levelLabelFor(ActivityKind activityKind, AppLocalizations l10n) {
  return switch (activityKind) {
    ActivityKind.socialRun ||
    ActivityKind.running ||
    ActivityKind.walking ||
    ActivityKind.cycling => l10n.eventsEventStatsGridVisiblecopyPaceLevel,
    ActivityKind.pickleball ||
    ActivityKind.padel ||
    ActivityKind.tennis ||
    ActivityKind.badminton => l10n.eventsEventStatsGridVisiblecopySkillLevel,
    ActivityKind.spinClass ||
    ActivityKind.yoga ||
    ActivityKind.strengthTraining =>
      l10n.eventsEventStatsGridVisiblecopyIntensity,
    ActivityKind.pubQuiz ||
    ActivityKind.barCrawl ||
    ActivityKind.dinner ||
    ActivityKind.singlesMixer ||
    ActivityKind.openActivity => l10n.eventsEventStatsGridVisiblecopyEnergy,
  };
}
