import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/payments/presentation/payment_confirmation_screen.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

void main() {
  group('PaymentConfirmationScreen', () {
    final confirmationData = PaymentConfirmationData(
      paymentId: 'pay_ABC123',
      orderId: 'order_XYZ789',
      amountInPaise: 29900,
      runId: 'run-1',
    );

    testWidgets('renders hero section with payment details', (tester) async {
      final run = buildRun(
        id: 'run-1',
        runClubId: 'club-1',
        priceInPaise: 29900,
      );
      final club = buildRunClub(id: 'club-1', name: 'Bandra Breakers');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchRunProvider('run-1').overrideWith((ref) => Stream.value(run)),
            watchRunClubProvider(
              'club-1',
            ).overrideWith((ref) => Stream.value(club)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: PaymentConfirmationScreen(data: confirmationData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Hero section
      expect(find.text("You're in"), findsOneWidget);
      expect(
        find.text('Booking confirmed · payment ID pay_ABC123'),
        findsOneWidget,
      );
      expect(find.text(run.title), findsAtLeastNWidgets(1));
      expect(find.text('₹299'), findsOneWidget);
    });

    testWidgets('renders run summary card with details', (tester) async {
      final run = buildRun(
        id: 'run-1',
        runClubId: 'club-1',
        priceInPaise: 29900,
        meetingPoint: 'Carter Road Promenade',
      );
      final club = buildRunClub(id: 'club-1', name: 'Bandra Breakers');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchRunProvider('run-1').overrideWith((ref) => Stream.value(run)),
            watchRunClubProvider(
              'club-1',
            ).overrideWith((ref) => Stream.value(club)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: PaymentConfirmationScreen(data: confirmationData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Summary card
      expect(find.text('Bandra Breakers'), findsOneWidget);
      expect(find.text('Carter Road Promenade'), findsOneWidget);
      expect(find.text('₹299 · UPI'), findsOneWidget);
      expect(find.textContaining('Full refund'), findsOneWidget);
    });

    testWidgets('renders quick actions, heads up, and referral', (
      tester,
    ) async {
      final run = buildRun(id: 'run-1', runClubId: 'club-1');
      final club = buildRunClub(id: 'club-1');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchRunProvider('run-1').overrideWith((ref) => Stream.value(run)),
            watchRunClubProvider(
              'club-1',
            ).overrideWith((ref) => Stream.value(club)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: PaymentConfirmationScreen(data: confirmationData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Quick actions
      expect(find.text('Add to\ncalendar'), findsOneWidget);
      expect(find.text('Get\ndirections'), findsOneWidget);
      expect(find.text('Invite a\nfriend'), findsOneWidget);

      // Heads up
      expect(find.text('HEADS UP'), findsOneWidget);
      expect(find.textContaining('Bring a water bottle'), findsOneWidget);

      // Referral banner
      expect(find.text('Bring a friend, run together'), findsOneWidget);
    });

    testWidgets('Back to home button pops to root', (tester) async {
      final run = buildRun(id: 'run-1', runClubId: 'club-1');
      final club = buildRunClub(id: 'club-1');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchRunProvider('run-1').overrideWith((ref) => Stream.value(run)),
            watchRunClubProvider(
              'club-1',
            ).overrideWith((ref) => Stream.value(club)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: PaymentConfirmationScreen(data: confirmationData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Back to home'), findsOneWidget);
    });

    testWidgets('shows loading indicator while run is loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchRunProvider(
              'run-1',
            ).overrideWith((ref) => const Stream<Run?>.empty()),
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

    testWidgets('shows not found when run is null', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchRunProvider('run-1').overrideWith(
              (ref) => Stream<Run?>.value(null),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: PaymentConfirmationScreen(data: confirmationData),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Run not found.'), findsOneWidget);
    });
  });
}
