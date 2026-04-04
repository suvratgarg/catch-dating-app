import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_history_repository.g.dart';

class PaymentHistoryRepository {
  PaymentHistoryRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Payment> _getCollectionReference() =>
      _db.collection('payments').withConverter<Payment>(
        fromFirestore: (doc, _) =>
            Payment.fromJson({...doc.data()!, 'id': doc.id}),
        toFirestore: (payment, _) => payment.toJson(),
      );

  // ── Read ──────────────────────────────────────────────────────────────────

  Stream<List<Payment>> watchPaymentsForUser(String userId) =>
      _getCollectionReference()
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((d) => d.data()).toList());

  Future<List<Payment>> fetchPaymentsForUser(String userId) async {
    final snap = await _getCollectionReference()
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  /// Returns the payment record for a specific activity, if any.
  Future<Payment?> fetchPaymentForActivity({
    required String userId,
    required String activityId,
  }) async {
    final snap = await _getCollectionReference()
        .where('userId', isEqualTo: userId)
        .where('activityId', isEqualTo: activityId)
        .where('status', isEqualTo: PaymentStatus.completed.name)
        .limit(1)
        .get();
    return snap.docs.firstOrNull?.data();
  }
}

@riverpod
PaymentHistoryRepository paymentHistoryRepository(Ref ref) =>
    PaymentHistoryRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<List<Payment>> paymentsForUser(Ref ref, String userId) =>
    ref.watch(paymentHistoryRepositoryProvider).watchPaymentsForUser(userId);
