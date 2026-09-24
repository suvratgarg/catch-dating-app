import 'package:catch_dating_app/hosts/data/manager_event_setup_defaults_repository.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_preferences.dart';
import 'package:catch_dating_app/hosts/data/private_event_preferences_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_preferences_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_preferences_screen.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_pump_helpers.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('2x narrow event payment setting stays reachable and saves only its event intent',
      (tester) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final hash = List.filled(64, 'a').join();
    PrivateEventPreferencesUpdateRequest? sent;
    final controller = PrivateEventPreferencesController(
      userId: 'host-1', organizerId: 'club-1', eventId: 'event-1',
      readEvent: ({required organizerId, required eventId}) async =>
          throw StateError('Test read unavailable'),
      readDefaults: (_) async => throw StateError('Test read unavailable'),
      write: (request) async {
        sent = request;
        throw StateError('Response lost');
      },
    );
    controller.event = const PrivateEventBasicSummary(
      eventId: 'event-1', organizerId: 'club-1', setupRevision: 2,
      name: 'Saturday mixer',
      city: EventSetupCity(cityId: 'in-mh-mumbai',
        marketId: 'in-mh-mumbai'),
      localDate: '2026-10-03', localStartTime: '19:00',
      timezone: 'Asia/Kolkata', startTimeMillis: 1791043800000,
      status: 'active', setupDefaults: {}, detailsConfigured: false,
      eventPreferences: null, canEditBasics: true,
    );
    controller.defaults = ManagerEventSetupDefaults(
      organizerId: 'club-1', cityId: 'in-mh-mumbai',
      marketId: 'in-mh-mumbai', timezone: 'Asia/Kolkata',
      organizerDefaultsRevision: 1, basicsReviewedHash: hash,
      preferencesRevision: 1,
      preferences: const ManagerEventSetupPreferences(
        timezone: 'Asia/Kolkata', currency: 'INR',
        collectionPreference: EventCollectionPreference.manualInstructions,
      ),
      preferencesHash: hash, reviewedDefaultsHash: hash,
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      theme: CatchTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: PrivateEventPreferencesScreen(
          controller: controller,
          onBack: () {},
        ),
      ),
    ));
    final field = find.byKey(
      const ValueKey('event-preference-expectedAmountMinor-null'),
    );
    await tester.ensureVisible(field);
    await pumpFeatureUi(tester);
    expect(tester.takeException(), isNull);
    final input = find.descendant(of: field,
      matching: find.byKey(const ValueKey('catch-field-text-entry')));
    await tester.enterText(input, '120000');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpFeatureUi(tester);
    expect(sent?.expectedSetupRevision, 2);
    expect(sent?.reviewedDefaultsHash, hash);
    expect(sent?.intents.expectedAmountMinor.value, 120000);
    expect(sent?.intents.collectionPreference.mode,
      EventSetupValueMode.inherit);
    expect(controller.pending?.toJson(), sent?.toJson());
    expect(tester.takeException(), isNull);
  });
}
