import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_screen.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

void main() {
  group('PaymentHistoryScreen', () {
    testWidgets('shows booking failure details for sign-up failures', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            paymentsForUserProvider('runner-1').overrideWith(
              (ref) => Stream.value([
                Payment(
                  id: 'pay-1',
                  userId: 'runner-1',
                  orderId: 'order-1',
                  paymentId: 'pay-1',
                  runId: 'run-1',
                  amount: 25000,
                  status: PaymentStatus.completed,
                  signUpFailed: true,
                  createdAt: DateTime(2025, 1, 2),
                ),
              ]),
            ),
            watchRunProvider(
              'run-1',
            ).overrideWith((ref) => Stream.value(buildRun(id: 'run-1'))),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const PaymentHistoryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Booking failed'), findsOneWidget);
      expect(
        find.text('No spot was reserved. Refund may still be pending.'),
        findsOneWidget,
      );
    });

    testWidgets('shows refunded recovery details for sign-up failures', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            paymentsForUserProvider('runner-1').overrideWith(
              (ref) => Stream.value([
                Payment(
                  id: 'pay-2',
                  userId: 'runner-1',
                  orderId: 'order-2',
                  paymentId: 'pay-2',
                  runId: 'run-2',
                  amount: 25000,
                  status: PaymentStatus.refunded,
                  signUpFailed: true,
                  createdAt: DateTime(2025, 1, 3),
                ),
              ]),
            ),
            watchRunProvider(
              'run-2',
            ).overrideWith((ref) => Stream.value(buildRun(id: 'run-2'))),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const PaymentHistoryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Refunded'), findsOneWidget);
      expect(
        find.text('Booking failed, but your payment was refunded.'),
        findsOneWidget,
      );
    });
  });
}
