import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_share_card_sheet.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_share_card.dart';
import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/payments/presentation/payment_confirmation_keys.dart';
import 'package:catch_dating_app/payments/presentation/payment_confirmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';
import '../test_pump_helpers.dart';

void main() {
  group('PaymentConfirmationScreen', () {
    final confirmationData = const PaymentConfirmationData(
      paymentId: 'pay_ABC123',
      orderId: 'order_XYZ789',
      amountInPaise: 29900,
      currency: 'INR',
      eventId: 'event-1',
    );

    testWidgets('renders joined celebration with payment details', (
      tester,
    ) async {
      final event = buildEvent(priceInPaise: 29900);
      final club = buildClub(name: 'Bandra Breakers');

      await _pumpPaymentConfirmation(
        tester,
        data: confirmationData,
        event: event,
        club: club,
      );

      expect(find.text("You're in."), findsOneWidget);
      expect(find.text('BOOKING CONFIRMED'), findsOneWidget);
      expect(find.text('Payment ID'), findsOneWidget);
      expect(find.text('pay_ABC123'), findsOneWidget);
      expect(find.textContaining(event.title), findsAtLeastNWidgets(1));
      expect(find.text('₹299'), findsOneWidget);
    });

    testWidgets('renders event details inside the celebration', (tester) async {
      final event = buildEvent(
        priceInPaise: 29900,
        meetingPoint: 'Carter Road Promenade',
      );
      final club = buildClub(name: 'Bandra Breakers');

      await _pumpPaymentConfirmation(
        tester,
        data: confirmationData,
        event: event,
        club: club,
      );

      expect(find.textContaining('Bandra Breakers'), findsOneWidget);
      expect(find.text('Where'), findsOneWidget);
      expect(find.text('Carter Road Promenade'), findsOneWidget);
      expect(find.text('When'), findsOneWidget);
      expect(find.text('Event'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
    });

    testWidgets('renders quick actions, heads up, and referral', (
      tester,
    ) async {
      final event = buildEvent();
      final club = buildClub();

      await _pumpPaymentConfirmation(
        tester,
        data: confirmationData,
        event: event,
        club: club,
      );

      expect(find.byKey(PaymentConfirmationKeys.addToCalendar), findsOneWidget);
      expect(find.text('Add to calendar'), findsOneWidget);
      expect(find.byKey(PaymentConfirmationKeys.directions), findsOneWidget);
      expect(find.text('Get directions'), findsOneWidget);
      expect(find.byKey(PaymentConfirmationKeys.inviteFriend), findsOneWidget);
      expect(find.text('Invite friend'), findsOneWidget);

      expect(find.text('HEADS UP'), findsOneWidget);
      expect(find.textContaining('Bring a water bottle'), findsOneWidget);

      expect(find.byKey(PaymentConfirmationKeys.referralShare), findsOneWidget);
      expect(
        find.text('Bring someone you actually want there'),
        findsOneWidget,
      );
    });

    testWidgets('renders pending external checkout as the booking sheet', (
      tester,
    ) async {
      final event = buildEvent(priceInPaise: 60000);
      final club = buildClub();
      final pendingData = PaymentConfirmationData(
        paymentId: 'pay_PENDING',
        orderId: 'order_PENDING',
        amountInPaise: 60000,
        currency: 'INR',
        eventId: event.id,
        provider: 'stripe',
        status: PaymentStatus.pending,
        checkoutUrl: Uri.parse('https://checkout.stripe.test/session'),
      );

      await _pumpPaymentConfirmation(
        tester,
        data: pendingData,
        event: event,
        club: club,
      );

      expect(find.text('Checkout is waiting'), findsOneWidget);
      expect(find.textContaining('Finish payment in Stripe'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Open Stripe checkout'), findsOneWidget);
      expect(find.text('View payment history'), findsOneWidget);
      expect(find.text('Back to event'), findsOneWidget);
      expect(find.text(event.title), findsWidgets);
      expect(find.text('₹600'), findsOneWidget);
    });

    testWidgets('invite and referral surfaces open rich event share cards', (
      tester,
    ) async {
      final event = buildEvent();
      final club = buildClub();

      await _pumpPaymentConfirmation(
        tester,
        data: confirmationData,
        event: event,
        club: club,
      );

      await tester.ensureVisible(find.text('Invite friend'));
      await tester.tap(find.text('Invite friend'));
      await pumpFeatureUi(tester);

      expect(find.byKey(RichShareCardSheetKeys.cardPreview), findsOneWidget);
      expect(find.byType(EventShareCard), findsOneWidget);
      expect(find.text('CATCH INVITE'), findsOneWidget);

      Navigator.of(tester.element(find.byType(EventShareCard))).pop();
      await pumpFeatureUi(tester);

      await tester.ensureVisible(
        find.byKey(PaymentConfirmationKeys.referralShare),
      );
      await tester.tap(find.byKey(PaymentConfirmationKeys.referralShare));
      await pumpFeatureUi(tester);

      expect(find.byKey(RichShareCardSheetKeys.cardPreview), findsOneWidget);
      expect(find.byType(EventShareCard), findsOneWidget);
    });

    testWidgets('Back to home button pops to root', (tester) async {
      final event = buildEvent();
      final club = buildClub();

      await _pumpPaymentConfirmation(
        tester,
        data: confirmationData,
        event: event,
        club: club,
      );

      expect(find.byKey(PaymentConfirmationKeys.backHome), findsOneWidget);
    });

    testWidgets('shows loading indicator while event is loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchEventProvider(
              'event-1',
            ).overrideWith((ref) => const Stream<Event?>.empty()),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: PaymentConfirmationScreen(data: confirmationData),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows not found when event is null', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchEventProvider(
              'event-1',
            ).overrideWith((ref) => Stream<Event?>.value(null)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: PaymentConfirmationScreen(data: confirmationData),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Event not found'), findsOneWidget);
      expect(find.text('This event is no longer available.'), findsOneWidget);
    });
  });
}

Future<void> _pumpPaymentConfirmation(
  WidgetTester tester, {
  required PaymentConfirmationData data,
  required Event event,
  required Club club,
  Payment? payment,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        watchEventProvider(
          data.eventId,
        ).overrideWith((ref) => Stream.value(event)),
        watchClubProvider(
          event.clubId,
        ).overrideWith((ref) => Stream.value(club)),
        if (data.isPendingExternalCheckout)
          watchPaymentProvider(
            data.paymentId,
          ).overrideWith((ref) => Stream<Payment?>.value(payment)),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: PaymentConfirmationScreen(data: data),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}
