import 'dart:async';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

class TestFirebaseFunctionsException extends FirebaseFunctionsException {
  TestFirebaseFunctionsException({required super.code, required super.message});
}

void main() {
  const firestoreContext = BackendErrorContext(
    service: BackendService.firestore,
    action: 'load runs',
    resource: 'runs',
  );

  group('normalizeBackendError', () {
    test('preserves existing AppException instances', () {
      const error = ValidationException('Name is required.');

      expect(
        normalizeBackendError(error, context: firestoreContext),
        same(error),
      );
    });

    test('lets feature mappers preserve domain-specific exceptions', () {
      final mapped = normalizeBackendError(
        StateError('server refused booking'),
        context: const BackendErrorContext(
          service: BackendService.functions,
          action: 'book run',
          resource: 'runs',
        ),
        mapper: (error, stackTrace, context) =>
            RunBookingFailedException('This run is full.', context: context),
      );

      expect(mapped, isA<RunBookingFailedException>());
      expect(mapped.message, 'This run is full.');
      expect(mapped.context?.service, BackendService.functions);
    });

    test('maps common Firestore failures to typed app exceptions', () {
      expect(
        normalizeBackendError(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
          context: firestoreContext,
        ),
        isA<PermissionException>(),
      );

      final network = normalizeBackendError(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
        context: firestoreContext,
      );
      expect(network, isA<NetworkException>());
      expect(network.retryable, isTrue);

      final missing = normalizeBackendError(
        FirebaseException(plugin: 'cloud_firestore', code: 'not-found'),
        context: firestoreContext,
      );
      expect(missing, isA<DocumentNotFoundException>());
      expect(missing.context?.resource, 'runs');
    });

    test('maps callable Functions failures with Functions service context', () {
      final error = normalizeBackendError(
        TestFirebaseFunctionsException(
          code: 'unauthenticated',
          message: 'Auth required',
        ),
        context: const BackendErrorContext(
          service: BackendService.functions,
          action: 'join run',
          resource: 'runs',
        ),
      );

      expect(error, isA<SignInRequiredException>());
      expect(error.context?.service, BackendService.functions);
      expect(error.context?.action, 'join run');
    });

    test('maps Firebase Auth validation and retry failures', () {
      final invalidCode = normalizeBackendError(
        FirebaseAuthException(code: 'invalid-verification-code'),
        context: const BackendErrorContext(
          service: BackendService.auth,
          action: 'verify OTP',
        ),
      );
      expect(invalidCode, isA<ValidationException>());
      expect(invalidCode.code, 'invalid-verification-code');

      final tooManyRequests = normalizeBackendError(
        FirebaseAuthException(code: 'too-many-requests'),
        context: const BackendErrorContext(
          service: BackendService.auth,
          action: 'send OTP',
        ),
      );
      expect(tooManyRequests, isA<NetworkException>());
      expect(tooManyRequests.retryable, isTrue);
    });

    test('maps Firebase Storage failures', () {
      final denied = normalizeBackendError(
        FirebaseException(plugin: 'firebase_storage', code: 'unauthorized'),
        context: const BackendErrorContext(
          service: BackendService.storage,
          action: 'upload profile photo',
          resource: 'profile_photos',
        ),
      );
      expect(denied, isA<PermissionException>());

      final retryable = normalizeBackendError(
        FirebaseException(
          plugin: 'firebase_storage',
          code: 'retry-limit-exceeded',
        ),
        context: const BackendErrorContext(
          service: BackendService.storage,
          action: 'upload profile photo',
          resource: 'profile_photos',
        ),
      );
      expect(retryable, isA<StorageException>());
      expect(retryable.retryable, isTrue);
    });

    test('maps Remote Config, App Check, and Messaging failures', () {
      final remoteConfig = normalizeBackendError(
        FirebaseException(
          plugin: 'firebase_remote_config',
          code: 'fetch-throttled',
        ),
        context: const BackendErrorContext(
          service: BackendService.remoteConfig,
          action: 'check minimum app version',
        ),
      );
      expect(remoteConfig, isA<BackendOperationException>());
      expect(remoteConfig.retryable, isTrue);

      final appCheck = normalizeBackendError(
        FirebaseException(plugin: 'firebase_app_check', code: 'token-error'),
        context: const BackendErrorContext(
          service: BackendService.appCheck,
          action: 'verify app session',
        ),
      );
      expect(appCheck, isA<BackendOperationException>());
      expect(appCheck.severity, AppErrorSeverity.error);

      final messaging = normalizeBackendError(
        FirebaseException(
          plugin: 'firebase_messaging',
          code: 'network-request-failed',
        ),
        context: const BackendErrorContext(
          service: BackendService.messaging,
          action: 'save push token',
        ),
      );
      expect(messaging, isA<BackendOperationException>());
      expect(messaging.retryable, isTrue);
    });

    test('maps timeouts and unexpected errors with backend context', () {
      final timeout = normalizeBackendError(
        TimeoutException('slow'),
        context: firestoreContext,
      );
      expect(timeout, isA<NetworkException>());
      expect(timeout.context?.action, 'load runs');

      final unexpected = normalizeBackendError(
        StateError('bad decode'),
        context: firestoreContext,
      );
      expect(unexpected, isA<BackendOperationException>());
      expect(unexpected.code, 'unexpected');
      expect(unexpected.severity, AppErrorSeverity.error);
      expect(unexpected.context?.service, BackendService.firestore);
    });
  });
}
