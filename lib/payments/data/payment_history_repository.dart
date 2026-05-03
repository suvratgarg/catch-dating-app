import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_history_repository.g.dart';

class PaymentHistoryRepository {
  const PaymentHistoryRepository(this._db);

  static const _collectionPath = 'payments';

  final FirebaseFirestore _db;

  CollectionReference<Payment> get _paymentsRef => _db
      .collection(_collectionPath)
      .withDocumentIdConverter<Payment>(
        idField: 'id',
        fromJson: Payment.fromJson,
        toJson: (payment) => payment.toJson(),
      );

  // ── Read ──────────────────────────────────────────────────────────────────

  Stream<List<Payment>> watchPaymentsForUser(String userId) => _paymentsRef
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => d.data()).toList());

  Future<List<Payment>> fetchPaymentsForUser(String userId) async {
    final snap = await _paymentsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  /// Returns the payment record for a specific run, if any.
  Future<Payment?> fetchPaymentForRun({
    required String userId,
    required String runId,
  }) async {
    final snap = await _paymentsRef
        .where('userId', isEqualTo: userId)
        .where('runId', isEqualTo: runId)
        .where('status', isEqualTo: PaymentStatus.completed.name)
        .limit(10)
        .get();
    return selectLatestSuccessfulPayment(snap.docs.map((doc) => doc.data()));
  }
}

Payment? selectLatestSuccessfulPayment(Iterable<Payment> payments) {
  final completedPayments =
      payments
          .where(
            (payment) =>
                payment.status == PaymentStatus.completed &&
                !payment.signUpFailed,
          )
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return completedPayments.firstOrNull;
}

@riverpod
PaymentHistoryRepository paymentHistoryRepository(Ref ref) =>
    PaymentHistoryRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<List<Payment>> paymentsForUser(Ref ref, String userId) =>
    ref.watch(paymentHistoryRepositoryProvider).watchPaymentsForUser(userId);
