import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_preferences.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('manager preferences can set and clear without public serialization', () {
    const original = ManagerEventSetupPreferences(
      usualDurationMinutes: 90,
      offerValidityMinutes: 1440,
      collectionPreference: EventCollectionPreference.reusablePage,
      currency: 'INR',
      offerMessageTemplate: 'Review this event',
      paymentInstructions: 'Pay after approval',
      reusablePaymentPage: ReusableOrganizerPaymentPage(
        'https://example.com/pay',
      ),
    );
    final cleared = original.copyWith(
      collectionPreference: null,
      paymentInstructions: null,
      reusablePaymentPage: null,
    );
    expect(cleared.usualDurationMinutes, 90);
    expect(cleared.collectionPreference, isNull);
    expect(cleared.paymentInstructions, isNull);
    expect(cleared.reusablePaymentPage, isNull);
    expect(original.reusablePaymentPage!.reusableForEvents, isTrue);
    final publicOrganizerJson = const ClubHostDefaults().toJson();
    expect(publicOrganizerJson.keys, isNot(contains('eventSetup')));
    expect(publicOrganizerJson.keys, isNot(contains('paymentInstructions')));
    expect(publicOrganizerJson.keys, isNot(contains('reusablePaymentPage')));
  });

  testWidgets('manager-only editor labels suggestions and disables unsaved controls', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(
      theme: CatchTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: SingleChildScrollView(
          child: HostManagerEventSetupPreferencesEditor(
            preferences: ManagerEventSetupPreferences(
              usualDurationMinutes: 90,
              collectionPreference: EventCollectionPreference.catchCheckout,
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(find.text('Usual duration'), findsOneWidget);
    expect(find.text('Preferred collection method'), findsOneWidget);
    expect(find.textContaining('A preference only'), findsOneWidget);
    expect(find.text('90 min'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
