import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth/auth_test_helpers.dart';

void main() {
  group('OnboardingController.sendOtp', () {
    test(
      'prefixes +91 and advances to the OTP step when code is sent',
      () async {
        final repository = FakeAuthRepository()
          ..onVerifyPhoneNumber =
              ({
                required verificationCompleted,
                required verificationFailed,
                required codeSent,
                required codeAutoRetrievalTimeout,
              }) {
                codeSent('verification-id', 11);
              };
        final container = createAuthTestContainer(
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(repository.dispose);
        addTearDown(container.dispose);

        final notifier = container.read(onboardingControllerProvider.notifier);

        await notifier.sendOtp('9999999999');

        expect(repository.verifiedPhoneNumber, '+919999999999');
        expect(
          container.read(onboardingControllerProvider),
          const OnboardingData(
            step: 2,
            phoneNumber: '9999999999',
            verificationId: 'verification-id',
          ),
        );
        expect(repository.credential, isNull);
        expect(repository.otpVerificationId, isNull);
      },
    );

    test(
      'uses signInWithCredential during auto verification and advances to profile',
      () async {
        final credential = PhoneAuthProvider.credential(
          verificationId: 'verification-id',
          smsCode: '123456',
        );
        final repository = FakeAuthRepository()
          ..onVerifyPhoneNumber =
              ({
                required verificationCompleted,
                required verificationFailed,
                required codeSent,
                required codeAutoRetrievalTimeout,
              }) {
                verificationCompleted(credential);
              };
        final container = createAuthTestContainer(
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(repository.dispose);
        addTearDown(container.dispose);

        final notifier = container.read(onboardingControllerProvider.notifier);

        await notifier.sendOtp('9999999999');

        expect(repository.credential, same(credential));
        expect(repository.otpVerificationId, isNull);
        expect(container.read(onboardingControllerProvider).step, 3);
      },
    );
  });
}
