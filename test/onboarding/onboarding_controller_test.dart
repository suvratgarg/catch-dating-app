import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_profile_draft.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';
import 'onboarding_test_helpers.dart';

void main() {
  group('OnboardingController.initStep', () {
    test('starts on the welcome step for signed-out users', () async {
      final repository = FakeAuthRepository();
      final container = createOnboardingTestContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          uidProvider.overrideWith((ref) => Stream.value(null)),
          userProfileStreamProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);
      await primeOnboardingAsyncProviders(container);

      container.read(onboardingControllerProvider.notifier).initStep();

      expect(
        container.read(onboardingControllerProvider).step,
        OnboardingStep.welcome,
      );
    });

    test(
      'jumps to the profile step and reuses auth phone when no profile exists',
      () async {
        final repository = FakeAuthRepository()
          ..currentUserValue = TestUser(
            uid: 'runner-1',
            phoneNumber: '+919876543210',
          );
        final container = createOnboardingTestContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(repository),
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            userProfileStreamProvider.overrideWith((ref) => Stream.value(null)),
          ],
        );
        addTearDown(repository.dispose);
        addTearDown(container.dispose);
        await primeOnboardingAsyncProviders(container);

        container.read(onboardingControllerProvider.notifier).initStep();

        expect(
          container.read(onboardingControllerProvider),
          const OnboardingData(
            step: OnboardingStep.nameDob,
            phoneVerified: true,
            profileDraft: OnboardingProfileDraft(phoneNumber: '9876543210'),
          ),
        );
      },
    );

    test('jumps to the photos step for incomplete profiles', () async {
      final repository = FakeAuthRepository()
        ..currentUserValue = TestUser(uid: 'runner-1');
      final container = createOnboardingTestContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          userProfileStreamProvider.overrideWith(
            (ref) => Stream.value(
              buildUser(uid: 'runner-1').copyWith(profileComplete: false),
            ),
          ),
        ],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);
      await primeOnboardingAsyncProviders(container);

      container.read(onboardingControllerProvider.notifier).initStep();

      expect(
        container.read(onboardingControllerProvider).step,
        OnboardingStep.photos,
      );
    });
  });

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
        final container = createOnboardingTestContainer(
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
            step: OnboardingStep.otp,
            verificationId: 'verification-id',
            profileDraft: OnboardingProfileDraft(phoneNumber: '9999999999'),
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
        final container = createOnboardingTestContainer(
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(repository.dispose);
        addTearDown(container.dispose);

        final notifier = container.read(onboardingControllerProvider.notifier);

        await notifier.sendOtp('9999999999');

        expect(repository.credential, same(credential));
        expect(repository.otpVerificationId, isNull);
        expect(
          container.read(onboardingControllerProvider).step,
          OnboardingStep.nameDob,
        );
        expect(
          container.read(onboardingControllerProvider).phoneVerified,
          isTrue,
        );
      },
    );
  });

  group('OnboardingController.verifyOtp', () {
    test(
      'throws a friendly error when no verification session is active',
      () async {
        final repository = FakeAuthRepository();
        final container = createOnboardingTestContainer(
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(repository.dispose);
        addTearDown(container.dispose);

        await expectLater(
          container
              .read(onboardingControllerProvider.notifier)
              .verifyOtp('123456'),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              'Verification session expired. Please request a new code.',
            ),
          ),
        );
        expect(repository.otpVerificationId, isNull);
      },
    );

    test(
      'signs in with the stored verification id and marks the phone as verified',
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
        final container = createOnboardingTestContainer(
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(repository.dispose);
        addTearDown(container.dispose);
        final notifier = container.read(onboardingControllerProvider.notifier);

        await notifier.sendOtp('9999999999');
        await notifier.verifyOtp('123456');

        expect(repository.otpVerificationId, 'verification-id');
        expect(repository.otpSmsCode, '123456');
        expect(
          container.read(onboardingControllerProvider).step,
          OnboardingStep.nameDob,
        );
        expect(
          container.read(onboardingControllerProvider).phoneVerified,
          isTrue,
        );
      },
    );
  });

  group('OnboardingController.saveProfile', () {
    test('throws when the user is no longer signed in', () async {
      final repository = FakeAuthRepository();
      final userProfileRepository = FakeOnboardingUserProfileRepository();
      final container = createOnboardingTestContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          userProfileRepositoryProvider.overrideWith(
            (ref) => userProfileRepository,
          ),
          uidProvider.overrideWith((ref) => Stream.value(null)),
          userProfileStreamProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);
      await primeOnboardingAsyncProviders(container);

      final notifier = container.read(onboardingControllerProvider.notifier);
      notifier.setNameDob(
        firstName: 'Asha',
        lastName: 'Runner',
        dateOfBirth: DateTime(1997, 4, 15),
        phoneNumber: '9876543210',
      );
      notifier.setGenderInterest(
        gender: Gender.woman,
        sexualOrientation: SexualOrientation.straight,
        interestedInGenders: const [Gender.man],
      );

      await expectLater(
        notifier.saveProfile(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Please sign in again before continuing.',
          ),
        ),
      );
      expect(userProfileRepository.lastSavedUser, isNull);
    });

    test('persists the draft profile and advances to photos', () async {
      final repository = FakeAuthRepository()
        ..currentUserValue = TestUser(
          uid: 'runner-1',
          email: 'runner@example.com',
        );
      final userProfileRepository = FakeOnboardingUserProfileRepository();
      final container = createOnboardingTestContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          userProfileRepositoryProvider.overrideWith(
            (ref) => userProfileRepository,
          ),
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          userProfileStreamProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);
      await primeOnboardingAsyncProviders(container);

      final notifier = container.read(onboardingControllerProvider.notifier);
      notifier.setNameDob(
        firstName: 'Asha',
        lastName: 'Runner',
        dateOfBirth: DateTime(1997, 4, 15),
        phoneNumber: '9876543210',
      );
      notifier.setGenderInterest(
        gender: Gender.woman,
        sexualOrientation: SexualOrientation.straight,
        interestedInGenders: const [Gender.man],
      );

      await notifier.saveProfile();

      expect(userProfileRepository.lastSavedUser, isNotNull);
      expect(userProfileRepository.lastSavedUser!.uid, 'runner-1');
      expect(userProfileRepository.lastSavedUser!.email, 'runner@example.com');
      expect(userProfileRepository.lastSavedUser!.name, 'Asha Runner');
      expect(userProfileRepository.lastSavedUser!.phoneNumber, '+919876543210');
      expect(userProfileRepository.lastSavedUser!.profileComplete, isFalse);
      expect(
        container.read(onboardingControllerProvider).step,
        OnboardingStep.photos,
      );
    });
  });

  group('OnboardingController.complete', () {
    test('throws when the latest profile is unavailable', () async {
      final repository = FakeAuthRepository();
      final userProfileRepository = FakeOnboardingUserProfileRepository();
      final container = createOnboardingTestContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          userProfileRepositoryProvider.overrideWith(
            (ref) => userProfileRepository,
          ),
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          userProfileStreamProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);
      await primeOnboardingAsyncProviders(container);

      await expectLater(
        container
            .read(onboardingControllerProvider.notifier)
            .complete(
              paceMinSecsPerKm: 300,
              paceMaxSecsPerKm: 360,
              preferredDistances: const [PreferredDistance.tenK],
              runningReasons: const [RunReason.community],
            ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'User profile not loaded. Please try again.',
          ),
        ),
      );
    });

    test('saves running preferences and marks the profile complete', () async {
      final repository = FakeAuthRepository();
      final userProfileRepository = FakeOnboardingUserProfileRepository(
        currentUser: buildUser(
          uid: 'runner-1',
        ).copyWith(profileComplete: false),
      );
      final container = createOnboardingTestContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          userProfileRepositoryProvider.overrideWith(
            (ref) => userProfileRepository,
          ),
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          userProfileStreamProvider.overrideWith(
            (ref) => Stream.value(
              buildUser(uid: 'runner-1').copyWith(profileComplete: false),
            ),
          ),
        ],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);
      await primeOnboardingAsyncProviders(container);

      await container
          .read(onboardingControllerProvider.notifier)
          .complete(
            paceMinSecsPerKm: 305,
            paceMaxSecsPerKm: 355,
            preferredDistances: const [PreferredDistance.tenK],
            runningReasons: const [RunReason.community, RunReason.social],
          );

      expect(userProfileRepository.lastSavedUser, isNotNull);
      expect(userProfileRepository.lastSavedUser!.paceMinSecsPerKm, 305);
      expect(userProfileRepository.lastSavedUser!.paceMaxSecsPerKm, 355);
      expect(userProfileRepository.lastSavedUser!.preferredDistances, const [
        PreferredDistance.tenK,
      ]);
      expect(userProfileRepository.lastSavedUser!.runningReasons, const [
        RunReason.community,
        RunReason.social,
      ]);
      expect(userProfileRepository.lastSavedUser!.profileComplete, isTrue);
    });
  });
}
