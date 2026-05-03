import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/onboarding/domain/onboarding_draft.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_draft_repository.g.dart';

class OnboardingDraftRepository {
  const OnboardingDraftRepository(this._db);

  static const _collectionPath = 'onboarding_drafts';

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _draftRef(String uid) =>
      _db.collection(_collectionPath).doc(uid);

  Future<OnboardingDraft?> fetchDraft({required String uid}) async {
    final snap = await _draftRef(uid).get();
    if (!snap.exists) return null;
    return OnboardingDraft.fromJson(snap.data()!);
  }

  Future<void> saveDraft({
    required String uid,
    required OnboardingDraft draft,
  }) => _draftRef(uid).set(draft.toJson());

  Future<void> deleteDraft({required String uid}) =>
      _draftRef(uid).delete();
}

@Riverpod(keepAlive: true)
OnboardingDraftRepository onboardingDraftRepository(Ref ref) =>
    OnboardingDraftRepository(ref.watch(firebaseFirestoreProvider));
