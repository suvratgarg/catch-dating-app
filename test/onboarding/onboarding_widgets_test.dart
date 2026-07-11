import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/image_uploads/shared/photo_grid_keys.dart';
import 'package:catch_dating_app/image_uploads/shared/photo_upload_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_form_keys.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_screen.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/gender_interest_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/gender_interest_page_state.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/instagram_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/instagram_page_state.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/name_dob_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/name_dob_page_state.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/photos_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/photos_page_state.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/profile_prompts_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/profile_prompts_page_state.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/running_prefs_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/running_prefs_page_state.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/welcome_page.dart';
import 'package:catch_dating_app/routing/go_router.dart' as app_router;
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../events/events_test_helpers.dart';
import 'onboarding_test_helpers.dart';

void main() {
  group('WelcomePage', () {
    testWidgets('reel phrase bank matches strings.json', (tester) async {
      final strings =
          jsonDecode(_welcomeStringsSource().readAsStringSync())
              as Map<String, dynamic>;
      final phrases = (strings['phrases'] as List<Object?>)
          .cast<Map<String, dynamic>>();
      final objects = [
        for (final phrase in phrases) '${phrase['object'] as String}.',
      ];
      final runtimePhrases = welcomePhraseBank;

      expect(strings['landingIndex'], welcomeLandingIndex);
      expect(runtimePhrases, hasLength(phrases.length));
      for (final entry in phrases.indexed) {
        final source = entry.$2;
        final runtime = runtimePhrases[entry.$1];
        final sourceActivity = _welcomeActivityKind(
          source['activity'] as String,
        );
        final sourcePigment = _colorFromHex(source['pigment'] as String);

        expect(runtime.object, source['object']);
        expect(runtime.activityKind, sourceActivity);
        expect(ActivityPalette.pigments[runtime.activityKind], sourcePigment);
      }

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 320,
            height: 540,
            child: ReelBand(spinValue: 0, landingValue: 0, landed: false),
          ),
        ),
      );

      final rendered = tester
          .widgetList<RichText>(find.byType(RichText))
          .map((widget) => widget.text.toPlainText())
          .toList();

      expect(objects.last, 'someone real.');
      expect(rendered, [...objects, ...objects]);
    });

    testWidgets('shows the landed welcome page with CTA', (tester) async {
      final reporter = _FakeAnalyticsReporter();
      final container = createOnboardingTestContainer(
        appAnalytics: AppAnalytics(reporter: reporter, shouldCollect: true),
      );
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const WelcomePage(playIntro: false),
      );

      expect(
        find.widgetWithText(CatchButton, 'See what\'s on'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(CatchButton, 'Continue with phone'),
        findsOneWidget,
      );
      expect(find.text('Catch'), findsOneWidget);
      expect(find.textContaining('someone real'), findsWidgets);
      expect(find.text('RUN CLUB DATING'), findsNothing);
      expect(find.text('Love arrives\nat mile\nthree.'), findsNothing);
      expect(find.byType(TextButton), findsNothing);
      expect(find.text('Already a runner? Sign in'), findsNothing);
      expect(reporter.events, hasLength(1));
      expect(reporter.events.single.name, AnalyticsEvents.welcomeSplashShown);
      expect(
        reporter.events.single.parameters,
        containsPair(AnalyticsParameters.splashMotion, 'direct'),
      );
    });

    testWidgets('reduced motion renders landed state immediately', (
      tester,
    ) async {
      final reporter = _FakeAnalyticsReporter();
      final container = createOnboardingTestContainer(
        appAnalytics: AppAnalytics(reporter: reporter, shouldCollect: true),
      );
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: WelcomePage(),
        ),
      );

      expect(
        find.widgetWithText(CatchButton, 'Continue with phone'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(CatchButton, 'See what\'s on'),
        findsOneWidget,
      );
      expect(
        reporter.events.single.parameters,
        containsPair(AnalyticsParameters.splashMotion, 'reduced_motion'),
      );
    });

    testWidgets('landed scene pins reel and CTA anchors', (tester) async {
      tester.view.physicalSize = const Size(320, 630);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: WelcomeScene(
            viewportHeight: 630,
            mediaPadding: EdgeInsets.zero,
            spinValue: 1,
            landingValue: 1,
            landed: true,
            onContinue: () {},
            onExplore: () {},
          ),
        ),
      );

      final catchTopLeft = tester.getTopLeft(find.text('Catch'));
      expect(catchTopLeft.dx, closeTo(CatchLayout.welcomeReelCatchLeft, 0.1));
      expect(
        catchTopLeft.dy,
        closeTo(
          CatchLayout.welcomeReelTop + CatchLayout.welcomeReelCatchFocusTop,
          0.1,
        ),
      );

      final phraseFinder = find.text('someone real.').first;
      final phraseTopLeft = tester.getTopLeft(phraseFinder);
      expect(phraseTopLeft.dx, closeTo(CatchLayout.welcomeReelObjectLeft, 0.1));
      expect(
        phraseTopLeft.dy,
        closeTo(
          CatchLayout.welcomeReelTop + CatchLayout.welcomeReelCatchFocusTop,
          0.1,
        ),
      );
      final phraseText = tester.widget<Text>(phraseFinder);
      final rootSpan = phraseText.textSpan! as TextSpan;
      final periodSpan = rootSpan.children!.last as TextSpan;
      expect(periodSpan.text, '.');
      expect(periodSpan.style!.color!.a, closeTo(1, 0.001));

      expect(
        tester
            .getBottomLeft(find.widgetWithText(CatchButton, 'See what\'s on'))
            .dy,
        closeTo(630 - CatchLayout.welcomeButtonsBottom, 0.1),
      );
    });

    testWidgets('tap skips the reel into the welcome CTAs', (tester) async {
      final reporter = _FakeAnalyticsReporter();
      final container = createOnboardingTestContainer(
        appAnalytics: AppAnalytics(reporter: reporter, shouldCollect: true),
      );
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const WelcomePage(),
      );

      expect(
        find.widgetWithText(CatchButton, 'Continue with phone'),
        findsNothing,
      );

      await tester.tap(find.byKey(WelcomePage.splashTapTargetKey));
      await tester.pump(CatchMotion.welcomeLandingReveal);
      await tester.pump();

      expect(
        find.widgetWithText(CatchButton, 'Continue with phone'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(CatchButton, 'See what\'s on'),
        findsOneWidget,
      );
      expect(
        reporter.events.map((event) => event.name),
        containsAllInOrder([
          AnalyticsEvents.welcomeSplashShown,
          AnalyticsEvents.welcomeSplashSkipped,
        ]),
      );
    });

    testWidgets('see whats on routes through the named Explore route', (
      tester,
    ) async {
      final reporter = _FakeAnalyticsReporter();
      final container = createOnboardingTestContainer(
        appAnalytics: AppAnalytics(reporter: reporter, shouldCollect: true),
      );
      addTearDown(container.dispose);
      final router = GoRouter(
        initialLocation: app_router.Routes.startScreen.path,
        routes: [
          GoRoute(
            path: app_router.Routes.startScreen.path,
            builder: (_, _) => const WelcomePage(playIntro: false),
          ),
          GoRoute(
            path: app_router.Routes.exploreScreen.path,
            name: app_router.Routes.exploreScreen.name,
            builder: (_, _) => const Scaffold(body: Text('Explore route')),
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
      await pumpOnboardingUi(tester);

      await tester.tap(find.widgetWithText(CatchButton, 'See what\'s on'));
      await tester.pump();
      await tester.pump();

      expect(router.routeInformationProvider.value.uri.path, '/clubs');
      expect(find.text('Explore route'), findsOneWidget);
      expect(
        reporter.events.map((event) => event.name),
        contains(AnalyticsEvents.welcomeCtaTapped),
      );
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

        expect(find.text('How do you identify?'), findsOneWidget);
        expect(find.text('STEP 2 OF 2'), findsOneWidget);
        await tester.tap(find.byTooltip('Back'));
        await pumpOnboardingUi(tester);

        expect(
          container.read(onboardingControllerProvider).step,
          OnboardingStep.nameDob,
        );
        expect(find.text("What's your name?"), findsOneWidget);
        expect(find.text('STEP 1 OF 2'), findsOneWidget);
      },
    );
  });

  group('NameDobPage', () {
    test('state derives draft display, date policy, and submit intent', () {
      final state = OnboardingNameDobState.fromDraft(
        firstName: ' Asha ',
        lastName: ' Runner ',
        phoneNumber: ' 9876543210 ',
        countryCode: '+91',
        dateOfBirth: DateTime(1997, 4, 15),
        step: OnboardingStep.nameDob,
        today: DateTime(2026, 7, 3),
      );

      expect(state.shouldAutofocus, isTrue);
      expect(state.dateText, '15 Apr 1997');
      expect(state.ageSuffix, 'AGE 29');
      expect(state.phonePrefix, '+91 ');
      expect(state.datePickerRequest.initialDate, DateTime(1997, 4, 15));
      expect(state.datePickerRequest.firstDate, DateTime(1920));
      expect(state.datePickerRequest.title, 'Date of birth');

      final intent = state.submitIntent(
        firstName: state.firstName,
        lastName: state.lastName,
        phoneNumber: state.phoneNumber,
      );
      expect(intent?.firstName, 'Asha');
      expect(intent?.lastName, 'Runner');
      expect(intent?.phoneNumber, '9876543210');
      expect(intent?.countryCode, '+91');
      expect(intent?.dateOfBirth, DateTime(1997, 4, 15));

      final missingDate = OnboardingNameDobState.fromDraft(
        firstName: 'Asha',
        lastName: 'Runner',
        phoneNumber: '9876543210',
        countryCode: '+91',
        dateOfBirth: null,
        step: OnboardingStep.genderInterest,
        today: DateTime(2026, 7, 3),
      );
      expect(missingDate.shouldAutofocus, isFalse);
      expect(missingDate.dateText, isEmpty);
      expect(missingDate.ageSuffix, isNull);
      expect(
        missingDate.validateDateOfBirth(),
        'Please select your date of birth',
      );
      expect(
        missingDate.submitIntent(
          firstName: 'Asha',
          lastName: 'Runner',
          phoneNumber: '9876543210',
        ),
        isNull,
      );
    });

    testWidgets('provider-free step forwards date and continue actions', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();
      final controllers = OnboardingNameDobTextControllers(
        firstName: TextEditingController(text: 'Asha'),
        lastName: TextEditingController(text: 'Runner'),
        phone: TextEditingController(text: '9876543210'),
        date: TextEditingController(text: '15 Apr 1997'),
      );
      addTearDown(controllers.firstName.dispose);
      addTearDown(controllers.lastName.dispose);
      addTearDown(controllers.phone.dispose);
      addTearDown(controllers.date.dispose);
      final state = OnboardingNameDobState.fromDraft(
        firstName: controllers.firstName.text,
        lastName: controllers.lastName.text,
        phoneNumber: controllers.phone.text,
        countryCode: '+91',
        dateOfBirth: DateTime(1997, 4, 15),
        step: OnboardingStep.nameDob,
        today: DateTime(2026, 7, 3),
      );
      OnboardingNameDobDatePickerRequest? dateRequest;
      var continueCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: OnboardingNameDobStep(
              formKey: formKey,
              state: state,
              controllers: controllers,
              callbacks: OnboardingNameDobCallbacks(
                onPickDate: (request) => dateRequest = request,
                onContinue: () => continueCount += 1,
              ),
            ),
          ),
        ),
      );
      await pumpOnboardingUi(tester);

      await tester.tap(
        find.descendant(
          of: find.widgetWithText(CatchField, 'DATE OF BIRTH'),
          matching: find.byType(EditableText),
        ),
      );
      await tester.tap(find.widgetWithText(CatchButton, 'Continue'));
      await pumpOnboardingUi(tester);

      expect(dateRequest?.title, 'Date of birth');
      expect(dateRequest?.initialDate, DateTime(1997, 4, 15));
      expect(continueCount, 1);
      expect(find.text('AGE 29'), findsOneWidget);
    });

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
      expect(find.text('15 Apr 1997'), findsOneWidget);
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
                of: find.widgetWithText(CatchField, 'PHONE'),
                matching: find.byType(EditableText),
              ),
            )
            .readOnly,
        isTrue,
      );
    });
  });

  group('GenderInterestPage', () {
    test('state validates selections and creates submit intent', () {
      final empty = OnboardingGenderInterestState.fromDraft(
        gender: null,
        interestedIn: const [],
      );

      expect(empty.selectedGender, isEmpty);
      expect(empty.validateGender(null), 'Please select your gender');
      expect(
        empty.validateInterestedIn(null),
        'Please select who you want to see',
      );
      expect(empty.submitIntent(), isNull);

      final ready = OnboardingGenderInterestState.fromDraft(
        gender: Gender.woman,
        interestedIn: const [Gender.man],
        isSaving: true,
        saveErrorMessage: 'Could not save profile.',
      );
      expect(ready.selectedGender, {Gender.woman});
      expect(ready.interestedIn, {Gender.man});
      expect(ready.isSaving, isTrue);
      expect(ready.hasSaveError, isTrue);
      expect(ready.validateGender(null), isNull);
      expect(ready.validateInterestedIn(null), isNull);
      expect(ready.submitIntent()?.gender, Gender.woman);
      expect(ready.submitIntent()?.interestedInGenders, [Gender.man]);
    });

    testWidgets('provider-free step forwards typed chip actions', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();
      final state = OnboardingGenderInterestState.fromDraft(
        gender: Gender.woman,
        interestedIn: const [Gender.man],
        saveErrorMessage: 'Could not save profile.',
      );
      Set<Gender>? nextGender;
      Set<Gender>? nextInterestedIn;
      var continueCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: OnboardingGenderInterestStep(
              formKey: formKey,
              state: state,
              callbacks: OnboardingGenderInterestCallbacks(
                onGenderChanged: (next) => nextGender = next,
                onInterestedInChanged: (next) => nextInterestedIn = next,
                onContinue: () => continueCount += 1,
              ),
            ),
          ),
        ),
      );
      await pumpOnboardingUi(tester);

      expect(find.text('Could not save profile.'), findsOneWidget);

      await tester.tap(find.byKey(OnboardingFormKeys.genderChip(Gender.man)));
      await tester.tap(
        find.byKey(OnboardingFormKeys.interestedInChip(Gender.woman)),
      );
      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is CatchButton && widget.label == 'Continue',
        ),
      );
      await pumpOnboardingUi(tester);

      expect(nextGender, {Gender.man});
      expect(nextInterestedIn, {Gender.man, Gender.woman});
      expect(continueCount, 1);
    });

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

  group('InstagramPage', () {
    test('state trims continue handles and clears skipped handles', () {
      final state = OnboardingInstagramState.fromDraft(
        handle: ' sundayseaface ',
      );

      expect(state.handleText, ' sundayseaface ');
      expect(
        state.continueIntent(handle: state.handleText).instagramHandle,
        'sundayseaface',
      );
      expect(state.continueIntent(handle: '   ').instagramHandle, isNull);
      expect(state.skipIntent.instagramHandle, isNull);
    });

    testWidgets('provider-free step forwards continue and skip actions', (
      tester,
    ) async {
      final controllers = OnboardingInstagramTextControllers(
        handle: TextEditingController(text: 'sundayseaface'),
      );
      addTearDown(controllers.handle.dispose);
      var continueCount = 0;
      var skipCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: OnboardingInstagramStep(
              controllers: controllers,
              callbacks: OnboardingInstagramCallbacks(
                onContinue: () => continueCount += 1,
                onSkip: () => skipCount += 1,
              ),
            ),
          ),
        ),
      );
      await pumpOnboardingUi(tester);

      await tester.tap(find.widgetWithText(CatchButton, 'Continue'));
      await tester.tap(find.widgetWithText(CatchButton, 'Skip for now'));
      await pumpOnboardingUi(tester);

      expect(continueCount, 1);
      expect(skipCount, 1);
    });

    testWidgets('continues with a trimmed handle and advances to photos', (
      tester,
    ) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);
      container
          .read(onboardingControllerProvider.notifier)
          .goToStep(OnboardingStep.instagram);
      container
          .read(onboardingControllerProvider.notifier)
          .setInstagramHandle(' sundayseaface ');

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const InstagramPage(),
      );

      await tester.tap(find.widgetWithText(CatchButton, 'Continue'));
      await pumpOnboardingUi(tester);

      final data = container.read(onboardingControllerProvider);
      expect(data.step, OnboardingStep.photos);
      expect(data.instagramHandle, 'sundayseaface');
    });

    testWidgets('skip clears the handle and advances to photos', (
      tester,
    ) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);
      container
          .read(onboardingControllerProvider.notifier)
          .goToStep(OnboardingStep.instagram);
      container
          .read(onboardingControllerProvider.notifier)
          .setInstagramHandle('sundayseaface');

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const InstagramPage(),
      );

      await tester.tap(find.widgetWithText(CatchButton, 'Skip for now'));
      await pumpOnboardingUi(tester);

      final data = container.read(onboardingControllerProvider);
      expect(data.step, OnboardingStep.photos);
      expect(data.instagramHandle, isNull);
    });
  });

  group('PhotosPage', () {
    test('state derives continue gating and photo slot intents', () {
      final onePhoto = buildUser(
        photoUrls: const ['assets/test/onboarding-photo-1.jpg'],
      ).effectiveProfilePhotos;
      final readyPhotos = buildUser(
        photoUrls: const [
          'assets/test/onboarding-photo-1.jpg',
          'assets/test/onboarding-photo-2.jpg',
        ],
      ).effectiveProfilePhotos;
      final editablePhotos = buildUser(
        photoUrls: const [
          'assets/test/onboarding-photo-1.jpg',
          'assets/test/onboarding-photo-2.jpg',
          'assets/test/onboarding-photo-3.jpg',
        ],
      ).effectiveProfilePhotos;

      final empty = OnboardingPhotosState.from(
        profilePhotos: const [],
        loadingIndices: const {},
        profileCompletionOnly: false,
      );
      expect(empty.canContinue, isFalse);
      expect(empty.continueHint, 'Add 2 more photos to continue.');
      expect(empty.supportingCopy, 'Running photos boost catches by 2.3x.');

      final pending = OnboardingPhotosState.from(
        profilePhotos: onePhoto,
        loadingIndices: const {1},
        profileCompletionOnly: true,
      );
      expect(pending.canContinue, isFalse);
      expect(pending.continueHint, 'Finish uploading your photos to continue.');
      expect(
        pending.supportingCopy,
        'This only gates Catches. Event booking stays available.',
      );

      final ready = OnboardingPhotosState.from(
        profilePhotos: readyPhotos,
        loadingIndices: const {},
        profileCompletionOnly: false,
      );
      expect(ready.canContinue, isTrue);
      expect(ready.continueHint, isNull);
      expect(ready.slotIntent(0).photo, readyPhotos.first);
      expect(ready.slotIntent(0).canDelete, isFalse);

      final editable = OnboardingPhotosState.from(
        profilePhotos: editablePhotos,
        loadingIndices: const {},
        profileCompletionOnly: false,
      );
      expect(editable.slotIntent(0).canDelete, isTrue);
      expect(editable.slotIntent(3).photo, isNull);
    });

    testWidgets('provider-free step forwards typed photo actions', (
      tester,
    ) async {
      final state = OnboardingPhotosState.from(
        profilePhotos: const [],
        loadingIndices: const {},
        profileCompletionOnly: false,
      );
      var continueCount = 0;
      OnboardingPhotoSlotIntent? slotIntent;
      int? deletedIndex;
      (int, int)? reorderIntent;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: OnboardingPhotosStep(
              state: state,
              callbacks: OnboardingPhotosCallbacks(
                onContinue: () => continueCount += 1,
                onSlotTapped: (intent) => slotIntent = intent,
                onDeletePhoto: (index) => deletedIndex = index,
                onReorderPhoto: (fromIndex, toIndex) {
                  reorderIntent = (fromIndex, toIndex);
                },
              ),
            ),
          ),
        ),
      );
      await pumpOnboardingUi(tester);

      await tester.tap(find.widgetWithText(CatchButton, 'Continue'));
      await tester.tap(find.byKey(PhotoGridKeys.slot(0)));
      await pumpOnboardingUi(tester);

      expect(continueCount, 1);
      expect(slotIntent?.index, 0);
      expect(slotIntent?.photo, isNull);
      expect(slotIntent?.canDelete, isFalse);
      expect(deletedIndex, isNull);
      expect(reorderIntent, isNull);
    });

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
              (ref) =>
                  Stream.value(buildUser().copyWith(profilePhotos: const [])),
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

    testWidgets('explains the catches gate in profile-completion mode', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 2200);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = createOnboardingTestContainer(
        overrides: [
          watchUserProfileProvider.overrideWith(
            (ref) =>
                Stream.value(buildUser().copyWith(profilePhotos: const [])),
          ),
        ],
      );
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const PhotosPage(profileCompletionOnly: true),
      );

      expect(
        find.text('This only gates Catches. Event booking stays available.'),
        findsOneWidget,
      );
    });

    testWidgets('surfaces upload failures from the photo upload controller', (
      tester,
    ) async {
      final user = buildUser().copyWith(profilePhotos: const []);
      final container = createOnboardingTestContainer(
        overrides: [
          uidProvider.overrideWithValue(AsyncData<String?>(user.uid)),
          watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
          userProfileRepositoryProvider.overrideWithValue(
            FakeOnboardingUserProfileRepository(currentUser: user),
          ),
          imageUploadRepositoryProvider.overrideWithValue(
            _FailingOnboardingImageUploadRepository(),
          ),
          errorLoggerProvider.overrideWithValue(_SilentOnboardingErrorLogger()),
        ],
      );
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const _OnboardingUploadFailureSeeder(),
      );
      await pumpOnboardingUi(tester);
      await pumpOnboardingUi(tester);

      expect(find.text('Upload failed. Please try again.'), findsOneWidget);
      expect(
        container
            .read(photoUploadControllerProvider)
            .loadingIndices
            .contains(0),
        isFalse,
      );
    });
  });

  group('ProfilePromptsPage', () {
    test(
      'state derives prompt progress, available prompts, and submit intent',
      () {
        final answers = List<String>.generate(
          maxProfilePromptAnswers,
          (index) => 'Answer ${index + 1}',
        );
        final complete = OnboardingProfilePromptsState.fromSelections(
          selectedPromptIds: defaultProfilePromptIds,
          answerTexts: answers,
          isCompleting: true,
          completeErrorMessage: 'Could not save prompts.',
        );

        expect(complete.answeredCount, maxProfilePromptAnswers);
        expect(complete.canContinue, isTrue);
        expect(complete.canSubmit, isFalse);
        expect(
          complete.progressLabel,
          '$maxProfilePromptAnswers / $maxProfilePromptAnswers prompts answered',
        );
        expect(complete.hasCompleteError, isTrue);
        expect(
          complete.availablePromptIds(1),
          isNot(contains(complete.selectedPromptIdForSlot(0))),
        );
        expect(
          complete.availablePromptIds(1),
          contains(complete.selectedPromptIdForSlot(1)),
        );
        expect(
          complete.submitIntent()?.prompts.map((prompt) => prompt.answer),
          answers,
        );

        final partial = OnboardingProfilePromptsState.fromSelections(
          selectedPromptIds: defaultProfilePromptIds,
          answerTexts: const ['Only one answer'],
        );
        expect(partial.canContinue, isFalse);
        expect(partial.submitIntent(), isNull);

        final deduped = OnboardingProfilePromptsState.fromSelections(
          selectedPromptIds: List<String>.filled(
            maxProfilePromptAnswers,
            defaultProfilePromptIds.first,
          ),
          answerTexts: const [],
        );
        expect(
          deduped.selectedPromptIds.toSet(),
          hasLength(maxProfilePromptAnswers),
        );
      },
    );

    testWidgets('provider-free step shows progress and forwards continue', (
      tester,
    ) async {
      final controllers = OnboardingProfilePromptsTextControllers(
        answers: [
          for (var index = 0; index < maxProfilePromptAnswers; index += 1)
            TextEditingController(text: 'Answer ${index + 1}'),
        ],
      );
      for (final controller in controllers.answers) {
        addTearDown(controller.dispose);
      }
      final state = OnboardingProfilePromptsState.fromSelections(
        selectedPromptIds: defaultProfilePromptIds,
        answerTexts: [
          for (var index = 0; index < maxProfilePromptAnswers; index += 1)
            'Answer ${index + 1}',
        ],
        completeErrorMessage: 'Could not save prompts.',
      );
      var continueCount = 0;
      (int, String)? promptChange;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: OnboardingProfilePromptsStep(
              state: state,
              controllers: controllers,
              callbacks: OnboardingProfilePromptsCallbacks(
                onPromptChanged: (index, promptId) {
                  promptChange = (index, promptId);
                },
                onContinue: () => continueCount += 1,
              ),
            ),
          ),
        ),
      );
      await pumpOnboardingUi(tester);

      expect(
        find.text(
          '$maxProfilePromptAnswers / $maxProfilePromptAnswers prompts answered',
        ),
        findsOneWidget,
      );
      expect(find.text('Could not save prompts.'), findsOneWidget);

      await tester.tap(find.widgetWithText(CatchButton, 'Continue'));
      await pumpOnboardingUi(tester);

      expect(continueCount, 1);
      expect(promptChange, isNull);
    });

    testWidgets('explains prompts as part of catches completion', (
      tester,
    ) async {
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const ProfilePromptsPage(profileCompletionOnly: true),
      );

      // The mode-specific copy now lives in the flow header (see
      // onboarding_step_test `headerCopy`); the page renders its prompt
      // selectors and Continue affordance in completion mode.
      expect(find.byType(MenuAnchor), findsNWidgets(maxProfilePromptAnswers));
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('prompt pickers hide prompts selected in other slots', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 2200);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = createOnboardingTestContainer();
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const ProfilePromptsPage(),
      );

      final menus = find.byType(MenuAnchor);
      expect(menus, findsNWidgets(maxProfilePromptAnswers));

      await tester.tap(menus.at(1));
      await pumpOnboardingUi(tester);

      final menuPanel = find.byWidgetPredicate((widget) => widget is CatchMenu);
      expect(
        find.descendant(
          of: menuPanel,
          matching: find.text(
            profilePromptDefinition(profilePromptPerfectEventId).title,
          ),
        ),
        findsNothing,
      );
      final unusedPrompt = profilePromptCatalog.firstWhere(
        (definition) => !defaultProfilePromptIds.contains(definition.id),
      );
      await tester.tap(
        find.descendant(of: menuPanel, matching: find.text(unusedPrompt.title)),
      );
      await pumpOnboardingUi(tester);

      await tester.tap(menus.at(2));
      await pumpOnboardingUi(tester);

      expect(
        find.descendant(of: menuPanel, matching: find.text(unusedPrompt.title)),
        findsNothing,
      );
    });
  });

  group('RunningPrefsPage', () {
    test('state derives labels and submit payload', () {
      final state = OnboardingRunningPrefsState.fromDraft(
        paceRange: const RangeValues(300, 420),
        distances: const [PreferredDistance.fiveK],
        reasons: const [RunReason.community],
        runTimes: const [PreferredRunTime.morning],
        runPreferencesOnly: true,
        isCompleting: true,
        completeErrorMessage: 'Could not save run preferences.',
      );

      expect(state.footerLabel, 'Continue booking');
      expect(state.reasonLabel, 'Why do you run?');
      expect(state.runTimesLabel, 'FAVOURITE RUN TIMES');
      expect(state.minPaceLabel, '5:00/km');
      expect(state.maxPaceLabel, '7:00/km');
      expect(state.canSubmit, isFalse);
      expect(state.hasCompleteError, isTrue);

      final intent = state.submitIntent();
      expect(intent.paceMinSecsPerKm, 300);
      expect(intent.paceMaxSecsPerKm, 420);
      expect(intent.preferredDistances, [PreferredDistance.fiveK]);
      expect(intent.runningReasons, [RunReason.community]);
      expect(intent.preferredRunTimes, [PreferredRunTime.morning]);
    });

    testWidgets('provider-free step shows state and forwards continue', (
      tester,
    ) async {
      final state = OnboardingRunningPrefsState.fromDraft(
        paceRange: const RangeValues(300, 420),
        distances: const [PreferredDistance.fiveK],
        reasons: const [RunReason.community],
        runTimes: const [PreferredRunTime.morning],
        completeErrorMessage: 'Could not save run preferences.',
      );
      var continueCount = 0;
      RangeValues? nextPace;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: OnboardingRunningPrefsStep(
              state: state,
              callbacks: OnboardingRunningPrefsCallbacks(
                onPaceChanged: (next) => nextPace = next,
                onDistancesChanged: (_) {},
                onReasonsChanged: (_) {},
                onRunTimesChanged: (_) {},
                onContinue: () => continueCount += 1,
              ),
            ),
          ),
        ),
      );
      await pumpOnboardingUi(tester);

      expect(find.text('Save run preferences'), findsOneWidget);
      expect(find.text('5:00/km'), findsOneWidget);
      expect(find.text('7:00/km'), findsOneWidget);
      expect(find.text('Could not save run preferences.'), findsOneWidget);

      await tester.tap(
        find.widgetWithText(CatchButton, 'Save run preferences'),
      );
      await pumpOnboardingUi(tester);

      expect(continueCount, 1);
      expect(nextPace, isNull);
    });

    testWidgets('explains run preferences as event-specific booking data', (
      tester,
    ) async {
      final container = createOnboardingTestContainer(
        overrides: [
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.value(buildUser()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await pumpOnboardingPage(
        tester,
        container: container,
        child: const RunningPrefsPage(runPreferencesOnly: true),
      );

      expect(find.text('Why do you run?'), findsOneWidget);
      expect(find.text('Continue booking'), findsOneWidget);
    });

    testWidgets('shows favorite event-time preferences', (tester) async {
      final container = createOnboardingTestContainer(
        overrides: [
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.value(
              buildUser().copyWith(
                activityPreferences: const ActivityPreferences(
                  running: RunningPreferences(
                    preferredRunTimes: [PreferredRunTime.morning],
                    version: currentRunPreferencesVersion,
                  ),
                ),
              ),
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

      expect(find.text('FAVOURITE EVENT TIMES'), findsOneWidget);
      expect(find.text('Morning'), findsOneWidget);
      expect(find.text('Evening'), findsOneWidget);
    });
  });
}

File _welcomeStringsSource() {
  final handoff = File(
    '${Platform.environment['HOME']}/Downloads/Catch Design System (2)/splash-welcome-handoff/strings.json',
  );
  if (handoff.existsSync()) return handoff;
  return File('test/fixtures/splash_welcome_strings.json');
}

ActivityKind _welcomeActivityKind(String activity) => switch (activity) {
  'social-run' => ActivityKind.socialRun,
  'dinner' => ActivityKind.dinner,
  'pub-quiz' => ActivityKind.pubQuiz,
  'padel' => ActivityKind.padel,
  'running' => ActivityKind.running,
  'strength' => ActivityKind.strengthTraining,
  'bar-crawl' => ActivityKind.barCrawl,
  'yoga' => ActivityKind.yoga,
  'cycling' => ActivityKind.cycling,
  'singles' => ActivityKind.singlesMixer,
  _ => throw StateError('Unknown welcome activity slug: $activity'),
};

Color _colorFromHex(String hex) {
  final value = hex.replaceFirst('#', '');
  return Color(int.parse('FF$value', radix: 16));
}

final class _AnalyticsEventCall {
  const _AnalyticsEventCall(this.name, this.parameters);

  final String name;
  final Map<String, Object>? parameters;
}

final class _FakeAnalyticsReporter implements AnalyticsReporter {
  final events = <_AnalyticsEventCall>[];

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    events.add(_AnalyticsEventCall(name, parameters));
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {}

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setUserId(String? userId) async {}
}

class _OnboardingUploadFailureSeeder extends ConsumerStatefulWidget {
  const _OnboardingUploadFailureSeeder();

  @override
  ConsumerState<_OnboardingUploadFailureSeeder> createState() =>
      _OnboardingUploadFailureSeederState();
}

class _OnboardingUploadFailureSeederState
    extends ConsumerState<_OnboardingUploadFailureSeeder> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _started) return;
      _started = true;
      PhotoUploadController.uploadPhotoMutation.reset(ref);
      unawaited(
        PhotoUploadController.uploadPhotoMutation
            .run(ref, (tx) async {
              await tx
                  .get(photoUploadControllerProvider.notifier)
                  .pickAndUpload(0);
            })
            .catchError((_) {}),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const PhotosPage();
}

class _FailingOnboardingImageUploadRepository extends Fake
    implements ImageUploadRepository {
  @override
  Future<XFile?> pickImage({
    ImageUploadPurpose purpose = ImageUploadPurpose.profilePhoto,
    int? imageQuality,
  }) async {
    return XFile('picked-onboarding-photo.jpg');
  }

  @override
  Future<UploadedImage> uploadUserProfilePhoto({
    required String uid,
    required int index,
    required XFile image,
  }) async {
    throw obviousOfflineException();
  }
}

class _SilentOnboardingErrorLogger extends ErrorLogger {
  _SilentOnboardingErrorLogger()
    : super(crashReporter: null, shouldReportErrors: false);

  @override
  void log({
    required LogLevel level,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, String>? context,
  }) {}
}
