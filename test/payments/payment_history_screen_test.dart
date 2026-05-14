import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_keys.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_screen.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';
import '../test_pump_helpers.dart';

/// Wraps [child] in a MaterialApp with an iPhone SE-sized surface so that
/// bottom sheets don't overflow during tests.
Widget _wrapPhoneSized(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: SizedBox(width: 375, height: 812, child: child),
  );
}

void main() {
  group('PaymentHistoryScreen', () {
    testWidgets('shows booking failure details for sign-up failures', (
      tester,
    ) async {
      await _pumpPaymentHistory(
        tester,
        payments: [
          _payment(
            id: 'pay-1',
            orderId: 'order-1',
            runId: 'run-1',
            status: PaymentStatus.completed,
            signUpFailed: true,
            createdAt: DateTime(2025, 1, 2),
          ),
        ],
        runs: {'run-1': buildRun(id: 'run-1')},
      );

      expect(_topBarMaterial(tester).color, CatchTokens.sunsetLight.bg);
      expect(find.text('Booking failed'), findsOneWidget);
      expect(
        find.text('No spot was reserved. Refund may still be pending.'),
        findsOneWidget,
      );
    });

    testWidgets('shows refunded recovery details for sign-up failures', (
      tester,
    ) async {
      await _pumpPaymentHistory(
        tester,
        payments: [
          _payment(
            id: 'pay-2',
            orderId: 'order-2',
            runId: 'run-2',
            status: PaymentStatus.refunded,
            signUpFailed: true,
            createdAt: DateTime(2025, 1, 3),
          ),
        ],
        runs: {'run-2': buildRun(id: 'run-2')},
      );

      expect(find.text('Refunded'), findsOneWidget);
      expect(
        find.text('Booking failed, but your payment was refunded.'),
        findsOneWidget,
      );
    });

    testWidgets('tapping a payment tile opens detail bottom sheet', (
      tester,
    ) async {
      await _pumpPaymentHistory(
        tester,
        payments: [
          _payment(
            id: 'pay-3',
            orderId: 'order-3',
            paymentId: 'pay_XYZ789',
            runId: 'run-3',
            amount: 19900,
            status: PaymentStatus.completed,
            createdAt: DateTime(2025, 2, 10),
          ),
        ],
        runs: {'run-3': buildRun(id: 'run-3')},
      );

      await tester.tap(find.byKey(PaymentHistoryKeys.paymentTile('pay-3')));
      await _pumpPaymentSheet(tester);

      expect(find.text('Payment ID'), findsOneWidget);
      expect(find.text('pay_XYZ789'), findsOneWidget);
      expect(find.text('Order ID'), findsOneWidget);
      expect(find.text('order-3'), findsOneWidget);
      expect(find.text('10 Feb 2025 · 12:00 AM'), findsWidgets);
    });

    testWidgets('detail sheet shows Get help button for sign-up failures', (
      tester,
    ) async {
      await _pumpPaymentHistory(
        tester,
        payments: [
          _payment(
            id: 'pay-4',
            orderId: 'order-4',
            runId: 'run-4',
            status: PaymentStatus.completed,
            signUpFailed: true,
            createdAt: DateTime(2025, 3, 1),
          ),
        ],
        runs: {'run-4': buildRun(id: 'run-4')},
      );

      await tester.tap(find.byKey(PaymentHistoryKeys.paymentTile('pay-4')));
      await _pumpPaymentSheet(tester);

      expect(find.text('Get help with this booking'), findsOneWidget);
    });

    testWidgets('shows all status badge variants correctly', (tester) async {
      await _pumpPaymentHistory(
        tester,
        payments: [
          _payment(
            id: 'pay-completed',
            orderId: 'order-c',
            paymentId: 'pay-c',
            runId: 'run-a',
            amount: 10000,
            status: PaymentStatus.completed,
            createdAt: DateTime(2025, 1, 10),
          ),
          _payment(
            id: 'pay-failed',
            orderId: 'order-f',
            paymentId: 'pay-f',
            runId: 'run-b',
            amount: 5000,
            status: PaymentStatus.failed,
            createdAt: DateTime(2025, 1, 9),
          ),
          _payment(
            id: 'pay-pending',
            orderId: 'order-p',
            paymentId: 'pay-p',
            runId: 'run-c',
            amount: 7500,
            status: PaymentStatus.pending,
            createdAt: DateTime(2025, 1, 8),
          ),
        ],
        runs: {
          'run-a': buildRun(id: 'run-a'),
          'run-b': buildRun(id: 'run-b'),
          'run-c': buildRun(id: 'run-c'),
        },
      );

      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('Failed'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });
  });
}

Material _topBarMaterial(WidgetTester tester) {
  return tester.widget<Material>(
    find
        .descendant(
          of: find.byType(CatchTopBar),
          matching: find.byType(Material),
        )
        .first,
  );
}

Future<void> _pumpPaymentSheet(WidgetTester tester) async {
  await pumpFeatureUi(tester);
}

Future<void> _pumpPaymentHistory(
  WidgetTester tester, {
  required List<Payment> payments,
  required Map<String, Run> runs,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        watchPaymentsForUserProvider(
          'runner-1',
        ).overrideWith((ref) => Stream.value(payments)),
        for (final entry in runs.entries)
          watchRunProvider(
            entry.key,
          ).overrideWith((ref) => Stream.value(entry.value)),
      ],
      child: _wrapPhoneSized(const PaymentHistoryScreen()),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Payment _payment({
  required String id,
  required String orderId,
  required String runId,
  required PaymentStatus status,
  required DateTime createdAt,
  String? paymentId,
  int amount = 25000,
  bool signUpFailed = false,
}) {
  return Payment(
    id: id,
    userId: 'runner-1',
    orderId: orderId,
    paymentId: paymentId ?? id,
    runId: runId,
    amount: amount,
    status: status,
    signUpFailed: signUpFailed,
    createdAt: createdAt,
  );
}
