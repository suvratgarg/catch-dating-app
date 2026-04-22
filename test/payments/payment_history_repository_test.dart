// ignore_for_file: must_be_immutable, override_on_non_overriding_member, subtype_of_sealed_class

import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

class TestFirebaseFirestore extends Fake implements FirebaseFirestore {
  TestFirebaseFirestore({required this.paymentsCollection});

  final CollectionReference<Map<String, dynamic>> paymentsCollection;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    switch (collectionPath) {
      case 'payments':
        return paymentsCollection;
      default:
        throw UnimplementedError('Unexpected collection path: $collectionPath');
    }
  }
}

class TestPaymentsRawCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  TestPaymentsRawCollection(this.convertedCollection);

  final TestPaymentsCollection convertedCollection;

  @override
  CollectionReference<R> withConverter<R>({
    required FromFirestore<R> fromFirestore,
    required ToFirestore<R> toFirestore,
  }) {
    if (R != Payment) {
      throw UnimplementedError(
        'Only Payment conversion is supported in tests.',
      );
    }
    return convertedCollection as CollectionReference<R>;
  }
}

class TestPaymentsCollection extends Fake
    implements CollectionReference<Payment> {
  TestPaymentsQuery? nextWhereResult;
  final whereCalls = <WhereCall>[];

  @override
  Query<Payment> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) {
    whereCalls.add(WhereCall(field: field, isEqualTo: isEqualTo));
    return nextWhereResult!;
  }
}

class TestPaymentsQuery extends Fake implements Query<Payment> {
  TestPaymentsQuery(this.snapshot);

  final QuerySnapshot<Payment> snapshot;
  final whereCalls = <WhereCall>[];
  int? lastLimit;

  @override
  Query<Payment> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) {
    whereCalls.add(WhereCall(field: field, isEqualTo: isEqualTo));
    return this;
  }

  @override
  Query<Payment> limit(int limit) {
    lastLimit = limit;
    return this;
  }

  @override
  Future<QuerySnapshot<Payment>> get([GetOptions? options]) async => snapshot;
}

class TestPaymentQuerySnapshot extends Fake implements QuerySnapshot<Payment> {
  TestPaymentQuerySnapshot(this.docsValue);

  final List<QueryDocumentSnapshot<Payment>> docsValue;

  @override
  List<QueryDocumentSnapshot<Payment>> get docs => docsValue;

  @override
  List<DocumentChange<Payment>> get docChanges => const [];

  @override
  int get size => docsValue.length;
}

class TestPaymentQueryDocumentSnapshot extends Fake
    implements QueryDocumentSnapshot<Payment> {
  TestPaymentQueryDocumentSnapshot({
    required this.referenceValue,
    required this.dataValue,
  });

  @override
  final DocumentReference<Payment> referenceValue;
  final Payment dataValue;

  @override
  bool get exists => true;

  @override
  String get id => referenceValue.id;

  @override
  DocumentReference<Payment> get reference => referenceValue;

  @override
  Payment data() => dataValue;
}

class TestPaymentDocumentReference extends Fake
    implements DocumentReference<Payment> {
  TestPaymentDocumentReference(this.id);

  @override
  final String id;

  @override
  String get path => 'payments/$id';
}

class WhereCall {
  const WhereCall({required this.field, this.isEqualTo});

  final Object field;
  final Object? isEqualTo;

  @override
  bool operator ==(Object other) =>
      other is WhereCall &&
      other.field == field &&
      other.isEqualTo == isEqualTo;

  @override
  int get hashCode => Object.hash(field, isEqualTo);
}

void main() {
  group('PaymentHistoryRepository', () {
    test(
      'fetchPaymentForRun returns the latest completed payment without sign-up failures',
      () async {
        final rawCollection = TestPaymentsCollection();
        final query = TestPaymentsQuery(
          TestPaymentQuerySnapshot([
            TestPaymentQueryDocumentSnapshot(
              referenceValue: TestPaymentDocumentReference('payment-old'),
              dataValue: buildPayment(
                id: 'payment-old',
                createdAt: DateTime(2025, 1, 1),
              ),
            ),
            TestPaymentQueryDocumentSnapshot(
              referenceValue: TestPaymentDocumentReference('payment-failed'),
              dataValue: buildPayment(
                id: 'payment-failed',
                createdAt: DateTime(2025, 1, 4),
                signUpFailed: true,
              ),
            ),
            TestPaymentQueryDocumentSnapshot(
              referenceValue: TestPaymentDocumentReference('payment-latest'),
              dataValue: buildPayment(
                id: 'payment-latest',
                createdAt: DateTime(2025, 1, 3),
              ),
            ),
          ]),
        );
        rawCollection.nextWhereResult = query;
        final repository = PaymentHistoryRepository(
          TestFirebaseFirestore(
            paymentsCollection: TestPaymentsRawCollection(rawCollection),
          ),
        );

        final payment = await repository.fetchPaymentForRun(
          userId: 'runner-1',
          runId: 'run-1',
        );

        expect(payment?.id, 'payment-latest');
        expect(rawCollection.whereCalls, [
          const WhereCall(field: 'userId', isEqualTo: 'runner-1'),
        ]);
        expect(query.whereCalls, [
          const WhereCall(field: 'runId', isEqualTo: 'run-1'),
          const WhereCall(field: 'status', isEqualTo: 'completed'),
        ]);
        expect(query.lastLimit, 10);
      },
    );

    test(
      'fetchPaymentForRun returns null when no successful completed payment exists',
      () async {
        final rawCollection = TestPaymentsCollection();
        rawCollection.nextWhereResult = TestPaymentsQuery(
          TestPaymentQuerySnapshot([
            TestPaymentQueryDocumentSnapshot(
              referenceValue: TestPaymentDocumentReference('payment-failed'),
              dataValue: buildPayment(
                id: 'payment-failed',
                createdAt: DateTime(2025, 1, 4),
                signUpFailed: true,
              ),
            ),
          ]),
        );
        final repository = PaymentHistoryRepository(
          TestFirebaseFirestore(
            paymentsCollection: TestPaymentsRawCollection(rawCollection),
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

Payment buildPayment({
  required String id,
  required DateTime createdAt,
  PaymentStatus status = PaymentStatus.completed,
  bool signUpFailed = false,
}) {
  return Payment(
    id: id,
    userId: 'runner-1',
    orderId: 'order-$id',
    paymentId: 'payment-$id',
    runId: 'run-1',
    amount: 25000,
    status: status,
    signUpFailed: signUpFailed,
    createdAt: createdAt,
  );
}
