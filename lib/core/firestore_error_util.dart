import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Wraps [operation], catching [FirebaseException] and rethrowing it as a
/// [FirestoreWriteException] annotated with the collection name and action.
///
/// The wrapped exception keeps the original Firebase error code so callers
/// and error-display utilities can still pattern-match on it.
///
/// Example:
/// ```dart
/// await withFirestoreErrorContext(
///   () => _userRef(uid).set(profile),
///   collection: 'users',
///   action: 'create profile',
/// );
/// ```
Future<T> withFirestoreErrorContext<T>(
  Future<T> Function() operation, {
  required String collection,
  required String action,
}) async {
  try {
    return await operation();
  } on FirebaseException catch (e) {
    throw FirestoreWriteException(
      code: e.code,
      message: '$action on $collection failed: [${e.code}] ${e.message}',
    );
  }
}
