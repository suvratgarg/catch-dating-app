import 'dart:async';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club_membership.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_club_membership_repository.g.dart';

class RunClubMembershipRepository {
  const RunClubMembershipRepository(this._db);

  static const _collectionPath = 'runClubMemberships';

  final FirebaseFirestore _db;

  CollectionReference<RunClubMembership> get _membershipsRef => _db
      .collection(_collectionPath)
      .withDocumentIdConverter<RunClubMembership>(
        idField: 'id',
        fromJson: RunClubMembership.fromJson,
        toJson: (membership) => membership.toJson(),
      );

  Stream<List<RunClubMembership>> watchActiveMembershipsForUser({
    required String uid,
  }) => withBackendErrorStream(
    () => _membershipsRef
        .where('uid', isEqualTo: uid)
        .where('status', isEqualTo: RunClubMembershipStatus.active.name)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch user club memberships',
      resource: _collectionPath,
    ),
  );

  Stream<List<RunClubMembership>> watchActiveMembershipsForClub({
    required String clubId,
  }) => withBackendErrorStream(
    () => _membershipsRef
        .where('clubId', isEqualTo: clubId)
        .where('status', isEqualTo: RunClubMembershipStatus.active.name)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch club memberships',
      resource: _collectionPath,
    ),
  );

  Stream<RunClubMembership?> watchMembership({
    required String clubId,
    required String uid,
  }) => withBackendErrorStream(
    () => _membershipsRef
        .where('clubId', isEqualTo: clubId)
        .where('uid', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty ? null : snap.docs.first.data()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch club membership',
      resource: _collectionPath,
    ),
  );
}

@Riverpod(keepAlive: true)
RunClubMembershipRepository runClubMembershipRepository(Ref ref) =>
    RunClubMembershipRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<List<RunClubMembership>> watchActiveRunClubMembershipsForUser(
  Ref ref,
  String uid,
) => ref
    .watch(runClubMembershipRepositoryProvider)
    .watchActiveMembershipsForUser(uid: uid);

@riverpod
Stream<List<RunClubMembership>> watchActiveRunClubMembershipsForClub(
  Ref ref,
  String clubId,
) => ref
    .watch(runClubMembershipRepositoryProvider)
    .watchActiveMembershipsForClub(clubId: clubId);

@riverpod
Stream<RunClubMembership?> watchRunClubMembership(
  Ref ref,
  String clubId,
  String uid,
) => ref
    .watch(runClubMembershipRepositoryProvider)
    .watchMembership(clubId: clubId, uid: uid);
