import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/gender_interest_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/name_dob_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/otp_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/phone_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/photos_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/welcome_page.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../runs/runs_test_helpers.dart';
import 'onboarding_test_helpers.dart';

void main() {
  group('WelcomePage', () {
    testWidgets('Get started advances onboarding to the phone step', (
      tester,
    ) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const WelcomePage(),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Get started'));
      await tester.pumpAndSettle();

      expect(
        container.read(onboardingControllerProvider).step,
        OnboardingStep.phone,
      );
    });

    testWidgets('Sign in routes to the auth screen', (tester) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);
      final router = GoRouter(
        initialLocation: '/onboarding',
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (_, _) => const Scaffold(body: WelcomePage()),
          ),
          GoRoute(
            path: '/auth',
            builder: (_, _) => const Scaffold(body: Text('Auth screen')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Already have an account? Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Auth screen'), findsOneWidget);
    });

    testWidgets('Sign in preserves the pending destination', (tester) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);
      final router = GoRouter(
        initialLocation: '/onboarding?from=%2Fchats%2Fmatch-1',
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (_, _) => const Scaffold(body: WelcomePage()),
          ),
          GoRoute(
            path: '/auth',
            builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Already have an account? Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('/auth?from=%2Fchats%2Fmatch-1'), findsOneWidget);
    });
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
    testWidgets('manual phone entry requires 10 digits', (tester) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const NameDobPage(),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'First name'),
        'Asha',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Last name'),
        'Runner',
      );
      await tester.tap(find.widgetWithText(TextFormField, 'Date of birth'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mobile number'),
        '12345',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid 10-digit number'), findsOneWidget);
      expect(
        container.read(onboardingControllerProvider).step,
        OnboardingStep.welcome,
      );
    });

    testWidgets('valid manual phone entry advances to the next step', (
      tester,
    ) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const NameDobPage(),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'First name'),
        'Asha',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Last name'),
        'Runner',
      );
      await tester.tap(find.widgetWithText(TextFormField, 'Date of birth'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mobile number'),
        '9876543210',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
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

    testWidgets('restores saved values and keeps manual phone editable', (
      tester,
    ) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingControllerProvider.notifier);
      notifier.setNameDob(
        firstName: 'Asha',
        lastName: 'Runner',
        dateOfBirth: DateTime(1997, 4, 15),
        phoneNumber: '9876543210',
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

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mobile number'),
        '9123456780',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(
        container.read(onboardingControllerProvider).phoneNumber,
        '9123456780',
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

      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
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
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'Woman').first)
            .selected,
        isTrue,
      );
      expect(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'Straight'))
            .selected,
        isTrue,
      );
      expect(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'Man').last)
            .selected,
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
            appUserStreamProvider.overrideWith(
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
              .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Continue'),
              )
              .onPressed,
          isNull,
        );
      },
    );
  });
}
