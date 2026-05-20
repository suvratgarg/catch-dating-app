import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_form_keys.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_screen.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/gender_interest_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/name_dob_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/photos_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/profile_prompts_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/running_prefs_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/welcome_page.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';
import 'onboarding_test_helpers.dart';

void main() {
  group('WelcomePage', () {
    testWidgets('shows the branded welcome page with CTA', (tester) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const WelcomePage(),
      );

      expect(find.widgetWithText(CatchButton, 'Browse clubs'), findsOneWidget);
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
        await pumpOnboardingUi(tester);

        expect(find.text('Gender'), findsOneWidget);
        expect(find.text('2/2'), findsOneWidget);
        await tester.tap(find.byTooltip('Back'));
        await pumpOnboardingUi(tester);

        expect(
          container.read(onboardingControllerProvider).step,
          OnboardingStep.nameDob,
        );
        expect(find.text('Your name'), findsOneWidget);
        expect(find.text('1/2'), findsOneWidget);
      },
    );
  });

  group('NameDobPage', () {
    testWidgets('validates required fields before continuing', (tester) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const NameDobPage(),
      );

      await tester.tap(find.widgetWithText(CatchButton, 'Continue'));
      await pumpOnboardingUi(tester);

      expect(find.text('First name is required'), findsOneWidget);
      expect(find.text('Last name is required'), findsOneWidget);
      expect(find.text('Please select your date of birth'), findsOneWidget);
    });

    testWidgets('completed profile fields advance to the next step', (
      tester,
    ) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);
      container.read(onboardingControllerProvider.notifier)
        ..goToStep(OnboardingStep.nameDob)
        ..setNameDob(
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

      await tester.tap(find.widgetWithText(CatchButton, 'Continue'));
      await pumpOnboardingUi(tester);

      expect(
        container.read(onboardingControllerProvider).step,
        OnboardingStep.genderInterest,
      );
    });

    testWidgets('keeps phone field read-only', (tester) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);
      container.read(onboardingControllerProvider.notifier)
        ..goToStep(OnboardingStep.nameDob)
        ..setNameDob(
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
      await pumpOnboardingUi(tester);

      expect(find.text('Please select your gender'), findsOneWidget);
      expect(find.text('Please select who you want to see'), findsOneWidget);
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
            interestedInGenders: const [Gender.man],
          );

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const GenderInterestPage(),
      );

      expect(
        tester
            .widget<CatchChip>(
              find.byKey(OnboardingFormKeys.genderChip(Gender.woman)),
            )
            .active,
        isTrue,
      );
      expect(
        tester
            .widget<CatchChip>(
              find.byKey(OnboardingFormKeys.interestedInChip(Gender.man)),
            )
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
            watchUserProfileProvider.overrideWith(
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

    testWidgets('explains the swipe gate in profile-completion mode', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 2200);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = createOnboardingTestContainer(
        overrides: [
          watchUserProfileProvider.overrideWith(
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
        child: const PhotosPage(profileCompletionOnly: true),
      );

      expect(find.text('Complete your profile to swipe'), findsOneWidget);
      expect(
        find.text('This only gates swiping. Event booking stays available.'),
        findsOneWidget,
      );
    });
  });

  group('ProfilePromptsPage', () {
    testWidgets('explains prompts as part of swipe completion', (tester) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const ProfilePromptsPage(profileCompletionOnly: true),
      );

      expect(find.text('Add prompts to start swiping'), findsOneWidget);
      expect(
        find.text(
          'Prompts give people something real to respond to before you match.',
        ),
        findsOneWidget,
      );
    });
  });

  group('RunningPrefsPage', () {
    testWidgets('explains run preferences as event-specific booking data', (
      tester,
    ) async {
      final container = createOnboardingTestContainer(
        overrides: [
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.value(buildUser(uid: 'runner-1')),
          ),
        ],
      );
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const RunningPrefsPage(runPreferencesOnly: true),
      );

      expect(find.text('Set your run preferences'), findsOneWidget);
      expect(find.text('Why do you run?'), findsOneWidget);
      expect(find.text('Continue booking'), findsOneWidget);
    });

    testWidgets('shows favorite event-time preferences', (tester) async {
      final container = createOnboardingTestContainer(
        overrides: [
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.value(
              buildUser(
                uid: 'runner-1',
              ).copyWith(preferredRunTimes: const [PreferredRunTime.morning]),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const RunningPrefsPage(),
      );

      expect(find.text('Favorite event times'), findsOneWidget);
      expect(find.text('Morning'), findsOneWidget);
      expect(find.text('Evening'), findsOneWidget);
    });
  });
}
