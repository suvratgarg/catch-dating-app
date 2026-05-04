import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Wraps [operation], catching [FirebaseException] and
/// [FirebaseFunctionsException] and rethrowing them as typed [AppException]
/// subclasses annotated with the collection name and action.
///
/// - [FirebaseException] codes are mapped to specific [AppException] subtypes
///   (e.g. `permission-denied` → [PermissionException]).
/// - [AppException] instances already thrown by the operation are re-thrown
///   as-is (no double-wrapping).
/// - All other exceptions are wrapped in a generic [FirestoreWriteException]
///   with code `unexpected`.
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
  } on AppException {
    rethrow;
  } on FirebaseFunctionsException catch (e) {
    // Must be caught before FirebaseException — FirebaseFunctionsException
    // is a subtype of FirebaseException.
    throw _mapFunctionsException(e, collection: collection, action: action);
  } on FirebaseException catch (e) {
    throw _mapFirebaseException(e, collection: collection, action: action);
  } catch (e, st) {
    throw FirestoreWriteException(
      code: 'unexpected',
      message: '$action on $collection failed unexpectedly.',
      cause: e,
      stackTrace: st,
      collection: collection,
      action: action,
    );
  }
}

AppException _mapFirebaseException(
  FirebaseException e, {
  required String collection,
  required String action,
}) {
  final message = '$action on $collection failed: [${e.code}] ${e.message}';
  return switch (e.code) {
    'permission-denied' => PermissionException(message),
    'unauthenticated' => SignInRequiredException(action),
    'unavailable' => NetworkException('connection-failed', message),
    'deadline-exceeded' => NetworkException('timeout', message),
    'resource-exhausted' => NetworkException('too-many-requests', message),
    'not-found' => DocumentNotFoundException('$collection/document'),
    _ => FirestoreWriteException(
      code: e.code,
      message: message,
      collection: collection,
      action: action,
    ),
  };
}

AppException _mapFunctionsException(
  FirebaseFunctionsException e, {
  required String collection,
  required String action,
}) {
  final message = '$action failed: [${e.code}] ${e.message}';
  return switch (e.code) {
    'unauthenticated' => SignInRequiredException(action),
    'permission-denied' => PermissionException(message),
    'unavailable' => NetworkException('connection-failed', message),
    'deadline-exceeded' => NetworkException('timeout', message),
    'resource-exhausted' => NetworkException('too-many-requests', message),
    _ => FirestoreWriteException(
      code: e.code,
      message: message,
      collection: collection,
      action: action,
    ),
  };
}
