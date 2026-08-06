import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/data/read_limit_policy.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show
        GetCrossPathsSuggestionsCallableRequest,
        SetCrossPathsEventConsentCallableRequest;
import 'package:catch_dating_app/cross_paths/domain/cross_paths_event_consent.dart';
import 'package:catch_dating_app/cross_paths/domain/cross_paths_suggestion.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cross_paths_repository.g.dart';

CrossPathsEventConsent crossPathsEventConsentFromFirestore(
  Map<String, dynamic> json,
) {
  DateTime? nullableTimestamp(Object? value) =>
      value is Timestamp ? value.toDate() : null;
  return CrossPathsEventConsent(
    eventId: json['eventId'] as String? ?? '',
    uid: json['uid'] as String? ?? '',
    enabled: json['enabled'] == true,
    termsVersion: json['termsVersion'] as int? ?? 0,
    consentedAt: nullableTimestamp(json['consentedAt']),
    updatedAt: nullableTimestamp(json['updatedAt']),
    revokedAt: nullableTimestamp(json['revokedAt']),
    source: json['source'] as String? ?? '',
  );
}

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
              ? crossPathsEventConsentFromFirestore(snapshot.docs.first.data())
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

  Future<CrossPathsSuggestionsResponse> getSuggestions({
    required List<String> eventIds,
    required String sessionId,
  }) => withBackendErrorContext(
    () async {
      final result = await _functions
          .httpsCallable('getCrossPathsSuggestions')
          .call(
            GetCrossPathsSuggestionsCallableRequest(
              eventIds: eventIds,
              sessionId: sessionId,
            ).toJson(),
          );
      return CrossPathsSuggestionsResponse.fromCallableData(result.data);
    },
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'fetch Cross Paths suggestions',
      resource: 'getCrossPathsSuggestions',
    ),
  );
}

// keepalive: Shared by event-detail consent listeners and mutation calls.
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
