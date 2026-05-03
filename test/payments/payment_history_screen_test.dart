import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_screen.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

/// Wraps [child] in a MaterialApp with an iPhone SE-sized surface so that
/// bottom sheets don't overflow during tests.
Widget _wrapPhoneSized(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: SizedBox(
      width: 375,
      height: 812,
      child: child,
    ),
  );
}

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
          child: _wrapPhoneSized(const PaymentHistoryScreen()),
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
          child: _wrapPhoneSized(const PaymentHistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Refunded'), findsOneWidget);
      expect(
        find.text('Booking failed, but your payment was refunded.'),
        findsOneWidget,
      );
    });

    testWidgets('tapping a payment tile opens detail bottom sheet', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            paymentsForUserProvider('runner-1').overrideWith(
              (ref) => Stream.value([
                Payment(
                  id: 'pay-3',
                  userId: 'runner-1',
                  orderId: 'order-3',
                  paymentId: 'pay_XYZ789',
                  runId: 'run-3',
                  amount: 19900,
                  status: PaymentStatus.completed,
                  signUpFailed: false,
                  createdAt: DateTime(2025, 2, 10),
                ),
              ]),
            ),
            watchRunProvider(
              'run-3',
            ).overrideWith((ref) => Stream.value(buildRun(id: 'run-3'))),
          ],
          child: _wrapPhoneSized(const PaymentHistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the payment tile badge.
      await tester.tap(find.text('Paid'));
      await tester.pumpAndSettle();

      // Detail sheet should be visible.
      expect(find.text('Payment ID'), findsOneWidget);
      expect(find.text('pay_XYZ789'), findsOneWidget);
      expect(find.text('Order ID'), findsOneWidget);
      expect(find.text('order-3'), findsOneWidget);
    });

    testWidgets(
      'detail sheet shows Get help button for sign-up failures',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              uidProvider.overrideWith((ref) => Stream.value('runner-1')),
              paymentsForUserProvider('runner-1').overrideWith(
                (ref) => Stream.value([
                  Payment(
                    id: 'pay-4',
                    userId: 'runner-1',
                    orderId: 'order-4',
                    paymentId: 'pay-4',
                    runId: 'run-4',
                    amount: 25000,
                    status: PaymentStatus.completed,
                    signUpFailed: true,
                    createdAt: DateTime(2025, 3, 1),
                  ),
                ]),
              ),
              watchRunProvider(
                'run-4',
              ).overrideWith((ref) => Stream.value(buildRun(id: 'run-4'))),
            ],
            child: _wrapPhoneSized(const PaymentHistoryScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the payment tile to open detail sheet.
        await tester.tap(find.text('Booking failed'));
        await tester.pumpAndSettle();

        // SignUpFailed help button should be visible.
        expect(find.text('Get help with this booking'), findsOneWidget);
      },
    );

    testWidgets('shows all status badge variants correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            paymentsForUserProvider('runner-1').overrideWith(
              (ref) => Stream.value([
                Payment(
                  id: 'pay-completed',
                  userId: 'runner-1',
                  orderId: 'order-c',
                  paymentId: 'pay-c',
                  runId: 'run-a',
                  amount: 10000,
                  status: PaymentStatus.completed,
                  createdAt: DateTime(2025, 1, 10),
                ),
                Payment(
                  id: 'pay-failed',
                  userId: 'runner-1',
                  orderId: 'order-f',
                  paymentId: 'pay-f',
                  runId: 'run-b',
                  amount: 5000,
                  status: PaymentStatus.failed,
                  createdAt: DateTime(2025, 1, 9),
                ),
                Payment(
                  id: 'pay-pending',
                  userId: 'runner-1',
                  orderId: 'order-p',
                  paymentId: 'pay-p',
                  runId: 'run-c',
                  amount: 7500,
                  status: PaymentStatus.pending,
                  createdAt: DateTime(2025, 1, 8),
                ),
              ]),
            ),
            watchRunProvider(
              'run-a',
            ).overrideWith((ref) => Stream.value(buildRun(id: 'run-a'))),
            watchRunProvider(
              'run-b',
            ).overrideWith((ref) => Stream.value(buildRun(id: 'run-b'))),
            watchRunProvider(
              'run-c',
            ).overrideWith((ref) => Stream.value(buildRun(id: 'run-c'))),
          ],
          child: _wrapPhoneSized(const PaymentHistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('Failed'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });
  });
}
