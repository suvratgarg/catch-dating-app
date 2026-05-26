import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/payments/data/payment_callable_requests.dart';
import 'package:catch_dating_app/payments/data/payment_callable_responses.dart';
import 'package:catch_dating_app/payments/domain/host_payment_account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hostPaymentAccountRepositoryProvider =
    Provider<HostPaymentAccountRepository>(
      (ref) => HostPaymentAccountRepository(
        db: ref.watch(firebaseFirestoreProvider),
        functions: ref.watch(firebaseFunctionsProvider),
      ),
    );

final watchHostPaymentAccountProvider = StreamProvider.autoDispose
    .family<HostPaymentAccount?, String>((ref, uid) {
      return ref
          .watch(hostPaymentAccountRepositoryProvider)
          .watchHostPaymentAccount(uid);
    });

class HostPaymentAccountRepository {
  const HostPaymentAccountRepository({
    required FirebaseFirestore db,
    required FirebaseFunctions functions,
  }) : _db = db,
       _functions = functions;

  static const _collectionPath = 'hostPaymentAccounts';

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  Stream<HostPaymentAccount?> watchHostPaymentAccount(String uid) =>
      withBackendErrorStream(
        () => _db
            .collection(_collectionPath)
            .doc(uid)
            .snapshots()
            .map(
              (snap) => snap.exists && snap.data() != null
                  ? HostPaymentAccount.fromJson(snap.data()!)
                  : null,
            ),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'watch host payment account',
          resource: _collectionPath,
        ),
      );

  Future<StripeHostOnboardingLinkCallableResponse> createOnboardingLink({
    required String country,
    required String defaultCurrency,
  }) => withBackendErrorContext(
    () async {
      final result = await _functions
          .httpsCallable('createStripeHostOnboardingLink')
          .call<Object?>(
            CreateStripeHostOnboardingLinkCallableRequest(
              country: country,
              defaultCurrency: defaultCurrency,
            ).toJson(),
          );
      return StripeHostOnboardingLinkCallableResponse.fromCallableData(
        result.data,
      );
    },
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'create Stripe onboarding link',
      resource: _collectionPath,
    ),
  );

  Future<void> refreshStripeStatus() => withBackendErrorContext(
    () => _functions
        .httpsCallable('refreshStripeHostPaymentAccount')
        .call(const <String, Object?>{}),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'refresh Stripe account status',
      resource: _collectionPath,
    ),
  );
}
