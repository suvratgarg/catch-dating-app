import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'public_profile_repository.g.dart';

class PublicProfileRepository {
  const PublicProfileRepository(this._db);

  static const _collectionPath = 'publicProfiles';

  final FirebaseFirestore _db;

  CollectionReference<PublicProfile> get _publicProfilesRef => _db
      .collection(_collectionPath)
      .withDocumentIdConverter<PublicProfile>(
        idField: 'uid',
        fromJson: PublicProfile.fromJson,
        toJson: (profile) => profile.toJson(),
      );

  DocumentReference<PublicProfile> _publicProfileRef(String uid) =>
      _publicProfilesRef.doc(uid);

  // ── Read ──────────────────────────────────────────────────────────────────

  Stream<PublicProfile?> watchPublicProfile({required String uid}) =>
      _publicProfileRef(
        uid,
      ).snapshots().map((doc) => doc.exists ? doc.data() : null);

  Future<PublicProfile?> fetchPublicProfile({required String uid}) async {
    final doc = await _publicProfileRef(uid).get();
    return doc.exists ? doc.data() : null;
  }

  /// Batch-fetches profiles by UID. Splits into chunks of 30 to respect
  /// Firestore's `whereIn` limit.
  Future<List<PublicProfile>> fetchPublicProfiles(List<String> uids) async {
    if (uids.isEmpty) return [];

    final profiles = <PublicProfile>[];
    for (var i = 0; i < uids.length; i += 30) {
      final chunk = uids.sublist(i, (i + 30).clamp(0, uids.length));
      final snap = await _publicProfilesRef
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      profiles.addAll(snap.docs.map((d) => d.data()));
    }
    return profiles;
  }
}

@riverpod
PublicProfileRepository publicProfileRepository(Ref ref) =>
    PublicProfileRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<PublicProfile?> publicProfile(Ref ref, String uid) =>
    ref.watch(publicProfileRepositoryProvider).watchPublicProfile(uid: uid);
