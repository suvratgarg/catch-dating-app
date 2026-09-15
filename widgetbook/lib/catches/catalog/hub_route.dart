import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/design_fixtures/catches_surface_fixtures.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_hub_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/page_preview.dart';
import '../../support/widgetbook_harness.dart';
import 'fixtures.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Hub route states',
  type: SwipeHubScreen,
  path: '[P1 product surfaces]/Catches',
)
Widget catchesHubRouteStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'SwipeHubScreen',
    contractId: 'screen.catches.hub',
    children: [
      WidgetbookPageStateCard(
        label: 'uid loading',
        child: const WidgetbookCatchesDeviceFrame(
          child: _HubRouteScope(uidValue: AsyncLoading<String?>()),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'auth error',
        child: WidgetbookCatchesDeviceFrame(
          child: _HubRouteScope(
            uidValue: AsyncError<String?>(
              StateError('Session failed'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'signed out shell-hidden',
        child: const WidgetbookCatchesDeviceFrame(
          child: _HubRouteScope(uidValue: AsyncData<String?>(null)),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'attended events loading',
        child: const WidgetbookCatchesDeviceFrame(
          child: _HubRouteScope(eventsValue: AsyncLoading<List<Event>>()),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'attended events error',
        child: WidgetbookCatchesDeviceFrame(
          child: _HubRouteScope(
            eventsValue: AsyncError<List<Event>>(
              StateError('Events failed'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'offline event load',
        child: WidgetbookCatchesDeviceFrame(
          child: _HubRouteScope(
            eventsValue: AsyncError<List<Event>>(
              widgetbookCatchesOfflineException(action: 'load attended events'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'no active windows',
        child: WidgetbookCatchesDeviceFrame(
          child: _HubRouteScope(
            eventsValue: AsyncData<List<Event>>([
              CatchesSurfaceFixtures.closedWindowEvent(),
            ]),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'active catch windows',
        child: WidgetbookCatchesDeviceFrame(
          child: _HubRouteScope(
            eventsValue: AsyncData<List<Event>>([
              CatchesSurfaceFixtures.openWindowEvent(),
              CatchesSurfaceFixtures.closingSoonEvent(),
            ]),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'text scale 2.0',
        child: const WidgetbookCatchesDeviceFrame(
          child: WidgetbookMediaOverride(
            textScaler: TextScaler.linear(2),
            child: _HubRouteScope(),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'reduced motion',
        child: const WidgetbookCatchesDeviceFrame(
          child: WidgetbookMediaOverride(
            disableAnimations: true,
            child: _HubRouteScope(),
          ),
        ),
      ),
    ],
  );
}

class _HubRouteScope extends StatelessWidget {
  const _HubRouteScope({this.uidValue, this.eventsValue});

  final AsyncValue<String?>? uidValue;
  final AsyncValue<List<Event>>? eventsValue;

  @override
  Widget build(BuildContext context) {
    final effectiveUid =
        uidValue ?? const AsyncData<String?>(CatchesSurfaceFixtures.viewerUid);
    final uid = effectiveUid.asData?.value;

    return WidgetbookFixtureScope(
      overrides: [
        uidProvider.overrideWithValue(effectiveUid),
        if (uid != null)
          watchAttendedEventsProvider(uid).overrideWithValue(
            eventsValue ??
                AsyncData<List<Event>>([
                  CatchesSurfaceFixtures.openWindowEvent(),
                  CatchesSurfaceFixtures.closingSoonEvent(),
                ]),
          ),
      ],
      child: SwipeHubScreen(now: CatchesSurfaceFixtures.now),
    );
  }
}
