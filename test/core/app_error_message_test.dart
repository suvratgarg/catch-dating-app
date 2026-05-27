import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('appErrorDescriptor', () {
    test('describes retryable network failures', () {
      const error = NetworkException(
        'timeout',
        'The request timed out. Please try again.',
      );

      final descriptor = appErrorDescriptor(error);

      expect(descriptor.title, 'Connection issue');
      expect(descriptor.message, 'The request timed out. Please try again.');
      expect(descriptor.icon, CatchIcons.wifiOffRounded);
      expect(descriptor.retryable, isTrue);
      expect(descriptor.retryLabel, 'Try again');
      expect(descriptor.severity, AppErrorSeverity.warning);
    });

    test('describes validation failures as non-retryable user fixes', () {
      const error = ValidationException('Please enter a valid phone number.');

      final descriptor = appErrorDescriptor(
        error,
        context: AppErrorContext.auth,
      );

      expect(descriptor.title, 'Check your details');
      expect(descriptor.message, 'Please enter a valid phone number.');
      expect(descriptor.icon, CatchIcons.editNoteRounded);
      expect(descriptor.retryable, isFalse);
    });

    test('uses context-specific titles and retry labels for load failures', () {
      const error = BackendOperationException(
        code: 'unavailable',
        message: 'Unable to load messages right now. Please try again.',
        context: BackendErrorContext(
          service: BackendService.firestore,
          action: 'load messages',
          resource: 'matches',
        ),
        retryable: true,
      );

      final descriptor = appErrorDescriptor(
        error,
        context: AppErrorContext.chat,
      );

      expect(descriptor.title, 'Messages unavailable');
      expect(descriptor.retryLabel, 'Reload messages');
      expect(descriptor.retryable, isTrue);
    });

    test('does not expose debug metadata in user-facing copy', () {
      const error = BackendOperationException(
        code: 'invalid-argument',
        message: 'Unable to create event right now. Please try again.',
        debugMessage:
            'functions.create event failed with cloud_functions/invalid-argument: '
            'eventSuccessDefaults: must NOT have additional properties',
        context: BackendErrorContext(
          service: BackendService.functions,
          action: 'create event',
          resource: 'events',
        ),
      );

      final descriptor = appErrorDescriptor(
        error,
        context: AppErrorContext.event,
      );

      expect(
        descriptor.message,
        'Unable to create event right now. Please try again.',
      );
      expect(descriptor.message, isNot(contains('[DEBUG]')));
      expect(descriptor.message, isNot(contains('firebase_functions')));
      expect(descriptor.message, isNot(contains('additional properties')));
    });

    test('uses catches copy for swipe load failures', () {
      const error = BackendOperationException(
        code: 'swipe-candidates-timeout',
        message: 'Swipe profiles are taking too long to load.',
        context: BackendErrorContext(
          service: BackendService.firestore,
          action: 'load swipe candidates',
          resource: 'swipe_candidates',
        ),
        retryable: true,
      );

      final descriptor = appErrorDescriptor(
        error,
        context: AppErrorContext.swipes,
      );

      expect(descriptor.title, 'Catches unavailable');
      expect(descriptor.retryLabel, 'Reload catches');
      expect(descriptor.retryable, isTrue);
    });

    test('describes storage and external action failures', () {
      final upload = appErrorDescriptor(
        const StorageException(
          'Unable to upload right now. Please check your connection and try again.',
          retryable: true,
        ),
      );
      expect(upload.title, 'Upload failed');
      expect(upload.icon, CatchIcons.cloudUploadOutlined);
      expect(upload.retryLabel, 'Try upload again');

      final external = appErrorDescriptor(
        const ExternalActionException('Could not open that link.'),
      );
      expect(external.title, 'Action failed');
      expect(external.icon, CatchIcons.openInNewRounded);
      expect(external.retryable, isFalse);
    });

    test('keeps payment and event booking product errors distinct', () {
      expect(
        appErrorDescriptor(const PaymentVerificationFailedException()).title,
        'Payment verification failed',
      );
      expect(
        appErrorDescriptor(
          const EventBookingFailedException('This event is full.'),
        ).title,
        'Event signup unavailable',
      );
    });
  });
}
