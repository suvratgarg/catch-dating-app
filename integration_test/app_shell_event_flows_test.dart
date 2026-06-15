import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/events/presentation/event_action_keys.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/payments/presentation/payment_confirmation_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/clubs/clubs_test_helpers.dart' as club_helpers;
import '../test/events/events_test_helpers.dart' as event_helpers;
import '../test/support/profile_readiness_fixtures.dart';
import '../test/test_pump_helpers.dart';
import 'support/app_shell_test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('event detail books a free event and shows confirmation', (
    tester,
  ) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');
    final club = club_helpers.buildClub();
    final run = event_helpers.buildEvent(
      id: 'run-1',
      clubId: club.id,
      startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 1,
    );
    final paymentRepository = event_helpers.FakePaymentRepository();

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        clubEvents: {
          club.id: [run],
        },
        paymentRepository: paymentRepository,
      ),
    );

    await openAppTab(tester, 'Explore');
    await openClubDetail(tester, club);
    await pumpRoute(tester);
    await openEventDetail(tester, club: club, event: run);

    await pumpUntilFound(tester, find.byKey(EventActionKeys.bookButton));
    await tester.tap(find.byKey(EventActionKeys.bookButton));
    await flushTestEventQueue();
    await pumpMutationUi(tester);

    expect(paymentRepository.bookFreeEventCalled, isTrue);
    expect(paymentRepository.bookedFreeEventId, run.id);
    expect(find.text('BOOKING CONFIRMED'), findsOneWidget);
    expect(find.text("You're in."), findsOneWidget);
  });

  testWidgets(
    'event detail books a paid event and opens payment confirmation',
    (tester) async {
      final user = buildSocialReadyUser(
        name: 'Suvrat Garg',
        email: 'suvrat@example.com',
        phoneNumber: '+919876543210',
      );
      final club = club_helpers.buildClub();
      final run = event_helpers.buildEvent(
        id: 'paid-run-1',
        clubId: club.id,
        startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
        meetingPoint: 'Carter Road Amphitheatre',
        bookedCount: 1,
        priceInPaise: 29900,
      );
      final paymentRepository = event_helpers.FakePaymentRepository()
        ..processPaymentResult = PaymentConfirmationData(
          paymentId: 'pay_integration_123',
          orderId: 'order_integration_123',
          amountInPaise: run.priceInPaise,
          currency: defaultCurrencyCode,
          eventId: run.id,
        );

      await pumpCatchAppShell(
        tester,
        overrides: appShellTestOverrides(
          uid: user.uid,
          user: user,
          clubs: [club],
          joinedClubIds: {club.id},
          clubEvents: {
            club.id: [run],
          },
          paymentRepository: paymentRepository,
        ),
      );

      await openAppTab(tester, 'Explore');
      await openClubDetail(tester, club);
      await pumpRoute(tester);
      await openEventDetail(tester, club: club, event: run);

      await pumpUntilFound(tester, find.byKey(EventActionKeys.bookButton));
      await tester.tap(find.byKey(EventActionKeys.bookButton));
      await flushTestEventQueue();
      await pumpMutationUi(tester);

      expect(paymentRepository.processPaymentCalled, isTrue);
      expect(paymentRepository.lastProcessPaymentCall?.eventId, run.id);
      expect(paymentRepository.lastProcessPaymentCall?.userName, user.name);
      expect(paymentRepository.lastProcessPaymentCall?.userEmail, user.email);
      expect(
        paymentRepository.lastProcessPaymentCall?.userContact,
        user.phoneNumber,
      );
      expect(find.text('BOOKING CONFIRMED'), findsOneWidget);
      expect(find.text('Payment ID'), findsOneWidget);
      expect(find.text('pay_integration_123'), findsOneWidget);
      expect(find.byKey(PaymentConfirmationKeys.backHome), findsOneWidget);
    },
  );

  testWidgets('event detail cancels an existing booking', (tester) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');
    final club = club_helpers.buildClub();
    final run = event_helpers.buildEvent(
      id: 'run-1',
      clubId: club.id,
      startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 1,
    );
    final eventRepository = event_helpers.FakeEventRepository();

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        signedUpEvents: [run],
        eventRepository: eventRepository,
      ),
    );

    await openEventDetail(tester, club: club, event: run, settle: false);
    await tester.tap(find.byKey(EventActionKeys.cancelBookingButton));
    await flushTestEventQueue();
    await pumpMutationUi(tester);

    expect(eventRepository.cancelledEventId, run.id);
    expect(find.text('Booking cancelled.'), findsOneWidget);
  });

  testWidgets('event detail joins a waitlist for a full event', (tester) async {
    final user = buildSocialReadyUser(name: 'Suvrat Garg');
    final club = club_helpers.buildClub();
    final run = event_helpers.buildEvent(
      id: 'run-1',
      clubId: club.id,
      startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      meetingPoint: 'Carter Road Amphitheatre',
      bookedCount: 20,
    );
    final eventRepository = event_helpers.FakeEventRepository();

    await pumpCatchAppShell(
      tester,
      overrides: appShellTestOverrides(
        uid: user.uid,
        user: user,
        clubs: [club],
        joinedClubIds: {club.id},
        clubEvents: {
          club.id: [run],
        },
        eventRepository: eventRepository,
      ),
    );

    await openAppTab(tester, 'Explore');
    await openClubDetail(tester, club);
    await pumpRoute(tester);
    await openEventDetail(tester, club: club, event: run);

    await tester.tap(find.byKey(EventActionKeys.joinWaitlistButton));
    await flushTestEventQueue();
    await pumpMutationUi(tester);

    expect(eventRepository.joinedWaitlistEventId, run.id);
  });
}
