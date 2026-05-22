import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/widgets/catch_metric_strip.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:flutter/material.dart';

class EventStatsGrid extends StatelessWidget {
  const EventStatsGrid({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return CatchMetricStrip(items: _statsFor(event));
  }
}

List<CatchMetricStripItem> _statsFor(Event event) {
  return [
    if (event.eventFormat.isDistanceBased)
      CatchMetricStripItem(
        value: event.distanceValueLabel,
        unit: 'km',
        label: 'Distance',
      )
    else
      CatchMetricStripItem(value: event.eventFormat.label, label: 'Activity'),
    CatchMetricStripItem(
      value: event.pace.label,
      label: _levelLabelFor(event.activityKind),
    ),
    CatchMetricStripItem(value: event.spotsLabel, label: 'Spots taken'),
  ];
}

String _levelLabelFor(ActivityKind activityKind) {
  return switch (activityKind) {
    ActivityKind.socialRun ||
    ActivityKind.running ||
    ActivityKind.walking ||
    ActivityKind.cycling => 'Pace level',
    ActivityKind.pickleball ||
    ActivityKind.padel ||
    ActivityKind.tennis ||
    ActivityKind.badminton => 'Skill level',
    ActivityKind.spinClass ||
    ActivityKind.yoga ||
    ActivityKind.strengthTraining => 'Intensity',
    ActivityKind.pubQuiz ||
    ActivityKind.barCrawl ||
    ActivityKind.dinner ||
    ActivityKind.singlesMixer ||
    ActivityKind.openActivity => 'Energy',
  };
}
