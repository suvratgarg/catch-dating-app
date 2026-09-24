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
