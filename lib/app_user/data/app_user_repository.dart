import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_user_repository.g.dart';

class AppUserRepository {
  const AppUserRepository(this._db);

  static const _collectionPath = 'users';

  final FirebaseFirestore _db;

  CollectionReference<AppUser> get _usersRef => _db
      .collection(_collectionPath)
      .withConverter<AppUser>(
        fromFirestore: (doc, _) =>
            AppUser.fromJson({...doc.data()!, 'uid': doc.id}),
        toFirestore: (user, _) => user.toJson(),
      );

  DocumentReference<AppUser> _userRef(String uid) => _usersRef.doc(uid);

  // ── Read ──────────────────────────────────────────────────────────────────

  Stream<AppUser?> watchAppUser({required String? uid}) {
    if (uid == null) return Stream.value(null);
    return _userRef(
      uid,
    ).snapshots().map((snap) => snap.exists ? snap.data() : null);
  }

  Future<AppUser?> fetchAppUser({required String? uid}) async {
    if (uid == null) return null;
    final doc = await _userRef(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> setAppUser({required AppUser appUser}) =>
      _userRef(appUser.uid).set(appUser);

  Future<void> updatePhotoUrls({
    required String uid,
    required List<String> photoUrls,
  }) => _userRef(uid).update({'photoUrls': photoUrls});

  Future<void> setProfileComplete({required String uid}) =>
      _userRef(uid).update({'profileComplete': true});
}

@Riverpod(keepAlive: true)
AppUserRepository appUserRepository(Ref ref) =>
    AppUserRepository(ref.watch(firebaseFirestoreProvider));

@Riverpod(keepAlive: true)
Stream<AppUser?> appUserStream(Ref ref) {
  final uidAsync = ref.watch(uidProvider);

  return switch (uidAsync) {
    AsyncData(:final value) =>
      ref.watch(appUserRepositoryProvider).watchAppUser(uid: value),
    AsyncError(:final error, :final stackTrace) => Stream.error(
      error,
      stackTrace,
    ),
    _ => const Stream.empty(),
  };
}
