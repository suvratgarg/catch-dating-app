import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaymentHistoryRepository', () {
    late FakeFirebaseFirestore firestore;
    late PaymentHistoryRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = PaymentHistoryRepository(firestore);
    });

    test(
      'fetchPaymentForRun returns the latest completed payment without sign-up failures',
      () async {
        await _seedPayment(
          firestore,
          buildPayment(id: 'payment-old', createdAt: DateTime(2025, 1, 1)),
        );
        await _seedPayment(
          firestore,
          buildPayment(
            id: 'payment-failed',
            createdAt: DateTime(2025, 1, 4),
            signUpFailed: true,
          ),
        );
        await _seedPayment(
          firestore,
          buildPayment(id: 'payment-latest', createdAt: DateTime(2025, 1, 3)),
        );
        await _seedPayment(
          firestore,
          buildPayment(
            id: 'payment-other-run',
            runId: 'run-2',
            createdAt: DateTime(2025, 1, 5),
          ),
        );

        final payment = await repository.fetchPaymentForRun(
          userId: 'runner-1',
          runId: 'run-1',
        );

        expect(payment?.id, 'payment-latest');
      },
    );

    test(
      'fetchPaymentForRun returns null when no successful completed payment exists',
      () async {
        await _seedPayment(
          firestore,
          buildPayment(
            id: 'payment-failed',
            createdAt: DateTime(2025, 1, 4),
            signUpFailed: true,
          ),
        );
        await _seedPayment(
          firestore,
          buildPayment(
            id: 'payment-pending',
            createdAt: DateTime(2025, 1, 5),
            status: PaymentStatus.pending,
          ),
        );

        final payment = await repository.fetchPaymentForRun(
          userId: 'runner-1',
          runId: 'run-1',
        );

        expect(payment, isNull);
      },
    );

    test(
      'watchPaymentsForUser streams payments ordered newest first',
      () async {
        await _seedPayment(
          firestore,
          buildPayment(id: 'old', createdAt: DateTime(2025, 1, 1)),
        );
        await _seedPayment(
          firestore,
          buildPayment(id: 'latest', createdAt: DateTime(2025, 1, 3)),
        );
        await _seedPayment(
          firestore,
          buildPayment(
            id: 'other-user',
            userId: 'runner-2',
            createdAt: DateTime(2025, 1, 4),
          ),
        );

        await expectLater(
          repository.watchPaymentsForUser('runner-1'),
          emits(
            predicate<List<Payment>>(
              (payments) =>
                  payments.map((payment) => payment.id).toList().join(',') ==
                  'latest,old',
            ),
          ),
        );
      },
    );

    test(
      'selectLatestSuccessfulPayment filters failed sign-ups and sorts newest first',
      () {
        final payment = selectLatestSuccessfulPayment([
          buildPayment(id: 'old', createdAt: DateTime(2025, 1, 1)),
          buildPayment(
            id: 'ignored',
            createdAt: DateTime(2025, 1, 5),
            signUpFailed: true,
          ),
          buildPayment(id: 'latest', createdAt: DateTime(2025, 1, 3)),
        ]);

        expect(payment?.id, 'latest');
      },
    );
  });
}

Future<void> _seedPayment(FakeFirebaseFirestore firestore, Payment payment) {
  return firestore.collection('payments').doc(payment.id).set(payment.toJson());
}

Payment buildPayment({
  required String id,
  required DateTime createdAt,
  String userId = 'runner-1',
  String runId = 'run-1',
  PaymentStatus status = PaymentStatus.completed,
  bool signUpFailed = false,
}) {
  return Payment(
    id: id,
    userId: userId,
    orderId: 'order-$id',
    paymentId: 'payment-$id',
    runId: runId,
    amount: 25000,
    status: status,
    signUpFailed: signUpFailed,
    createdAt: createdAt,
  );
}
