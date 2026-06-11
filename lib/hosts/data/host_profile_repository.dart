import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostProfileRepository {
  const HostProfileRepository(this._db);

  static const collectionPath = 'hostProfiles';

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _hostProfileRef(String uid) =>
      _db.collection(collectionPath).doc(uid);

  Stream<HostProfile?> watchHostProfile(String uid) => withBackendErrorStream(
    () => _hostProfileRef(uid).snapshots().map(
      (doc) => doc.exists ? HostProfile.fromDocument(doc) : null,
    ),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch host profile',
      resource: collectionPath,
    ),
  );

  Future<void> ensureHostProfile({
    required String uid,
    required String displayName,
  }) => withBackendErrorContext(
    () => _hostProfileRef(uid).set({
      'displayName': displayName.trim().isEmpty
          ? 'Catch Host'
          : displayName.trim(),
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'save host profile',
      resource: collectionPath,
    ),
  );

  Future<void> saveHostProfile({
    required String uid,
    required String displayName,
    String? roleTitle,
    String? bio,
  }) => withBackendErrorContext(
    () => _hostProfileRef(uid).set({
      'displayName': displayName.trim(),
      'roleTitle': _nullableTrimmed(roleTitle),
      'bio': _nullableTrimmed(bio),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'save host profile',
      resource: collectionPath,
    ),
  );
}

String? _nullableTrimmed(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

final hostProfileRepositoryProvider = Provider<HostProfileRepository>((ref) {
  return HostProfileRepository(ref.watch(firebaseFirestoreProvider));
});

final watchHostProfileProvider = StreamProvider.autoDispose
    .family<HostProfile?, String>((ref, uid) {
      return ref.watch(hostProfileRepositoryProvider).watchHostProfile(uid);
    });
