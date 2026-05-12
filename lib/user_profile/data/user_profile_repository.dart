import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/firestore_error_util.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_profile_repository.g.dart';

class UserProfileRepository {
  const UserProfileRepository(this._db, this._functions);

  static const _collectionPath = 'users';

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

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
      withFirestoreErrorContext(
        () => _userRef(userProfile.uid).set(userProfile),
        collection: _collectionPath,
        action: 'set profile',
      );

  /// Applies a validated profile patch via the `updateUserProfile` callable.
  ///
  /// Profile edits are server-owned after initial profile creation because this
  /// document has many fast-evolving fields and Firestore rules hit expression
  /// limits when they try to validate every changed field directly.
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> fields,
  }) => withFirestoreErrorContext(
    () => _functions.httpsCallable('updateUserProfile').call({
      'fields': _callableFields(fields),
    }),
    collection: _collectionPath,
    action: 'update profile',
  );

  Future<void> updatePhotoUrls({
    required String uid,
    required List<String> photoUrls,
  }) => withFirestoreErrorContext(
    () => updateUserProfile(uid: uid, fields: {'photoUrls': photoUrls}),
    collection: _collectionPath,
    action: 'update photo URLs',
  );

  Future<void> updateDetectedLocation({
    required String uid,
    required double latitude,
    required double longitude,
    String? city,
  }) {
    final cityPatch = city == null ? null : {'city': city};
    return updateUserProfile(
      uid: uid,
      fields: {'latitude': latitude, 'longitude': longitude, ...?cityPatch},
    );
  }

  Future<void> setProfileComplete({required String uid}) =>
      withFirestoreErrorContext(
        () => updateUserProfile(uid: uid, fields: {'profileComplete': true}),
        collection: _collectionPath,
        action: 'set profile complete',
      );
}

Map<String, Object?> _callableFields(Map<String, dynamic> fields) =>
    fields.map((key, value) => MapEntry(key, _callableValue(value)));

Object? _callableValue(Object? value) {
  if (value is Timestamp) {
    return value.millisecondsSinceEpoch;
  }
  if (value is DateTime) {
    return value.millisecondsSinceEpoch;
  }
  if (value is Iterable) {
    return value.map(_callableValue).toList();
  }
  return value;
}

@Riverpod(keepAlive: true)
UserProfileRepository userProfileRepository(Ref ref) => UserProfileRepository(
  ref.watch(firebaseFirestoreProvider),
  ref.watch(firebaseFunctionsProvider),
);

@Riverpod(keepAlive: true)
Stream<UserProfile?> watchUserProfile(Ref ref) {
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
