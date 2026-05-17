import 'dart:async';

import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'club_membership_repository.g.dart';

class ClubMembershipRepository {
  const ClubMembershipRepository(this._db);

  static const _collectionPath = 'clubMemberships';

  final FirebaseFirestore _db;

  CollectionReference<ClubMembership> get _membershipsRef => _db
      .collection(_collectionPath)
      .withDocumentIdConverter<ClubMembership>(
        idField: 'id',
        fromJson: ClubMembership.fromJson,
        toJson: (membership) => membership.toJson(),
      );

  Stream<List<ClubMembership>> watchActiveMembershipsForUser({
    required String uid,
  }) => withBackendErrorStream(
    () => _membershipsRef
        .where('uid', isEqualTo: uid)
        .where('status', isEqualTo: ClubMembershipStatus.active.name)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch user club memberships',
      resource: _collectionPath,
    ),
  );

  Stream<List<ClubMembership>> watchActiveMembershipsForClub({
    required String clubId,
  }) => withBackendErrorStream(
    () => _membershipsRef
        .where('clubId', isEqualTo: clubId)
        .where('status', isEqualTo: ClubMembershipStatus.active.name)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch club memberships',
      resource: _collectionPath,
    ),
  );

  Stream<ClubMembership?> watchMembership({
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
ClubMembershipRepository clubMembershipRepository(Ref ref) =>
    ClubMembershipRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<List<ClubMembership>> watchActiveClubMembershipsForUser(
  Ref ref,
  String uid,
) => ref
    .watch(clubMembershipRepositoryProvider)
    .watchActiveMembershipsForUser(uid: uid);

@riverpod
Stream<List<ClubMembership>> watchActiveClubMembershipsForClub(
  Ref ref,
  String clubId,
) => ref
    .watch(clubMembershipRepositoryProvider)
    .watchActiveMembershipsForClub(clubId: clubId);

@riverpod
Stream<ClubMembership?> watchClubMembership(
  Ref ref,
  String clubId,
  String uid,
) => ref
    .watch(clubMembershipRepositoryProvider)
    .watchMembership(clubId: clubId, uid: uid);
