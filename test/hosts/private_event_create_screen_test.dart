import 'dart:convert';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_create_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_draft_restore.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_setup_screen.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../clubs/clubs_test_helpers.dart';
import '../test_pump_helpers.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('restores canonical and legacy local draft times', () {
    final canonical = EventDraft(
      id: 'canonical',
      clubId: 'club-1',
      savedAt: DateTime(2026, 9, 24),
      eventLocalDate: '2090-10-03',
      eventLocalStartTime: '19:30',
      selectedDateMillis: DateTime(2090, 10, 4).millisecondsSinceEpoch,
      selectedStartHour: 8,
      selectedStartMinute: 15,
    );
    expect(restoredPrivateEventDate(canonical, rejectPast: true),
        DateTime(2090, 10, 3));
    expect(restoredPrivateEventStart(canonical),
        const TimeOfDay(hour: 19, minute: 30));
    final legacy = canonical.copyWith(
      eventLocalDate: null,
      eventLocalStartTime: null,
    );
    expect(restoredPrivateEventDate(legacy, rejectPast: true),
        DateTime(2090, 10, 4));
    expect(restoredPrivateEventStart(legacy),
        const TimeOfDay(hour: 8, minute: 15));
  });

  testWidgets('one first-save request opens the private setup workspace', (
    tester,
  ) async {
    final date = DateUtils.dateOnly(
      DateTime.now().add(const Duration(days: 2)),
    );
    final localDate =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final draft = EventDraft(
      id: 'local-draft',
      clubId: 'club-1',
      savedAt: DateTime.now(),
      name: 'Saturday mixer',
      eventCityId: 'in-mh-mumbai',
      eventMarketId: 'in-mh-mumbai',
      eventLocalDate: localDate,
      eventLocalStartTime: '19:00',
      eventTimezone: 'Asia/Kolkata',
      eventCityMode: 'set',
      eventTimezoneMode: 'set',
    );
    String? submittedRequestId;
    PrivateEventBasics? submitted;
    var calls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWithValue(const AsyncData<String?>('host-1')),
        ],
        child: MaterialApp(
          theme: CatchTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PrivateEventCreateScreen(
            club: buildClub(),
            initialDraft: draft,
            create: ({
              required organizerId,
              required requestId,
              required basics,
            }) async {
              calls += 1;
              expect(organizerId, 'club-1');
              submittedRequestId = requestId;
              submitted = basics;
              return const PrivateEventCreateReceipt(
                eventId: 'event-1',
                setupRevision: 1,
                replayed: false,
              );
            },
          ),
        ),
      ),
    );
    await pumpFeatureUi(tester);
    expect(find.text('Sell tickets with Catch'), findsNothing);
    expect(find.text('Use guest list'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('private-event-save')));
    await pumpFeatureUi(tester);
    expect(calls, 1);
    expect(submittedRequestId, isNotEmpty);
    expect(submitted?.name, 'Saturday mixer');
    expect(submitted?.localDate, localDate);
    expect(submitted?.localStartTime, '19:00');
    expect(find.text('Private'), findsOneWidget);
    expect(find.byType(PrivateEventSetupScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lost response retries the persisted body after reopening', (
    tester,
  ) async {
    final date = DateUtils.dateOnly(
      DateTime.now().add(const Duration(days: 2)),
    );
    final localDate =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final initial = EventDraft(
      id: 'local-draft',
      clubId: 'club-1',
      savedAt: DateTime.now(),
      name: 'Saturday mixer',
      eventCityId: 'in-mh-mumbai',
      eventMarketId: 'in-mh-mumbai',
      eventLocalDate: localDate,
      eventLocalStartTime: '19:00',
      eventTimezone: 'Asia/Kolkata',
      eventCityMode: 'set',
      eventTimezoneMode: 'set',
    );
    String? firstRequestId;
    Map<String, Object?>? firstPayload;
    Widget app(
      EventDraft draft,
      CreatePrivateEvent create,
    ) => ProviderScope(
      overrides: [
        // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
        uidProvider.overrideWithValue(const AsyncData<String?>('host-1')),
      ],
      child: MaterialApp(
        theme: CatchTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PrivateEventCreateScreen(
          club: buildClub(),
          initialDraft: draft,
          create: create,
        ),
      ),
    );

    await tester.pumpWidget(app(initial, ({
      required organizerId,
      required requestId,
      required basics,
    }) async {
      firstRequestId = requestId;
      firstPayload = basics.toJson();
      throw StateError('response lost');
    }));
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(const ValueKey('private-event-save')));
    await pumpFeatureUi(tester);

    final prefs = await SharedPreferences.getInstance();
    final saved = EventDraft.listFromJson(
      prefs.getString('event_drafts_club-1_host-1')!,
    ).single;
    expect(saved.eventCreateRequestId, firstRequestId);
    expect(jsonDecode(saved.eventCreatePayloadJson!), firstPayload);
    expect(saved.eventCreateReceiptEventId, isNull);

    // Reopening the draft after an uncertain response retains the exact
    // request even if the organizer's defaults and form values change.
    await tester.pumpWidget(const SizedBox.shrink());
    var replayAttempts = 0;
    await tester.pumpWidget(app(saved.copyWith(name: 'Edited after failure'), ({
      required organizerId,
      required requestId,
      required basics,
    }) async {
      replayAttempts += 1;
      expect(requestId, firstRequestId);
      expect(basics.toJson(), firstPayload);
      if (replayAttempts == 1) {
        throw FirebaseFunctionsException(
          code: 'permission-denied',
          message: 'Manager access changed',
        );
      }
      return const PrivateEventCreateReceipt(
        eventId: 'event-1',
        setupRevision: 1,
        replayed: true,
      );
    }));
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(const ValueKey('private-event-save')));
    await pumpFeatureUi(tester);
    final stillPending = EventDraft.listFromJson(
      prefs.getString('event_drafts_club-1_host-1')!,
    ).single;
    expect(stillPending.eventCreateRequestId, firstRequestId);
    expect(jsonDecode(stillPending.eventCreatePayloadJson!), firstPayload);
    expect(stillPending.eventCreateReceiptEventId, isNull);
    ScaffoldMessenger.of(
      tester.element(find.byType(PrivateEventCreateScreen)),
    ).removeCurrentSnackBar();
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(const ValueKey('private-event-save')));
    await pumpFeatureUi(tester);
    final completed = EventDraft.listFromJson(
      prefs.getString('event_drafts_club-1_host-1')!,
    ).single;
    expect(completed.eventCreateReceiptEventId, 'event-1');
    expect(completed.eventCreateReceiptRevision, 1);
    expect(replayAttempts, 2);
    expect(find.text('Private'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    var accidentalCreateCalls = 0;
    await tester.pumpWidget(app(completed, ({
      required organizerId,
      required requestId,
      required basics,
    }) async {
      accidentalCreateCalls += 1;
      throw StateError('saved event must not be created twice');
    }));
    await pumpFeatureUi(tester);
    expect(find.text('Private'), findsOneWidget);
    expect(accidentalCreateCalls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saved setup action remains reachable at 360px and 2x text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    var guideOpens = 0;
    await tester.pumpWidget(MaterialApp(
      theme: CatchTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(360, 800),
          textScaler: TextScaler.linear(2),
        ),
        child: PrivateEventSetupScreen(
          club: buildClub(),
          receipt: const PrivateEventCreateReceipt(
            eventId: 'saved-private-event',
            setupRevision: 1,
            replayed: false,
          ),
          name: 'Saturday mixer',
          date: DateTime(2026, 10, 3),
          start: const TimeOfDay(hour: 19, minute: 0),
          cityLabel: 'Mumbai',
          onClose: () {},
          onSetupGuide: () => guideOpens++,
        ),
      ),
    ));
    await tester.ensureVisible(find.text('Live event guide'));
    await pumpFeatureUi(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Live event guide'));
    await tester.pump();
    expect(guideOpens, 1);
    expect(tester.takeException(), isNull);
  });
}
