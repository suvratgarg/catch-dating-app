import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/data/read_limit_policy.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show SetCrossPathsEventConsentCallableRequest;
import 'package:catch_dating_app/cross_paths/domain/cross_paths_event_consent.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cross_paths_repository.g.dart';

class CrossPathsRepository {
  const CrossPathsRepository(this._db, this._functions);

  static const _collectionPath = 'eventCrossPathsConsents';
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  Stream<CrossPathsEventConsent?> watchEventConsent({
    required String eventId,
    required String uid,
  }) => withBackendErrorStream(
    () => _db
        .collection(_collectionPath)
        .where('eventId', isEqualTo: eventId)
        .where('uid', isEqualTo: uid)
        .limit(ReadLimitPolicy.lookup)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.isNotEmpty
              ? CrossPathsEventConsent.fromJson(snapshot.docs.first.data())
              : null,
        ),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch Cross Paths event consent',
      resource: _collectionPath,
    ),
  );

  Future<void> setEventConsent({
    required String eventId,
    required bool enabled,
    CrossPathsConsentSource source = CrossPathsConsentSource.eventDetail,
  }) => withBackendErrorContext(
    () => _functions
        .httpsCallable('setCrossPathsEventConsent')
        .call(
          SetCrossPathsEventConsentCallableRequest(
            eventId: eventId,
            enabled: enabled,
            termsVersion: currentCrossPathsTermsVersion,
            source: source.wireValue,
          ).toJson(),
        ),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'update Cross Paths event consent',
      resource: _collectionPath,
    ),
  );
}

@Riverpod(keepAlive: true)
CrossPathsRepository crossPathsRepository(Ref ref) => CrossPathsRepository(
  ref.watch(firebaseFirestoreProvider),
  ref.watch(firebaseFunctionsProvider),
);

@riverpod
Stream<CrossPathsEventConsent?> watchCrossPathsEventConsent(
  Ref ref,
  String eventId,
  String uid,
) => ref
    .watch(crossPathsRepositoryProvider)
    .watchEventConsent(eventId: eventId, uid: uid);
