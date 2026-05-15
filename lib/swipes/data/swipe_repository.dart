import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/profile_schema_contracts.g.dart'
    as schema_contracts;
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'swipe_repository.g.dart';

class SwipeRepository {
  const SwipeRepository(this._db);

  static const _collectionPath =
      schema_contracts.schemaProfileDecisionCollectionPath;
  static const _futureCollectionPath =
      schema_contracts.schemaProfileDecisionFutureCollectionPath;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _outgoingSwipesRef(String uid) =>
      _db
          .collection(_collectionPath)
          .doc(uid)
          .collection(
            schema_contracts.schemaProfileDecisionOutgoingSubcollectionPath,
          );

  CollectionReference<Map<String, dynamic>> _futureOutgoingSwipesRef(
    String uid,
  ) => _db
      .collection(_futureCollectionPath)
      .doc(uid)
      .collection(
        schema_contracts.schemaProfileDecisionFutureOutgoingSubcollectionPath,
      );

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Returns the set of user IDs this user has already swiped on.
  Future<Set<String>> fetchSwipedUserIds({required String uid}) =>
      withBackendErrorContext(
        () async {
          final snaps = await Future.wait([
            _outgoingSwipesRef(uid).get(),
            _futureOutgoingSwipesRef(uid).get(),
          ]);
          return {
            for (final snap in snaps)
              for (final doc in snap.docs) doc.id,
          };
        },
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'fetch swiped users',
          resource: _collectionPath,
        ),
      );

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> recordSwipe({required Swipe swipe}) => withBackendErrorContext(
    () {
      final comment = normalizeSwipeReactionComment(swipe.comment);
      final reactionFields = <String, Object?>{
        if (swipe.reactionTargetId != null)
          'reactionTargetId': swipe.reactionTargetId,
        if (swipe.reactionTargetType != null)
          'reactionTargetType': swipe.reactionTargetType!.name,
        if (swipe.reactionTargetLabel != null)
          'reactionTargetLabel': swipe.reactionTargetLabel,
        if (swipe.reactionTargetPreview != null)
          'reactionTargetPreview': swipe.reactionTargetPreview,
      };
      if (comment != null) {
        reactionFields['comment'] = comment;
      }

      final payload = {
        'swiperId': swipe.swiperId,
        'targetId': swipe.targetId,
        'runId': swipe.runId,
        'direction': swipe.direction.name,
        ...reactionFields,
        'createdAt': FieldValue.serverTimestamp(),
      };
      final batch = _db.batch();
      batch
        ..set(_outgoingSwipesRef(swipe.swiperId).doc(swipe.targetId), payload)
        ..set(
          _futureOutgoingSwipesRef(swipe.swiperId).doc(swipe.targetId),
          payload,
        );
      return batch.commit();
    },
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'record swipe',
      resource: _collectionPath,
    ),
  );
}

@riverpod
SwipeRepository swipeRepository(Ref ref) =>
    SwipeRepository(ref.watch(firebaseFirestoreProvider));
