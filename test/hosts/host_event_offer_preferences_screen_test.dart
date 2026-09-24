import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/hosts/data/event_offer_preferences_repository.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_defaults_repository.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_preferences.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/event_offer_preferences_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/host_event_offer_preferences_screen.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_pump_helpers.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('settings controller rebinds for organizer, event, and actor',
      (tester) async {
    final accounts = StreamController<String?>();
    addTearDown(accounts.close);
    var organizerId = 'club-1';
    var eventId = 'event-1';
    late StateSetter updateRoute;
    final bindings = <String>[];
    await tester.pumpWidget(ProviderScope(
      overrides: [uidProvider.overrideWith((ref) => accounts.stream)],
      child: MaterialApp(
        theme: CatchTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StatefulBuilder(builder: (context, setState) {
          updateRoute = setState;
          return HostEventOfferPreferencesScreen(
            organizerId: organizerId, eventId: eventId, onBack: () {},
            controllerForUser: (uid) {
              bindings.add('$uid/$organizerId/$eventId');
              return EventOfferPreferencesController(
                userId: uid, organizerId: organizerId, eventId: eventId,
                readConfiguration: ({required organizerId,
                    required eventId}) async =>
                    throw StateError('Fixture read unavailable'),
                readDefaults: (_) async =>
                    throw StateError('Fixture read unavailable'),
                write: (_) async => throw StateError('No save'),
              );
            },
          );
        }),
      ),
    ));
    accounts.add('host-1');
    await pumpFeatureUi(tester);
    expect(bindings, ['host-1/club-1/event-1']);
    updateRoute(() { organizerId = 'club-2'; eventId = 'event-2'; });
    await pumpFeatureUi(tester);
    expect(bindings.last, 'host-1/club-2/event-2');
    accounts.add('host-2');
    await pumpFeatureUi(tester);
    expect(bindings.last, 'host-2/club-2/event-2');
    expect(bindings.length, 3);
  });

  testWidgets('waits for async manager identity before starting settings read',
      (tester) async {
    final accounts = StreamController<String?>();
    addTearDown(accounts.close);
    final hash = List.filled(64, 'a').join();
    var created = 0;
    final controller = EventOfferPreferencesController(
      userId: 'host-1', organizerId: 'club-1', eventId: 'event-1',
      readConfiguration: ({required organizerId, required eventId}) async =>
          const EventOfferConfiguration(
            organizerId: 'club-1', eventId: 'event-1',
            eventSourceRevision: 8, startsAtMillis: 1791043800000,
            nowMillis: 1790000000000, suggestedExpiresAtMillis: null,
            preferencesRevision: 0, preferences: null,
          ),
      readDefaults: (_) async => ManagerEventSetupDefaults(
        organizerId: 'club-1', cityId: null, marketId: null,
        timezone: null, organizerDefaultsRevision: null,
        basicsReviewedHash: hash, preferencesRevision: 0,
        preferences: const ManagerEventSetupPreferences(),
        preferencesHash: hash, reviewedDefaultsHash: hash,
      ),
      write: (_) async => throw StateError('No save in this test'),
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [uidProvider.overrideWith((ref) => accounts.stream)],
      child: MaterialApp(
        theme: CatchTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HostEventOfferPreferencesScreen(
          organizerId: 'club-1', eventId: 'event-1', onBack: () {},
          controllerForUser: (uid) {
            expect(uid, 'host-1');
            created++;
            return controller;
          },
        ),
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(created, 0);
    accounts.add('host-1');
    await pumpFeatureUi(tester);
    expect(created, 1);
    expect(find.text('Published event offers'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('published preferences remain scrollable at 360px and 2x text',
      (tester) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final hash = List.filled(64, 'a').join();
    final controller = EventOfferPreferencesController(
      userId: 'host-1', organizerId: 'club-1', eventId: 'event-1',
      displayName: 'Saturday mixer',
      readConfiguration: ({required organizerId, required eventId}) async =>
          throw StateError('Preview read unavailable'),
      readDefaults: (_) async => throw StateError('Preview read unavailable'),
      write: (_) async => throw StateError('Preview save unavailable'),
    );
    controller.configuration = const EventOfferConfiguration(
      organizerId: 'club-1', eventId: 'event-1',
      eventSourceRevision: 8, startsAtMillis: 1791043800000,
      nowMillis: 1790000000000, suggestedExpiresAtMillis: null,
      preferencesRevision: 0, preferences: null,
    );
    controller.defaults = ManagerEventSetupDefaults(
      organizerId: 'club-1', cityId: 'in-mh-mumbai',
      marketId: 'in-mh-mumbai', timezone: 'Asia/Kolkata',
      organizerDefaultsRevision: 1, basicsReviewedHash: hash,
      preferencesRevision: 1,
      preferences: const ManagerEventSetupPreferences(
        timezone: 'Asia/Kolkata', currency: 'INR',
      ),
      preferencesHash: hash, reviewedDefaultsHash: hash,
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(ProviderScope(child: MaterialApp(
      theme: CatchTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: HostEventOfferPreferencesScreen(
          organizerId: 'club-1', eventId: 'event-1',
          initialController: controller, onBack: () {},
        ),
      ),
    )));
    expect(find.text('Published event offers'), findsOneWidget);
    final amount = find.byKey(
      const ValueKey('event-preference-expectedAmountMinor-null'),
    );
    await tester.ensureVisible(amount);
    await pumpFeatureUi(tester);
    expect(amount, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
