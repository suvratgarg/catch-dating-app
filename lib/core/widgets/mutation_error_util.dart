import 'package:catch_dating_app/core/firestore_error_message.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';

/// Returns a user-facing error message for a mutation in error state.
///
/// Usage:
/// ```dart
/// if (mutation.hasError)
///   ErrorBanner(message: mutationErrorMessage(mutation)),
/// ```
String mutationErrorMessage(MutationState mutation) {
  if (!mutation.hasError) return '';
  return firestoreErrorMessage((mutation as MutationError).error);
}
