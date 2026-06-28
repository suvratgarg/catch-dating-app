import 'dart:async';

import 'package:catch_dating_app/clubs/data/club_callable_responses.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/clubs/domain/update_club_patch.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_chunks.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show
        AddClubHostCallableRequest,
        ClubMembershipCallableRequest,
        CreateClubCallableRequest,
        RemoveClubHostCallableRequest,
        SetClubNotificationPreferenceCallableRequest,
        StartClubHostConversationCallableRequest,
        TransferClubOwnershipCallableRequest;
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clubs_repository.g.dart';

class ClubsRepository {
  const ClubsRepository(this._db, this._functions);

  static const _collectionPath = 'clubs';
  static const discoveryLimit = 30;

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  CollectionReference<Club> get _clubsRef => _db
      .collection(_collectionPath)
      .withDocumentIdConverter<Club>(
        idField: 'id',
        fromJson: Club.fromJson,
        toJson: (club) => club.toJson(),
      );

  DocumentReference<Club> _clubRef([String? id]) => _clubsRef.doc(id);

  // ── Read ───────────────────────────────────────────────────────────────────

  Stream<Club?> watchClub(String id) => withBackendErrorStream(
    () => _clubRef(id).snapshots().map((doc) => doc.exists ? doc.data() : null),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch club',
      resource: _collectionPath,
    ),
  );

  Future<Club?> fetchClub(String id) => withBackendErrorContext(
    () async {
      final doc = await _clubRef(id).get();
      return doc.exists ? doc.data() : null;
    },
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'fetch club',
      resource: _collectionPath,
    ),
  );

  Stream<List<Club>> watchClubsByLocation(String location) =>
      withBackendErrorStream(
        () => _clubsRef
            .where('locationMarketId', isEqualTo: location)
            .orderBy('createdAt', descending: true)
            .limit(discoveryLimit)
            .snapshots()
            .map(
              (snap) => _appDiscoverableClubs(snap.docs.map((d) => d.data())),
            ),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'watch clubs by location',
          resource: _collectionPath,
        ),
      );

  Stream<List<Club>> watchClubsByLocationSortedByRating(String location) =>
      withBackendErrorStream(
        () => _clubsRef
            .where('locationMarketId', isEqualTo: location)
            .orderBy('rating', descending: true)
            .limit(discoveryLimit)
            .snapshots()
            .map(
              (snap) => _appDiscoverableClubs(snap.docs.map((d) => d.data())),
            ),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'watch clubs by rating',
          resource: _collectionPath,
        ),
      );

  Stream<List<Club>> watchClubsHostedBy(String uid) => withBackendErrorStream(
    () => _clubsRef
        .where(
          Filter.or(
            Filter('hostUserId', isEqualTo: uid),
            Filter('hostUserIds', arrayContains: uid),
          ),
        )
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch hosted clubs',
      resource: _collectionPath,
    ),
  );

  Stream<List<Club>> watchClubsOwnedBy(String uid) => withBackendErrorStream(
    () => _clubsRef
        .where(
          Filter.or(
            Filter('hostUserId', isEqualTo: uid),
            Filter('ownerUserId', isEqualTo: uid),
          ),
        )
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch owned clubs',
      resource: _collectionPath,
    ),
  );

  Stream<List<Club>> watchClubsByIds({required List<String> clubIds}) {
    final uniqueIds = clubIds.toSet().toList()..sort();
    if (uniqueIds.isEmpty) return Stream.value(const []);

    var clubSubs = <StreamSubscription<QuerySnapshot<Club>>>[];
    var closed = false;
    late final StreamController<List<Club>> controller;

    void emitOrderedClubs({
      required Map<int, List<Club>> clubsByChunk,
      required int chunkCount,
    }) {
      if (clubsByChunk.length < chunkCount || controller.isClosed) return;
      final byId = <String, Club>{};
      for (final clubs in clubsByChunk.values) {
        for (final club in clubs) {
          byId[club.id] = club;
        }
      }
      final clubs = [
        for (final id in uniqueIds)
          if (byId[id] != null) byId[id]!,
      ];
      controller.add(_appDiscoverableClubs(clubs));
    }

    controller = StreamController<List<Club>>(
      onListen: () {
        final chunks = chunkedForWhereIn(uniqueIds).toList(growable: false);
        final clubsByChunk = <int, List<Club>>{};
        for (var i = 0; i < chunks.length; i += 1) {
          final chunk = chunks[i];
          final sub = _clubsRef
              .where(FieldPath.documentId, whereIn: chunk)
              .snapshots()
              .listen((clubSnap) {
                if (closed) return;
                clubsByChunk[i] = clubSnap.docs
                    .map((doc) => doc.data())
                    .toList();
                emitOrderedClubs(
                  clubsByChunk: clubsByChunk,
                  chunkCount: chunks.length,
                );
              }, onError: controller.addError);
          clubSubs.add(sub);
        }
      },
      onCancel: () async {
        closed = true;
        for (final sub in clubSubs) {
          await sub.cancel();
        }
        clubSubs = [];
        if (!controller.isClosed) {
          await controller.close();
        }
      },
    );

    return withBackendErrorStream(
      () => controller.stream,
      context: const BackendErrorContext(
        service: BackendService.firestore,
        action: 'watch clubs by ids',
        resource: _collectionPath,
      ),
    );
  }

  static List<Club> _appDiscoverableClubs(Iterable<Club> clubs) =>
      clubs.where((club) => club.isAppDiscoverable).toList(growable: false);

  // ── Write ──────────────────────────────────────────────────────────────────

  String generateId() => _clubRef().id;

  Future<String> createClub({
    String? clubId,
    required String name,
    required String description,
    required String location,
    required String area,
    String? imageUrl,
    String? profileImageUrl,
    String? instagramHandle,
    String? phoneNumber,
    String? email,
    ClubHostDefaults? hostDefaults,
  }) => withBackendErrorContext(
    () async {
      final result = await _functions
          .httpsCallable('createClub')
          .call<Object?>(
            CreateClubCallableRequest(
              clubId: clubId,
              name: name,
              description: description,
              location: location,
              area: area,
              imageUrl: imageUrl,
              profileImageUrl: profileImageUrl,
              instagramHandle: instagramHandle,
              phoneNumber: phoneNumber,
              email: email,
              hostDefaults: hostDefaults,
            ).toJson(),
          );
      return CreateClubCallableResponse.fromCallableData(result.data).clubId;
    },
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'create club',
      resource: _collectionPath,
    ),
  );

  /// Updates only the fields present in [patch] via the `updateClub` callable.
  Future<void> updateClub({
    required String clubId,
    required UpdateClubPatch patch,
  }) => withBackendErrorContext(
    () => _functions
        .httpsCallable('updateClub')
        .call(patch.toCallableJson(clubId: clubId)),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'update club',
      resource: _collectionPath,
    ),
  );

  // ── Members ────────────────────────────────────────────────────────────────

  /// Adds the signed-in user to [clubId] via the `joinClub` callable.
  ///
  /// Membership touches both `clubs/{clubId}` and `users/{uid}`, so the
  /// server owns this mutation and Firestore rules can keep membership fields
  /// read-only to direct client writes.
  Future<void> joinClub(String clubId) => withBackendErrorContext(
    () => _functions
        .httpsCallable('joinClub')
        .call(ClubMembershipCallableRequest(clubId: clubId).toJson()),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'join club',
      resource: _collectionPath,
    ),
  );

  /// Removes the signed-in user from [clubId] via the `leaveClub` callable.
  Future<void> leaveClub(String clubId) => withBackendErrorContext(
    () => _functions
        .httpsCallable('leaveClub')
        .call(ClubMembershipCallableRequest(clubId: clubId).toJson()),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'leave club',
      resource: _collectionPath,
    ),
  );

  /// Updates the signed-in user's per-club push notification opt-in.
  Future<void> setClubPushNotifications({
    required String clubId,
    required bool enabled,
  }) => withBackendErrorContext(
    () => _functions
        .httpsCallable('setClubNotificationPreference')
        .call(
          SetClubNotificationPreferenceCallableRequest(
            clubId: clubId,
            enabled: enabled,
          ).toJson(),
        ),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'update club notifications',
      resource: _collectionPath,
    ),
  );

  Future<void> addClubHost({
    required String clubId,
    String? uid,
    String? phoneNumber,
  }) => withBackendErrorContext(
    () => _functions
        .httpsCallable('addClubHost')
        .call(
          AddClubHostCallableRequest(
            clubId: clubId,
            uid: uid,
            phoneNumber: phoneNumber,
          ).toJson(),
        ),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'add club host',
      resource: _collectionPath,
    ),
  );

  Future<void> removeClubHost({required String clubId, required String uid}) =>
      withBackendErrorContext(
        () => _functions
            .httpsCallable('removeClubHost')
            .call(
              RemoveClubHostCallableRequest(clubId: clubId, uid: uid).toJson(),
            ),
        context: const BackendErrorContext(
          service: BackendService.functions,
          action: 'remove club host',
          resource: _collectionPath,
        ),
      );

  Future<void> transferClubOwnership({
    required String clubId,
    required String uid,
  }) => withBackendErrorContext(
    () => _functions
        .httpsCallable('transferClubOwnership')
        .call(
          TransferClubOwnershipCallableRequest(
            clubId: clubId,
            uid: uid,
          ).toJson(),
        ),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'transfer club ownership',
      resource: _collectionPath,
    ),
  );

  Future<String> startClubHostConversation({
    required String clubId,
    required String hostUid,
  }) => withBackendErrorContext(
    () async {
      final result = await _functions
          .httpsCallable('startClubHostConversation')
          .call(
            StartClubHostConversationCallableRequest(
              clubId: clubId,
              hostUid: hostUid,
            ).toJson(),
          );
      return StartClubHostConversationCallableResponse.fromCallableData(
        result.data,
      ).matchId;
    },
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'start club host conversation',
      resource: _collectionPath,
    ),
  );
}

@Riverpod(keepAlive: true)
ClubsRepository clubsRepository(Ref ref) => ClubsRepository(
  ref.watch(firebaseFirestoreProvider),
  ref.watch(firebaseFunctionsProvider),
);

@riverpod
Stream<Club?> watchClub(Ref ref, String id) {
  final repository = ref.watch(clubsRepositoryProvider);
  return repository.watchClub(id);
}

@riverpod
Stream<List<Club>> watchClubsByLocation(Ref ref, String location) {
  final repository = ref.watch(clubsRepositoryProvider);
  return repository.watchClubsByLocation(location);
}

@riverpod
Stream<List<Club>> watchClubsByLocationSortedByRating(
  Ref ref,
  String location,
) {
  final repository = ref.watch(clubsRepositoryProvider);
  return repository.watchClubsByLocationSortedByRating(location);
}

@riverpod
Stream<List<Club>> watchClubsHostedBy(Ref ref, String uid) {
  final repository = ref.watch(clubsRepositoryProvider);
  return repository.watchClubsHostedBy(uid);
}

@riverpod
Stream<List<Club>> watchClubsOwnedBy(Ref ref, String uid) {
  final repository = ref.watch(clubsRepositoryProvider);
  return repository.watchClubsOwnedBy(uid);
}

@riverpod
Future<Club?> fetchClub(Ref ref, String id) =>
    ref.watch(clubsRepositoryProvider).fetchClub(id);

@riverpod
Stream<List<Club>> watchClubsByIds(Ref ref, ClubsByIdQuery query) =>
    ref.watch(clubsRepositoryProvider).watchClubsByIds(clubIds: query.clubIds);

class ClubsByIdQuery {
  ClubsByIdQuery._(Iterable<String> clubIds)
    : clubIds = List.unmodifiable(clubIds.toSet().toList()..sort());

  factory ClubsByIdQuery(Iterable<String> clubIds) => ClubsByIdQuery._(clubIds);

  static const _equality = ListEquality<String>();

  final List<String> clubIds;

  @override
  bool operator ==(Object other) {
    return other is ClubsByIdQuery && _equality.equals(other.clubIds, clubIds);
  }

  @override
  int get hashCode => _equality.hash(clubIds);
}
