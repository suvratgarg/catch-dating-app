import 'package:catch_dating_app/design_fixtures/catches_surface_fixtures.dart';
import 'package:catch_dating_app/swipes/presentation/catches_hub_screen_state.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_hub_screen.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/attended_event_tile.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import '../../support/contract_preview.dart';
import '../../support/page_preview.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Hub composition',
  type: CatchesHubContent,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget catchesHubContentStates(BuildContext context) {
  final ready = _hubReadyState();

  return WidgetbookPageCatalogFrame(
    title: 'CatchesHubContent',
    contractId: 'screen.catches.hub sections',
    children: [
      WidgetbookPageStateCard(
        label: 'active windows',
        child: WidgetbookCatchesDeviceFrame(
          child: CatchesHubContent(
            state: ready,
            onOpenCatch: _ignoreCatchesRow,
            onOpenRecap: _ignoreCatchesRow,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'text scale 2.0',
        child: WidgetbookCatchesDeviceFrame(
          child: WidgetbookMediaOverride(
            textScaler: const TextScaler.linear(2),
            child: CatchesHubContent(
              state: ready,
              onOpenCatch: _ignoreCatchesRow,
              onOpenRecap: _ignoreCatchesRow,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Intro card states',
  type: CatchesIntroCard,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget catchesIntroCardStates(BuildContext context) {
  final rows = _hubRows();

  return WidgetbookPageCatalogFrame(
    title: 'CatchesIntroCard',
    contractId: 'screen.catches.hub.intro',
    children: [
      WidgetbookPageStateCard(
        label: 'window open',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.profileSectionPreviewHeight,
          child: Padding(
            padding: CatchInsets.content,
            child: CatchesIntroCard(row: rows.first, onTap: widgetbookNoop),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'closing soon',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.profileSectionPreviewHeight,
          child: Padding(
            padding: CatchInsets.content,
            child: CatchesIntroCard(row: rows.last, onTap: widgetbookNoop),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Tile states',
  type: AttendedEventTile,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget attendedEventTileStates(BuildContext context) {
  final rows = _hubRows();

  return WidgetbookPageCatalogFrame(
    title: 'AttendedEventTile',
    contractId: 'screen.catches.hub.event_tile',
    children: [
      WidgetbookPageStateCard(
        label: 'open and closing soon',
        child: Center(
          child: WidgetbookContentFrame(
            child: Padding(
              padding: CatchInsets.content,
              child: Column(
                children: [
                  AttendedEventTile(
                    row: rows.first,
                    onOpenCatch: widgetbookNoop,
                    onOpenRecap: widgetbookNoop,
                  ),
                  gapH12,
                  AttendedEventTile(
                    row: rows.last,
                    onOpenCatch: widgetbookNoop,
                    onOpenRecap: widgetbookNoop,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Empty states',
  type: CatchesHubEmptyState,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget catchesHubEmptyStateStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'CatchesHubEmptyState',
    contractId: 'screen.catches.hub.empty',
    children: [
      WidgetbookPageStateCard(
        label: 'no active catches',
        child: WidgetbookCatchesDeviceFrame(
          child: CatchesHubEmptyState(onFindEvent: widgetbookNoop),
        ),
      ),
    ],
  );
}

List<CatchesHubEventRow> _hubRows() {
  return catchesHubRowsFromEvents([
    CatchesSurfaceFixtures.openWindowEvent(),
    CatchesSurfaceFixtures.closingSoonEvent(),
  ], now: CatchesSurfaceFixtures.now);
}

CatchesHubReady _hubReadyState() {
  return CatchesHubReady(
    uid: CatchesSurfaceFixtures.viewerUid,
    rows: _hubRows(),
  );
}

void _ignoreCatchesRow(CatchesHubEventRow row) {}
