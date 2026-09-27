import 'package:catch_dating_app/events/domain/event_meeting_location.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_defaults_repository.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_preferences.dart';
import 'package:catch_dating_app/hosts/data/private_event_details_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_details_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_details_screen.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_pump_helpers.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final mapSelection in [false, true]) {
    testWidgets(
      'narrow 2x details sends actual ${mapSelection ? 'map location' : 'duration'}',
      (tester) async {
        tester.view.physicalSize = const Size(720, 1280);
        tester.view.devicePixelRatio = 2;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        final hash = List.filled(64, 'a').join();
        PrivateEventDetailsUpdateRequest? sent;
        final controller = PrivateEventDetailsController(
          userId: 'host-1',
          organizerId: 'club-1',
          eventId: 'event-1',
          readEvent: ({required organizerId, required eventId}) async =>
              throw StateError('Test read unavailable'),
          readDefaults: (_) async => throw StateError('Test read unavailable'),
          write: (request) async {
            sent = request;
            throw StateError('Response lost');
          },
        );
        controller.event = const PrivateEventBasicSummary(
          eventId: 'event-1',
          organizerId: 'club-1',
          setupRevision: 2,
          name: 'Saturday mixer',
          city: EventSetupCity(
            cityId: 'in-mh-mumbai',
            marketId: 'in-mh-mumbai',
          ),
          localDate: '2026-10-03',
          localStartTime: '19:00',
          timezone: 'Asia/Kolkata',
          startTimeMillis: 1791043800000,
          status: 'active',
          setupDefaults: {},
          detailsConfigured: false,
          eventPreferences: null,
          canEditBasics: true,
        );
        controller.defaults = ManagerEventSetupDefaults(
          organizerId: 'club-1',
          cityId: 'in-mh-mumbai',
          marketId: 'in-mh-mumbai',
          timezone: 'Asia/Kolkata',
          organizerDefaultsRevision: 1,
          basicsReviewedHash: hash,
          preferencesRevision: 1,
          preferences: const ManagerEventSetupPreferences(
            usualDurationMinutes: 90,
          ),
          preferencesHash: hash,
          reviewedDefaultsHash: hash,
        );
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          MaterialApp(
            theme: CatchTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: PrivateEventDetailsScreen(
                controller: controller,
                onBack: () {},
                pickLocation: (_) async => const EventMeetingLocation(
                  name: 'Test Town Hall',
                  latitude: 19.2,
                  longitude: 72.9,
                ),
              ),
            ),
          ),
        );
        await pumpFeatureUi(tester);
        expect(tester.takeException(), isNull);
        final action = find.text(
          mapSelection
              ? 'Choose meeting place on map'
              : 'Use suggested duration',
        );
        await ensureCentered(tester, action);
        await tester.pump();
        expect(action.hitTestable(), findsOneWidget);
        await tester.tap(action.hitTestable());
        await pumpFeatureUi(tester);
        if (mapSelection) {
          expect(sent?.details.meetingLocation?.latitude, 19.2);
          expect(sent?.details.meetingLocation?.longitude, 72.9);
          expect(sent?.details.venue, isNull);
        } else {
          expect(sent?.details.toJson(), {
            'durationMinutes': {'mode': 'inherit'},
          });
        }
        expect(sent?.reviewedDefaultsHash, hash);
        expect(controller.pending, isNotNull);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
