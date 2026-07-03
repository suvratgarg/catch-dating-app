import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/image_uploads/shared/photo_grid_keys.dart';
import 'package:catch_dating_app/image_uploads/shared/photo_upload_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_form_keys.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_screen.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/gender_interest_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/name_dob_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/photos_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/photos_page_state.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/profile_prompts_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/running_prefs_page.dart';
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

      expect(
        find.widgetWithText(
          MenuItemButton,
          profilePromptDefinition(profilePromptPerfectEventId).title,
        ),
        findsNothing,
      );
      final unusedPrompt = profilePromptCatalog.firstWhere(
        (definition) => !defaultProfilePromptIds.contains(definition.id),
      );
      await tester.tap(find.widgetWithText(MenuItemButton, unusedPrompt.title));
      await pumpOnboardingUi(tester);

      await tester.tap(menus.at(2));
      await pumpOnboardingUi(tester);

      expect(
        find.widgetWithText(MenuItemButton, unusedPrompt.title),
        findsNothing,
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
