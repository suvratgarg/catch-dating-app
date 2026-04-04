import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/publicProfile/domain/public_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'public_profile_repository.g.dart';

class PublicProfileRepository {
  PublicProfileRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<PublicProfile> _getCollectionReference() =>
      _db.collection('publicProfiles').withConverter<PublicProfile>(
        fromFirestore: (doc, _) =>
            PublicProfile.fromJson({...doc.data()!, 'uid': doc.id}),
        toFirestore: (profile, _) => profile.toJson(),
      );

  DocumentReference<PublicProfile> _getDocumentReference(String uid) =>
      _getCollectionReference().doc(uid);

  // ── Read ──────────────────────────────────────────────────────────────────

  Stream<PublicProfile?> watchPublicProfile({required String uid}) =>
      _getDocumentReference(uid)
          .snapshots()
          .map((doc) => doc.exists ? doc.data() : null);

  Future<PublicProfile?> fetchPublicProfile({required String uid}) async {
    final doc = await _getDocumentReference(uid).get();
    return doc.exists ? doc.data() : null;
  }

  /// Batch-fetches profiles by UID. Splits into chunks of 30 to respect
  /// Firestore's `whereIn` limit.
  Future<List<PublicProfile>> fetchPublicProfiles(
      List<String> uids) async {
    if (uids.isEmpty) return [];

    final profiles = <PublicProfile>[];
    for (var i = 0; i < uids.length; i += 30) {
      final chunk = uids.sublist(i, (i + 30).clamp(0, uids.length));
      final snap = await _getCollectionReference()
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      profiles.addAll(snap.docs.map((d) => d.data()));
    }
    return profiles;
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> setPublicProfile({required PublicProfile profile}) =>
      _getDocumentReference(profile.uid).set(profile);

  Future<void> updatePhotoUrls({
    required String uid,
    required List<String> photoUrls,
  }) => _getDocumentReference(uid).update({'photoUrls': photoUrls});
}

@riverpod
PublicProfileRepository publicProfileRepository(Ref ref) =>
    PublicProfileRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<PublicProfile?> publicProfile(Ref ref, String uid) =>
    ref.watch(publicProfileRepositoryProvider).watchPublicProfile(uid: uid);
