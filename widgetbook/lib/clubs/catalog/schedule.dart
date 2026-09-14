import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_schedule_section.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import '../../support/page_preview.dart';
import 'fixtures.dart';
import 'preview.dart';

final _sameDayScheduleEvents = [
  widgetbookClubEvent(
    id: 'widgetbook-thursday-dawn-5k',
    startTime: DateTime(2026, 6, 25, 6, 30),
    meetingPoint: 'Bandra Fort gate',
    distanceKm: 5,
    bookedCount: 12,
    capacityLimit: 18,
    description: 'A steady start for weekday regulars.',
  ),
  widgetbookClubEvent(
    id: 'widgetbook-thursday-evening-8k',
    startTime: DateTime(2026, 6, 25, 18, 15),
    meetingPoint: 'Carter Road amphitheatre',
    distanceKm: 8,
    bookedCount: 17,
    capacityLimit: 20,
    description: 'A social evening loop with a cool-down walk.',
  ),
];

@widgetbook.UseCase(
  name: 'Schedule states',
  type: ClubScheduleSection,
  path: '[Club Detail]/Sections',
)
Widget clubScheduleSectionStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubScheduleSection',
    catalogId: 'section.club.schedule',
    children: [
      WidgetbookPageStateCard(
        label: 'upcoming events',
        child: WidgetbookClubSliverFrame(
          height: WidgetbookPreviewLayout.defaultPhonePreviewHeight,
          slivers: [ClubScheduleSection(events: widgetbookClubEvents)],
        ),
      ),
      WidgetbookPageStateCard(
        label: 'same-day strip',
        child: WidgetbookClubSliverFrame(
          height: WidgetbookPreviewLayout.feedbackViewportHeight,
          slivers: [ClubScheduleSection(events: _sameDayScheduleEvents)],
        ),
      ),
      WidgetbookPageStateCard(
        label: 'hosted events',
        child: WidgetbookClubSliverFrame(
          height: WidgetbookPreviewLayout.feedbackViewportHeight,
          slivers: [
            ClubScheduleSection(events: _sameDayScheduleEvents, isHost: true),
          ],
        ),
      ),
      WidgetbookPageStateCard(
        label: 'empty consumer',
        child: const WidgetbookClubSliverFrame(
          height: WidgetbookPreviewLayout.routeViewportHeight,
          slivers: [ClubScheduleSection(events: [])],
        ),
      ),
      WidgetbookPageStateCard(
        label: 'empty host',
        child: const WidgetbookClubSliverFrame(
          height: WidgetbookPreviewLayout.routeViewportHeight,
          slivers: [ClubScheduleSection(events: [], isHost: true)],
        ),
      ),
    ],
  );
}
