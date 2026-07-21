import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';

/// Reads the canonical organizer projection and switches to the legacy club
/// projection only when production has not granted collection access yet.
///
/// A successful canonical result, including an empty result, is authoritative.
Stream<T> watchOrganizerProjectionWithFallback<T>({
  required Stream<T> Function() canonical,
  required Stream<T> Function() legacy,
  required BackendErrorContext context,
  required BackendErrorContext legacyContext,
}) async* {
  try {
    await for (final value in canonical()) {
      yield value;
    }
  } catch (error, stackTrace) {
    final normalized = normalizeBackendError(
      error,
      stackTrace: stackTrace,
      context: context,
    );
    if (!isOrganizerRolloutAccessFailure(normalized)) {
      Error.throwWithStackTrace(normalized, stackTrace);
    }
    yield* withBackendErrorStream(legacy, context: legacyContext);
  }
}

/// Future equivalent of [watchOrganizerProjectionWithFallback].
Future<T> fetchOrganizerProjectionWithFallback<T>({
  required Future<T> Function() canonical,
  required Future<T> Function() legacy,
  required BackendErrorContext context,
  required BackendErrorContext legacyContext,
}) async {
  try {
    return await withBackendErrorContext(canonical, context: context);
  } catch (error, stackTrace) {
    final normalized = normalizeBackendError(
      error,
      stackTrace: stackTrace,
      context: context,
    );
    if (!isOrganizerRolloutAccessFailure(normalized)) rethrow;
    return withBackendErrorContext(legacy, context: legacyContext);
  }
}

bool isOrganizerRolloutAccessFailure(AppException error) =>
    error is BackendOperationException &&
    error.code == 'backend-permission-denied';
