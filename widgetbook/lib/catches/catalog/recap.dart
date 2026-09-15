import 'package:catch_dating_app/design_fixtures/catches_surface_fixtures.dart';
import 'package:catch_dating_app/swipes/presentation/event_recap_screen.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/contract_preview.dart';
import '../../support/page_preview.dart';
import 'fixtures.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Loading composition',
  type: EventRecapLoadingBody,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget eventRecapLoadingBodyStates(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'EventRecapLoadingBody',
    contractId: 'screen.catches.recap.loading',
    children: [
      WidgetbookPageStateCard(
        label: 'content skeleton',
        child: WidgetbookCatchesDeviceFrame(child: EventRecapLoadingBody()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Ready body states',
  type: EventRecapReadyBody,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget eventRecapReadyBodyStates(BuildContext context) {
  final event = CatchesSurfaceFixtures.closedWindowEvent();
  final attendeeIds = CatchesSurfaceFixtures.candidates
      .map((profile) => profile.uid)
      .toList(growable: false);

  return WidgetbookPageCatalogFrame(
    title: 'EventRecapReadyBody',
    contractId: 'screen.catches.recap.ready_body',
    children: [
      WidgetbookPageStateCard(
        label: 'checked-in roster',
        child: WidgetbookCatchesDeviceFrame(
          child: WidgetbookCatchesRecapReadyBodyPreview(
            event: event,
            attendeeIds: attendeeIds,
            selectedVibeIds: const <String>{},
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'selected vibe tile',
        child: WidgetbookCatchesDeviceFrame(
          child: WidgetbookCatchesRecapReadyBodyPreview(
            event: event,
            attendeeIds: attendeeIds,
            selectedVibeIds: const {CatchesSurfaceFixtures.secondCandidateUid},
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'empty roster',
        child: WidgetbookCatchesDeviceFrame(
          child: WidgetbookCatchesRecapReadyBodyPreview(
            event: event,
            attendeeIds: const <String>[],
            selectedVibeIds: const <String>{},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Vibe grid states',
  type: VibeGrid,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget eventRecapVibeGridStates(BuildContext context) {
  final event = CatchesSurfaceFixtures.closedWindowEvent();
  final attendeeIds = CatchesSurfaceFixtures.candidates
      .map((profile) => profile.uid)
      .toList(growable: false);
  final partialAttendeeIds = [
    CatchesSurfaceFixtures.candidateUid,
    widgetbookCatchesMissingRecapProfileUid,
  ];
  final partialRoster = {
    CatchesSurfaceFixtures.candidateUid:
        CatchesSurfaceFixtures.candidates.first,
  };

  return WidgetbookPageCatalogFrame(
    title: 'VibeGrid',
    contractId: 'component.catches.recap.vibe_grid',
    children: [
      WidgetbookPageStateCard(
        label: 'profile tiles',
        child: VibeGrid(
          rows: widgetbookCatchesRecapReadyState(
            context,
            event: event,
            attendeeIds: attendeeIds,
          ).attendeeRows,
          onToggleVibe: widgetbookIgnoreString,
        ),
      ),
      WidgetbookPageStateCard(
        label: 'selected and fallback',
        child: VibeGrid(
          rows: widgetbookCatchesRecapReadyState(
            context,
            event: event,
            attendeeIds: partialAttendeeIds,
            rosterProfiles: partialRoster,
            selectedVibeIds: const {CatchesSurfaceFixtures.candidateUid},
          ).attendeeRows,
          onToggleVibe: widgetbookIgnoreString,
        ),
      ),
    ],
  );
}
