import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_screen.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/gender_interest_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/name_dob_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/otp_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/phone_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/photos_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/welcome_page.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';
import 'onboarding_test_helpers.dart';

FakeAuthRepository _phoneAuthRepository() => FakeAuthRepository()
  ..onVerifyPhoneNumber =
      ({
        required verificationCompleted,
        required verificationFailed,
        required codeSent,
        required codeAutoRetrievalTimeout,
      }) {
        codeSent('verification-id', 11);
      };

void main() {
  group('WelcomePage', () {
    testWidgets('Continue with phone advances onboarding to the phone step', (
      tester,
    ) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const WelcomePage(),
      );

      await tester.tap(find.widgetWithText(CatchButton, 'Continue with phone'));
      await tester.pumpAndSettle();

      expect(
        container.read(onboardingControllerProvider).step,
        OnboardingStep.phone,
      );
    });

    testWidgets('does not offer a second auth CTA', (tester) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const WelcomePage(),
      );

      expect(
        find.widgetWithText(CatchButton, 'Continue with phone'),
        findsOneWidget,
      );
      expect(find.byType(TextButton), findsNothing);
      expect(find.text('Already a runner? Sign in'), findsNothing);
    });
  });

  group('OnboardingScreen', () {
    testWidgets(
      'back button returns editable onboarding steps to previous step',
      (tester) async {
        final container = createOnboardingTestContainer();
        addTearDown(container.dispose);

        await pumpOnboardingScreen(
          tester,
          container: container,
          child: const OnboardingScreen(),
        );

        container
            .read(onboardingControllerProvider.notifier)
            .goToStep(OnboardingStep.genderInterest);
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();

        expect(
          container.read(onboardingControllerProvider).step,
          OnboardingStep.nameDob,
        );
      },
    );
  });

  group('PhonePage', () {
    testWidgets('shows a friendly auth error message', (tester) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);

      await expectLater(
        OnboardingController.sendOtpMutation.run(container, (
          transaction,
        ) async {
          throw FirebaseAuthException(code: 'invalid-phone-number');
        }),
        throwsA(isA<FirebaseAuthException>()),
      );

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const PhonePage(),
      );

      expect(find.text('Please enter a valid phone number.'), findsOneWidget);
    });

    testWidgets('restores the previously entered phone number', (tester) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);
      container
          .read(onboardingControllerProvider.notifier)
          .setNameDob(
            firstName: 'Asha',
            lastName: 'Runner',
            dateOfBirth: DateTime(1997, 4, 15),
            phoneNumber: '9876543210',
            countryCode: '+91',
          );

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const PhonePage(),
      );

      expect(find.text('9876543210'), findsOneWidget);
    });
  });

  group('OtpPage', () {
    testWidgets('renders six digit boxes and submits completed code', (
      tester,
    ) async {
      final repository = _phoneAuthRepository();
      final container = createOnboardingTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);

      await container
          .read(onboardingControllerProvider.notifier)
          .sendOtp('9876543210', '+91');

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const OtpPage(),
      );

      for (var i = 0; i < 6; i++) {
        expect(find.byKey(ValueKey('otp_digit_$i')), findsOneWidget);
      }

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pumpAndSettle();

      expect(repository.otpVerificationId, 'verification-id');
      expect(repository.otpSmsCode, '123456');
    });

    testWidgets('shows resend countdown before allowing another OTP', (
      tester,
    ) async {
      final repository = _phoneAuthRepository();
      final container = createOnboardingTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      });

      await container
          .read(onboardingControllerProvider.notifier)
          .sendOtp('9876543210', '+91');

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const OtpPage(),
      );

      expect(repository.verifyPhoneNumberCallCount, 1);
      expect(find.text('Resend OTP in 60s'), findsOneWidget);
      expect(
        tester
            .widget<CatchButton>(
              find.widgetWithText(CatchButton, 'Resend OTP in 60s'),
            )
            .onPressed,
        isNull,
      );

      await tester.pump(const Duration(seconds: 30));
      expect(find.text('Resend OTP in 30s'), findsOneWidget);

      await tester.pump(const Duration(seconds: 30));
      expect(find.text('Resend OTP'), findsOneWidget);

      await tester.tap(find.widgetWithText(CatchButton, 'Resend OTP'));
      await tester.pump();

      expect(repository.verifyPhoneNumberCallCount, 2);
      expect(find.text('Resend OTP in 60s'), findsOneWidget);
    });

    testWidgets('Change number returns to the phone step', (tester) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const OtpPage(),
      );

      await tester.tap(find.text('Change number'));
      await tester.pumpAndSettle();

      expect(
        container.read(onboardingControllerProvider).step,
        OnboardingStep.phone,
      );
    });
  });

  group('NameDobPage', () {
    testWidgets('requires a verified phone before continuing', (tester) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const NameDobPage(),
      );

      await tester.enterText(
        find.widgetWithText(CatchTextField, 'First name'),
        'Asha',
      );
      await tester.enterText(
        find.widgetWithText(CatchTextField, 'Last name'),
        'Runner',
      );
      await tester.tap(find.widgetWithText(CatchTextField, 'Date of birth'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(CatchButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please verify your phone number before continuing.'),
        findsOneWidget,
      );
      expect(
        container.read(onboardingControllerProvider).step,
        OnboardingStep.welcome,
      );
    });

    testWidgets('verified phone advances to the next step', (tester) async {
      final repository = _phoneAuthRepository();
      final container = createOnboardingTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);
      final notifier = container.read(onboardingControllerProvider.notifier);
      await notifier.sendOtp('9876543210', '+91');
      await notifier.verifyOtp('123456');

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const NameDobPage(),
      );

      await tester.enterText(
        find.widgetWithText(CatchTextField, 'First name'),
        'Asha',
      );
      await tester.enterText(
        find.widgetWithText(CatchTextField, 'Last name'),
        'Runner',
      );
      await tester.tap(find.widgetWithText(CatchTextField, 'Date of birth'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(CatchButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(
        container.read(onboardingControllerProvider).step,
        OnboardingStep.genderInterest,
      );
      expect(
        container.read(onboardingControllerProvider).phoneNumber,
        '9876543210',
      );
    });

    testWidgets('restores saved values and keeps verified phone read-only', (
      tester,
    ) async {
      final repository = _phoneAuthRepository();
      final container = createOnboardingTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);
      final notifier = container.read(onboardingControllerProvider.notifier);
      await notifier.sendOtp('9876543210', '+91');
      await notifier.verifyOtp('123456');
      notifier.setNameDob(
        firstName: 'Asha',
        lastName: 'Runner',
        dateOfBirth: DateTime(1997, 4, 15),
        phoneNumber: '9876543210',
        countryCode: '+91',
      );

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const NameDobPage(),
      );

      expect(find.text('Asha'), findsOneWidget);
      expect(find.text('Runner'), findsOneWidget);
      expect(find.text('15/04/1997'), findsOneWidget);
      expect(find.text('9876543210'), findsOneWidget);

      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: find.widgetWithText(CatchTextField, 'Mobile number'),
                matching: find.byType(EditableText),
              ),
            )
            .readOnly,
        isTrue,
      );
    });
  });

  group('GenderInterestPage', () {
    testWidgets('validates required selections before continuing', (
      tester,
    ) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const GenderInterestPage(),
      );

      await tester.tap(find.widgetWithText(CatchButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Please select your gender'), findsOneWidget);
      expect(find.text('Please select your orientation'), findsOneWidget);
    });

    testWidgets('restores saved selections from the onboarding draft', (
      tester,
    ) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);
      container
          .read(onboardingControllerProvider.notifier)
          .setGenderInterest(
            gender: Gender.woman,
            sexualOrientation: SexualOrientation.straight,
            interestedInGenders: const [Gender.man],
          );

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const GenderInterestPage(),
      );

      expect(
        tester
            .widget<CatchChip>(find.widgetWithText(CatchChip, 'Woman').first)
            .active,
        isTrue,
      );
      expect(
        tester
            .widget<CatchChip>(find.widgetWithText(CatchChip, 'Straight'))
            .active,
        isTrue,
      );
      expect(
        tester
            .widget<CatchChip>(find.widgetWithText(CatchChip, 'Man').last)
            .active,
        isTrue,
      );
    });
  });

  group('PhotosPage', () {
    testWidgets(
      'explains why continue is disabled until enough photos are added',
      (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(1080, 2200);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final container = createOnboardingTestContainer(
          overrides: [
            userProfileStreamProvider.overrideWith(
              (ref) => Stream.value(
                buildUser(uid: 'runner-1').copyWith(photoUrls: const []),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        await pumpOnboardingPage(
          tester,
          container: container,
          child: const PhotosPage(),
        );

        expect(find.text('Add 2 more photos to continue.'), findsOneWidget);
        expect(
          tester
              .widget<CatchButton>(find.widgetWithText(CatchButton, 'Continue'))
              .onPressed,
          isNull,
        );
      },
    );
  });
}
