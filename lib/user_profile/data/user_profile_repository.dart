import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_profile_repository.g.dart';

class UserProfileRepository {
  const UserProfileRepository(this._db);

  static const _collectionPath = 'users';

  final FirebaseFirestore _db;

  CollectionReference<UserProfile> get _usersRef => _db
      .collection(_collectionPath)
      .withDocumentIdConverter<UserProfile>(
        idField: 'uid',
        fromJson: UserProfile.fromJson,
        toJson: (user) => user.toJson(),
      );

  DocumentReference<UserProfile> _userRef(String uid) => _usersRef.doc(uid);

  // ── Read ──────────────────────────────────────────────────────────────────

  Stream<UserProfile?> watchUserProfile({required String? uid}) {
    if (uid == null) return Stream.value(null);
    return _userRef(
      uid,
    ).snapshots().map((snap) => snap.exists ? snap.data() : null);
  }

  Future<UserProfile?> fetchUserProfile({required String? uid}) async {
    if (uid == null) return null;
    final doc = await _userRef(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> setUserProfile({required UserProfile userProfile}) =>
      _userRef(userProfile.uid).set(userProfile);

  Future<void> updatePhotoUrls({
    required String uid,
    required List<String> photoUrls,
  }) => _userRef(uid).update({'photoUrls': photoUrls});

  Future<void> setProfileComplete({required String uid}) =>
      _userRef(uid).update({'profileComplete': true});

  Future<void> saveRun({required String uid, required String runId}) =>
      _userRef(uid).update({
        'savedRunIds': FieldValue.arrayUnion([runId]),
      });

  Future<void> unsaveRun({required String uid, required String runId}) =>
      _userRef(uid).update({
        'savedRunIds': FieldValue.arrayRemove([runId]),
      });
}

@Riverpod(keepAlive: true)
UserProfileRepository userProfileRepository(Ref ref) =>
    UserProfileRepository(ref.watch(firebaseFirestoreProvider));

@Riverpod(keepAlive: true)
Stream<UserProfile?> userProfileStream(Ref ref) {
  final uidAsync = ref.watch(uidProvider);

  return switch (uidAsync) {
    AsyncData(:final value) =>
      ref.watch(userProfileRepositoryProvider).watchUserProfile(uid: value),
    AsyncError(:final error, :final stackTrace) => Stream.error(
      error,
      stackTrace,
    ),
    _ => const Stream.empty(),
  };
}
