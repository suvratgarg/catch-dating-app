import 'dart:async';

import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_sheet.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_private_event_setup_inventory_section.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';

const _city = EventSetupCity(
  cityId: 'in-mh-mumbai',
  marketId: 'in-mh-mumbai',
);

const _saved = PrivateEventSetupInventoryItem(
  eventId: 'event-1',
  name: 'Saturday mixer',
  city: _city,
  localDate: '2026-09-26',
  localStartTime: '19:00',
  timezone: 'Asia/Kolkata',
  startTimeMillis: 1790449200000,
  setupRevision: 1,
  detailsConfigured: false,
);

void main() {
  test('manager inventory validates every returned private item and cursor', () {
    final body = <String, Object?>{
      'events': [
        {
          'eventId': 'event-1',
          'name': 'Saturday mixer',
          'city': {'cityId': 'in-mh-mumbai', 'marketId': 'in-mh-mumbai'},
          'localDate': '2026-09-26',
          'localStartTime': '19:00',
          'timezone': 'Asia/Kolkata',
          'startTimeMillis': 1790449200000,
          'setupRevision': 1,
          'status': 'active',
          'detailsConfigured': false,
        },
      ],
      'nextCursor': 'next_page',
    };
    final page = PrivateEventSetupInventoryPage.fromResponse(body);
    expect(page.events.single.eventId, 'event-1');
    expect(page.nextCursor, 'next_page');
    final item = Map<String, Object?>.from((body['events'] as List).single as Map);
    expect(
      () => PrivateEventSetupInventoryPage.fromResponse({
        ...body,
        'events': [{...item, 'status': 'cancelled'}],
      }),
      throwsFormatException,
    );
    expect(
      () => PrivateEventSetupInventoryPage.fromResponse({
        ...body,
        'events': [item, item],
      }),
      throwsFormatException,
    );
    expect(
      () => PrivateEventSetupInventoryPage.fromResponse({
        ...body,
        'nextCursor': 'bad/cursor',
      }),
      throwsFormatException,
    );
  });

  testWidgets('manager inventory pages and reopens the canonical id', (
    tester,
  ) async {
    final cursors = <String?>[];
    final opened = <String>[];
    await tester.pumpWidget(_app(
      HostPrivateEventSetupInventorySection(
        organizerId: 'club-1',
        read: ({required organizerId, required limit, cursor}) async {
          expect(organizerId, 'club-1');
          expect(limit, 20);
          cursors.add(cursor);
          return PrivateEventSetupInventoryPage(
            events: cursor == null ? const [_saved] : const [],
            nextCursor: cursor == null ? 'page_2' : null,
          );
        },
        openSaved: (eventId) async {
          opened.add(eventId);
        },
      ),
    ));
    await pumpFeatureUi(tester);
    expect(find.text('Saturday mixer'), findsOneWidget);
    await tester.tap(find.text('Load more private events'));
    await pumpFeatureUi(tester);
    expect(cursors, [null, 'page_2']);
    await tester.tap(find.text('Saturday mixer'));
    await pumpFeatureUi(tester);
    expect(opened, ['event-1']);
    expect(cursors, [null, 'page_2', null]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stale organizer response cannot replace the current inventory', (
    tester,
  ) async {
    final oldRead = Completer<PrivateEventSetupInventoryPage>();
    Widget inventory(String organizerId) => _app(
      HostPrivateEventSetupInventorySection(
        organizerId: organizerId,
        read: ({required organizerId, required limit, cursor}) =>
            organizerId == 'old'
                ? oldRead.future
                : Future.value(const PrivateEventSetupInventoryPage(
                    events: [_saved], nextCursor: null,
                  )),
        openSaved: (_) async {},
      ),
    );
    await tester.pumpWidget(inventory('old'));
    await tester.pump();
    await tester.pumpWidget(inventory('new'));
    await pumpFeatureUi(tester);
    oldRead.complete(const PrivateEventSetupInventoryPage(
      events: [], nextCursor: null,
    ));
    await pumpFeatureUi(tester);
    expect(find.text('Saturday mixer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('entry selection carries saved id into the existing flow', (
    tester,
  ) async {
    HostEventEntrySelection? selection;
    await tester.pumpWidget(_app(Builder(builder: (context) => TextButton(
      onPressed: () async {
        selection = await showCatchBottomSheet<HostEventEntrySelection>(
          context: context,
          builder: (_) => HostEventEntrySheet(
            state: HostEventEntryState.resolve(organizerId: 'club-1'),
            readPrivateInventory: ({required organizerId, required limit,
                cursor}) async => const PrivateEventSetupInventoryPage(
              events: [_saved], nextCursor: null,
            ),
          ),
        );
      },
      child: const Text('Open'),
    ))));
    await tester.tap(find.text('Open'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Saturday mixer'));
    await pumpFeatureUi(tester);
    expect(selection?.intent, HostEventEntryIntent.resumePrivateEvent);
    expect(selection?.savedEventId, 'event-1');
    expect(tester.takeException(), isNull);
  });
}

Widget _app(Widget child) => MaterialApp(
  theme: CatchTheme.light,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
