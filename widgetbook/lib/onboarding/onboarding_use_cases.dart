import 'dart:async';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/image_uploads/domain/photo_upload_state.dart';
import 'package:catch_dating_app/image_uploads/shared/photo_upload_controller.dart';
import 'package:catch_dating_app/labs/design_fixtures/profile_surface_fixtures.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/onboarding/data/onboarding_draft_repository.dart';
import 'package:catch_dating_app/onboarding/domain/onboarding_draft.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_flow_state.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_screen.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/gender_interest_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/instagram_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/name_dob_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/photos_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/profile_prompts_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/running_prefs_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/welcome_page.dart';
import 'package:catch_dating_app/onboarding/shared/onboarding_step_layout.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

final _profileNoPhotos = ProfileSurfaceFixtures.viewer.copyWith(
  profileComplete: false,
  profilePhotos: const [],
);
final _profileOnePhoto = ProfileSurfaceFixtures.viewer.copyWith(
  profileComplete: false,
  profilePhotos: ProfileSurfaceFixtures.viewer.profilePhotos
      .take(1)
      .toList(growable: false),
);
final _profileReadyPhotos = ProfileSurfaceFixtures.viewer.copyWith(
  profileComplete: false,
  profilePhotos: ProfileSurfaceFixtures.viewer.profilePhotos
      .take(2)
      .toList(growable: false),
);
final _profileNoPrompts = ProfileSurfaceFixtures.viewer.copyWith(
  profileComplete: false,
  profilePrompts: const [],
);
final _profilePartialPrompts = ProfileSurfaceFixtures.viewer.copyWith(
  profileComplete: false,
  profilePrompts: _promptAnswers(
    'A low-pressure loop that ends with a table everyone can hear.',
  ),
);
final _profileCompletePrompts = ProfileSurfaceFixtures.viewer.copyWith(
  profileComplete: false,
  profilePrompts: _promptAnswers(
    'A golden-hour 5K, filter coffee, and no rushed exits.',
    'Saturday starts outside, detours through a bookshop, and ends with chaat.',
    'Tell me your favourite route and I will remember the coffee stop.',
  ),
);
final _profileLongPrompts = ProfileSurfaceFixtures.viewer.copyWith(
  profileComplete: false,
  profilePrompts: _promptAnswers(
    'A small group run where everyone knows the route, nobody sprints the '
        'first kilometer, and the table afterward has enough time for real '
        'conversation.',
    'I am happiest when Saturday starts outside, detours through a bookshop, '
        'and ends with friends arguing over where the best chaat actually is.',
    'The green flag is someone who can make an ordinary weekday plan feel '
        'specific, calm, and worth showing up for.',
  ),
);

List<ProfilePromptAnswer> _promptAnswers(
  String first, [
  String? second,
  String? third,
]) {
  final answers = <String>[first, ?second, ?third];
  return [
    for (final entry in answers.indexed)
      profilePromptAnswerFor(
        definition: profilePromptDefinition(defaultProfilePromptIds[entry.$1]),
        answer: entry.$2,
      ),
  ];
}

@widgetbook.UseCase(
  name: 'Route states',
  type: OnboardingScreen,
  path: '[P1 product surfaces]/Onboarding',
)
Widget onboardingScreenRouteStates(BuildContext context) {
  return _OnboardingCatalog(
    title: 'OnboardingScreen',
    children: [
      _StateCard(
        label: 'signed out welcome',
        child: const _DeviceFrame(
          child: _OnboardingScope(uid: null, child: OnboardingScreen()),
        ),
      ),
      _StateCard(
        label: 'profile completion flow',
        child: _DeviceFrame(
          child: _OnboardingScope(
            profile: _profileNoPhotos,
            child: OnboardingScreen(profileCompletionOnly: true),
          ),
        ),
      ),
      _StateCard(
        label: 'run preferences flow',
        child: const _DeviceFrame(
          child: _OnboardingScope(
            child: OnboardingScreen(runPreferencesOnly: true),
          ),
        ),
      ),
      _StateCard(
        label: 'save profile pending',
        child: const _DeviceFrame(
          child: _OnboardingScope(
            mode: _OnboardingPreviewMode.saveProfilePending,
            child: OnboardingScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'save profile error',
        child: const _DeviceFrame(
          child: _OnboardingScope(
            mode: _OnboardingPreviewMode.saveProfileError,
            child: OnboardingScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'complete pending',
        child: const _DeviceFrame(
          child: _OnboardingScope(
            mode: _OnboardingPreviewMode.completePending,
            child: OnboardingScreen(runPreferencesOnly: true),
          ),
        ),
      ),
      _StateCard(
        label: 'complete error',
        child: const _DeviceFrame(
          child: _OnboardingScope(
            mode: _OnboardingPreviewMode.completeError,
            child: OnboardingScreen(runPreferencesOnly: true),
          ),
        ),
      ),
      _StateCard(
        label: 'upload pending',
        child: _DeviceFrame(
          child: _OnboardingScope(
            mode: _OnboardingPreviewMode.photos,
            profile: _profileOnePhoto,
            uploadState: (loadingIndices: {1}, uploadError: null),
            child: OnboardingScreen(profileCompletionOnly: true),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2',
        child: const _DeviceFrame(
          child: _MediaOverride(
            textScale: 2,
            child: _OnboardingScope(child: OnboardingScreen()),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: const _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _OnboardingScope(
              mode: _OnboardingPreviewMode.genderInterest,
              child: OnboardingScreen(),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Top bar',
  type: OnboardingTopBar,
  path: '[P1 product surfaces]/Onboarding',
)
Widget onboardingTopBarState(BuildContext context) {
  return _OnboardingCatalog(
    title: 'OnboardingTopBar',
    children: [
      _StateCard(
        label: 'profile completion photos',
        child: OnboardingTopBar(
          state: OnboardingTopBarState.from(
            l10n: context.l10n,
            step: OnboardingStep.photos,
            entryMode: OnboardingEntryMode.profileCompletion,
            canGoBack: false,
          ),
          onBack: null,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Step layout states',
  type: OnboardingStepLayout,
  path: '[P1 product surfaces]/Onboarding',
)
Widget onboardingStepLayoutStates(BuildContext context) {
  return const _OnboardingCatalog(
    title: 'OnboardingStepLayout',
    children: [
      _StateCard(
        label: 'body only',
        child: _DeviceFrame(
          child: OnboardingStepLayout(
            children: [
              Text('Tell us enough to make your first plan feel natural.'),
              SizedBox(height: 16),
              Text('Use the shared onboarding body rhythm and max width.'),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'sticky footer',
        child: _DeviceFrame(
          child: OnboardingStepLayout(
            footer: Row(
              children: [
                Expanded(child: Text('2 / 3 prompts answered')),
                SizedBox(width: 12),
                CatchButton(label: 'Continue', onPressed: null),
              ],
            ),
            children: [
              Text('Complete the visible fields before continuing.'),
              SizedBox(height: 16),
              Text('The bottom dock stays outside the scroll owner.'),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Splash states',
  type: WelcomePage,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget welcomePageStates(BuildContext context) {
  return _OnboardingCatalog(
    title: 'WelcomePage',
    children: const [
      _StateCard(
        label: 'animated reel',
        child: _DeviceFrame(child: WelcomePage()),
      ),
      _StateCard(
        label: 'landed',
        child: _DeviceFrame(child: WelcomePage(playIntro: false)),
      ),
      _StateCard(
        label: 'reduced motion',
        child: _DeviceFrame(
          child: _MediaOverride(disableAnimations: true, child: WelcomePage()),
        ),
      ),
      _StateCard(
        label: 'text scale 2',
        child: _DeviceFrame(
          child: _MediaOverride(
            textScale: 2,
            child: WelcomePage(playIntro: false),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Welcome scene states',
  type: WelcomeScene,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget welcomeSceneStates(BuildContext context) {
  return const _OnboardingCatalog(
    title: 'WelcomeScene',
    children: [
      _StateCard(
        label: 'spinning',
        child: _DeviceFrame(
          child: WelcomeScene(
            viewportHeight: 760,
            mediaPadding: EdgeInsets.only(top: 44, bottom: 34),
            spinValue: 0.42,
            landingValue: 0,
            landed: false,
            onContinue: _noop,
            onExplore: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'landed',
        child: _DeviceFrame(
          child: WelcomeScene(
            viewportHeight: 760,
            mediaPadding: EdgeInsets.only(top: 44, bottom: 34),
            spinValue: 1,
            landingValue: 1,
            landed: true,
            onContinue: _noop,
            onExplore: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Welcome reel band states',
  type: ReelBand,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget welcomeReelBandStates(BuildContext context) {
  return _OnboardingCatalog(
    title: 'ReelBand',
    children: [
      _StateCard(
        label: 'spinning band',
        child: ColoredBox(
          color: CatchTokens.editorialDark.bg,
          child: const SizedBox(
            height: 360,
            child: ReelBand(spinValue: 0.5, landingValue: 0, landed: false),
          ),
        ),
      ),
      _StateCard(
        label: 'landed focus',
        child: ColoredBox(
          color: CatchTokens.editorialDark.bg,
          child: const SizedBox(
            height: 360,
            child: ReelBand(spinValue: 1, landingValue: 1, landed: true),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Welcome reel row states',
  type: ReelRow,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget welcomeReelRowStates(BuildContext context) {
  return _OnboardingCatalog(
    title: 'ReelRow',
    children: [
      _StateCard(
        label: 'activity phrase',
        child: ColoredBox(
          color: CatchTokens.editorialDark.bg,
          child: const SizedBox(
            height: 92,
            child: ReelRow(
              phrase: WelcomePhrase('the long table', ActivityKind.dinner),
              phraseIndex: 2,
              rowIndex: 2,
              trackOffset: 0,
              landingValue: 0,
              landed: false,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'landing phrase',
        child: ColoredBox(
          color: CatchTokens.editorialDark.bg,
          child: const SizedBox(
            height: 92,
            child: ReelRow(
              phrase: WelcomePhrase('someone real', ActivityKind.socialRun),
              phraseIndex: 11,
              rowIndex: 2,
              trackOffset: 0,
              landingValue: 1,
              landed: true,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Welcome reveal states',
  type: RevealEntrance,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget welcomeRevealEntranceStates(BuildContext context) {
  return _OnboardingCatalog(
    title: 'RevealEntrance',
    children: [
      _StateCard(
        label: 'settling',
        child: ColoredBox(
          color: CatchTokens.editorialDark.bg,
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: RevealEntrance(
              landingValue: 0.62,
              order: 0,
              child: Text(
                'Show up to something you would do anyway.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'visible',
        child: ColoredBox(
          color: CatchTokens.editorialDark.bg,
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: RevealEntrance(
              landingValue: 1,
              order: 1,
              child: Text(
                'Continue with phone',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Identity form',
  type: NameDobPage,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget nameDobPageStates(BuildContext context) {
  return const _OnboardingCatalog(
    title: 'NameDobPage',
    children: [
      _StateCard(
        label: 'default',
        child: _DeviceFrame(child: _OnboardingScope(child: NameDobPage())),
      ),
      _StateCard(
        label: 'prefilled draft',
        child: _DeviceFrame(
          child: _OnboardingScope(
            mode: _OnboardingPreviewMode.nameDobPrefilled,
            child: NameDobPage(),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2',
        child: _DeviceFrame(
          child: _MediaOverride(
            textScale: 2,
            child: _OnboardingScope(
              mode: _OnboardingPreviewMode.nameDobPrefilled,
              child: NameDobPage(),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Gender and interest form',
  type: GenderInterestPage,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget genderInterestPageStates(BuildContext context) {
  return const _OnboardingCatalog(
    title: 'GenderInterestPage',
    children: [
      _StateCard(
        label: 'default',
        child: _DeviceFrame(
          child: _OnboardingScope(child: GenderInterestPage()),
        ),
      ),
      _StateCard(
        label: 'selected values',
        child: _DeviceFrame(
          child: _OnboardingScope(
            mode: _OnboardingPreviewMode.genderInterestSelected,
            child: GenderInterestPage(),
          ),
        ),
      ),
      _StateCard(
        label: 'save pending',
        child: _DeviceFrame(
          child: _OnboardingScope(
            mode: _OnboardingPreviewMode.saveProfilePending,
            child: GenderInterestPage(),
          ),
        ),
      ),
      _StateCard(
        label: 'save error',
        child: _DeviceFrame(
          child: _OnboardingScope(
            mode: _OnboardingPreviewMode.saveProfileError,
            child: GenderInterestPage(),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _OnboardingScope(
              mode: _OnboardingPreviewMode.genderInterest,
              child: GenderInterestPage(),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Instagram form',
  type: InstagramPage,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget instagramPageStates(BuildContext context) {
  return const _OnboardingCatalog(
    title: 'InstagramPage',
    children: [
      _StateCard(
        label: 'default',
        child: _DeviceFrame(child: _OnboardingScope(child: InstagramPage())),
      ),
      _StateCard(
        label: 'filled handle',
        child: _DeviceFrame(
          child: _OnboardingScope(
            mode: _OnboardingPreviewMode.instagramFilled,
            child: InstagramPage(),
          ),
        ),
      ),
      _StateCard(
        label: 'skipped handle',
        child: _DeviceFrame(
          child: _OnboardingScope(
            mode: _OnboardingPreviewMode.instagramSkipped,
            child: InstagramPage(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Photo grid states',
  type: PhotosPage,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget photosPageStates(BuildContext context) {
  return _OnboardingCatalog(
    title: 'PhotosPage',
    children: [
      _StateCard(
        label: 'no photos disabled',
        child: _DeviceFrame(
          child: _OnboardingScope(
            profile: _profileNoPhotos,
            child: PhotosPage(),
          ),
        ),
      ),
      _StateCard(
        label: 'one photo disabled',
        child: _DeviceFrame(
          child: _OnboardingScope(
            profile: _profileOnePhoto,
            child: PhotosPage(),
          ),
        ),
      ),
      _StateCard(
        label: 'minimum photos',
        child: _DeviceFrame(
          child: _OnboardingScope(
            profile: _profileReadyPhotos,
            child: PhotosPage(),
          ),
        ),
      ),
      _StateCard(
        label: 'profile completion copy',
        child: _DeviceFrame(
          child: _OnboardingScope(
            profile: _profileReadyPhotos,
            child: PhotosPage(profileCompletionOnly: true),
          ),
        ),
      ),
      _StateCard(
        label: 'upload pending',
        child: _DeviceFrame(
          child: _OnboardingScope(
            profile: _profileOnePhoto,
            uploadState: (loadingIndices: {1}, uploadError: null),
            child: PhotosPage(profileCompletionOnly: true),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2',
        child: _DeviceFrame(
          child: _MediaOverride(
            textScale: 2,
            child: _OnboardingScope(
              profile: _profileOnePhoto,
              child: PhotosPage(profileCompletionOnly: true),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Prompt form',
  type: ProfilePromptsPage,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget profilePromptsPageStates(BuildContext context) {
  return _OnboardingCatalog(
    title: 'ProfilePromptsPage',
    children: [
      _StateCard(
        label: 'empty prompts',
        child: _DeviceFrame(
          child: _OnboardingScope(
            profile: _profileNoPrompts,
            child: ProfilePromptsPage(),
          ),
        ),
      ),
      _StateCard(
        label: 'partial prompts',
        child: _DeviceFrame(
          child: _OnboardingScope(
            profile: _profilePartialPrompts,
            child: ProfilePromptsPage(),
          ),
        ),
      ),
      _StateCard(
        label: 'complete prompts',
        child: _DeviceFrame(
          child: _OnboardingScope(
            profile: _profileCompletePrompts,
            child: ProfilePromptsPage(),
          ),
        ),
      ),
      _StateCard(
        label: 'long answers',
        child: _DeviceFrame(
          child: _OnboardingScope(
            profile: _profileLongPrompts,
            child: ProfilePromptsPage(),
          ),
        ),
      ),
      _StateCard(
        label: 'profile completion copy',
        child: _DeviceFrame(
          child: _OnboardingScope(
            profile: _profileCompletePrompts,
            child: ProfilePromptsPage(profileCompletionOnly: true),
          ),
        ),
      ),
      _StateCard(
        label: 'complete pending',
        child: _DeviceFrame(
          child: _OnboardingScope(
            mode: _OnboardingPreviewMode.completePending,
            profile: _profileCompletePrompts,
            child: ProfilePromptsPage(profileCompletionOnly: true),
          ),
        ),
      ),
      _StateCard(
        label: 'complete error',
        child: _DeviceFrame(
          child: _OnboardingScope(
            mode: _OnboardingPreviewMode.completeError,
            profile: _profileCompletePrompts,
            child: ProfilePromptsPage(profileCompletionOnly: true),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Prompt field states',
  type: PromptField,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget promptFieldStates(BuildContext context) {
  final answeredController = TextEditingController(
    text: 'A walk where phones disappear and the coffee after runs long.',
  );
  final emptyController = TextEditingController();
  final promptIds = defaultProfilePromptIds.take(3).toList(growable: false);

  return _OnboardingCatalog(
    title: 'PromptField',
    children: [
      _StateCard(
        label: 'answered',
        child: PromptField(
          index: 0,
          definition: profilePromptDefinition(promptIds[0]),
          controller: answeredController,
          availablePromptIds: promptIds,
          selectedPromptId: promptIds[0],
          onPromptChanged: (_) {},
        ),
      ),
      _StateCard(
        label: 'empty',
        child: PromptField(
          index: 1,
          definition: profilePromptDefinition(promptIds[1]),
          controller: emptyController,
          availablePromptIds: promptIds,
          selectedPromptId: promptIds[1],
          onPromptChanged: (_) {},
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Run preferences form',
  type: RunningPrefsPage,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget runningPrefsPageStates(BuildContext context) {
  return const _OnboardingCatalog(
    title: 'RunningPrefsPage',
    children: [
      _StateCard(
        label: 'onboarding completion',
        child: _DeviceFrame(child: _OnboardingScope(child: RunningPrefsPage())),
      ),
      _StateCard(
        label: 'booking resume',
        child: _DeviceFrame(
          child: _OnboardingScope(
            child: RunningPrefsPage(runPreferencesOnly: true),
          ),
        ),
      ),
      _StateCard(
        label: 'complete pending',
        child: _DeviceFrame(
          child: _OnboardingScope(
            mode: _OnboardingPreviewMode.completePending,
            child: RunningPrefsPage(runPreferencesOnly: true),
          ),
        ),
      ),
      _StateCard(
        label: 'complete error',
        child: _DeviceFrame(
          child: _OnboardingScope(
            mode: _OnboardingPreviewMode.completeError,
            child: RunningPrefsPage(runPreferencesOnly: true),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2',
        child: _DeviceFrame(
          child: _MediaOverride(
            textScale: 2,
            child: _OnboardingScope(
              child: RunningPrefsPage(runPreferencesOnly: true),
            ),
          ),
        ),
      ),
    ],
  );
}

enum _OnboardingPreviewMode {
  idle,
  nameDobPrefilled,
  genderInterest,
  genderInterestSelected,
  instagramFilled,
  instagramSkipped,
  photos,
  saveProfilePending,
  saveProfileError,
  completePending,
  completeError,
}

class _OnboardingScope extends StatelessWidget {
  const _OnboardingScope({
    required this.child,
    this.uid = 'widgetbook-viewer',
    this.profile,
    this.uploadState = _idlePhotoUploadState,
    this.mode = _OnboardingPreviewMode.idle,
  });

  final String? uid;
  final UserProfile? profile;
  final PhotoUploadState uploadState;
  final _OnboardingPreviewMode mode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final viewer =
        profile ?? ProfileSurfaceFixtures.viewer.copyWith(uid: uid ?? '');
    final effectiveProfile = uid == null ? null : viewer;

    return ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(AsyncData<String?>(uid)),
        watchUserProfileProvider.overrideWith(
          (ref) => Stream.value(effectiveProfile),
        ),
        userProfileRepositoryProvider.overrideWithValue(
          ProfileFixtureUserProfileRepository(profile: effectiveProfile),
        ),
        authRepositoryProvider.overrideWithValue(
          const _WidgetbookOnboardingAuthRepository(),
        ),
        onboardingDraftRepositoryProvider.overrideWithValue(
          _WidgetbookOnboardingDraftRepository(),
        ),
        photoUploadControllerProvider.overrideWithValue(uploadState),
      ],
      child: _OnboardingPreviewSeeder(mode: mode, child: child),
    );
  }
}

const PhotoUploadState _idlePhotoUploadState = (
  loadingIndices: <int>{},
  uploadError: null,
);

class _OnboardingPreviewSeeder extends ConsumerStatefulWidget {
  const _OnboardingPreviewSeeder({required this.mode, required this.child});

  final _OnboardingPreviewMode mode;
  final Widget child;

  @override
  ConsumerState<_OnboardingPreviewSeeder> createState() =>
      _OnboardingPreviewSeederState();
}

class _OnboardingPreviewSeederState
    extends ConsumerState<_OnboardingPreviewSeeder> {
  Completer<void>? _pendingCompleter;

  @override
  void initState() {
    super.initState();
    _seed();
  }

  @override
  void didUpdateWidget(covariant _OnboardingPreviewSeeder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _completePending();
      _seed();
    }
  }

  @override
  void dispose() {
    _completePending();
    super.dispose();
  }

  void _seed() {
    OnboardingController.saveProfileMutation.reset(ref);
    OnboardingController.completeMutation.reset(ref);

    final controller = ref.read(onboardingControllerProvider.notifier);
    switch (widget.mode) {
      case _OnboardingPreviewMode.idle:
        break;
      case _OnboardingPreviewMode.nameDobPrefilled:
        _seedBookingIdentity(controller);
        controller.goToStep(OnboardingStep.nameDob);
        break;
      case _OnboardingPreviewMode.genderInterest:
        _seedBookingIdentity(controller);
        controller.goToStep(OnboardingStep.genderInterest);
        break;
      case _OnboardingPreviewMode.genderInterestSelected:
        _seedGenderInterest(controller);
        break;
      case _OnboardingPreviewMode.instagramFilled:
        _seedGenderInterest(controller);
        controller.setInstagramHandle('neharuns');
        controller.goToStep(OnboardingStep.instagram);
        break;
      case _OnboardingPreviewMode.instagramSkipped:
        _seedGenderInterest(controller);
        controller.setInstagramHandle(null);
        controller.goToStep(OnboardingStep.instagram);
        break;
      case _OnboardingPreviewMode.photos:
        _seedGenderInterest(controller);
        controller.goToStep(OnboardingStep.photos);
        break;
      case _OnboardingPreviewMode.saveProfilePending:
        _seedGenderInterest(controller);
        _runPending(OnboardingController.saveProfileMutation);
        break;
      case _OnboardingPreviewMode.saveProfileError:
        _seedGenderInterest(controller);
        _runError(
          OnboardingController.saveProfileMutation,
          const NetworkException(
            'widgetbook-onboarding-save-failed',
            'We could not save your profile. Please try again.',
            context: BackendErrorContext(
              service: BackendService.firestore,
              action: 'save onboarding profile',
              resource: 'users',
            ),
          ),
        );
        break;
      case _OnboardingPreviewMode.completePending:
        controller.goToStep(OnboardingStep.runningPrefs);
        _runPending(OnboardingController.completeMutation);
        break;
      case _OnboardingPreviewMode.completeError:
        controller.goToStep(OnboardingStep.runningPrefs);
        _runError(
          OnboardingController.completeMutation,
          const NetworkException(
            'widgetbook-onboarding-complete-failed',
            'We could not finish onboarding. Please try again.',
            context: BackendErrorContext(
              service: BackendService.firestore,
              action: 'complete onboarding',
              resource: 'users',
            ),
          ),
        );
        break;
    }
  }

  void _seedGenderInterest(OnboardingController controller) {
    _seedBookingIdentity(controller);
    controller
      ..setGenderInterest(
        gender: Gender.woman,
        interestedInGenders: const [Gender.man],
      )
      ..goToStep(OnboardingStep.genderInterest);
  }

  void _seedBookingIdentity(OnboardingController controller) {
    controller.setNameDob(
      firstName: 'Neha',
      lastName: 'Kapoor',
      dateOfBirth: DateTime(1996, 4, 12),
      phoneNumber: '9876543210',
      countryCode: '+91',
    );
  }

  void _runPending(Mutation<void> mutation) {
    final completer = Completer<void>();
    _pendingCompleter = completer;
    unawaited(mutation.run(ref, (_) => completer.future));
  }

  void _runError(Mutation<void> mutation, Object error) {
    unawaited(mutation.run(ref, (_) async => throw error).catchError((_) {}));
  }

  void _completePending() {
    final completer = _pendingCompleter;
    _pendingCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _OnboardingCatalog extends StatelessWidget {
  const _OnboardingCatalog({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Wrap(spacing: 16, runSpacing: 16, children: children),
      ],
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 390,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 390,
      height: 760,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: child,
        ),
      ),
    );
  }
}

class _MediaOverride extends StatelessWidget {
  const _MediaOverride({
    required this.child,
    this.disableAnimations = false,
    this.textScale,
  });

  final Widget child;
  final bool disableAnimations;
  final double? textScale;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        disableAnimations: disableAnimations,
        textScaler: textScale == null ? null : TextScaler.linear(textScale!),
      ),
      child: child,
    );
  }
}

void _noop() {}

class _WidgetbookOnboardingAuthRepository implements AuthRepository {
  const _WidgetbookOnboardingAuthRepository();

  @override
  User? get currentUser => null;

  @override
  Stream<User?> authStateChanges() => Stream<User?>.value(null);

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    int? forceResendingToken,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(AppException e) verificationFailed,
    required void Function(PhoneAuthCredential credential)
    verificationCompleted,
  }) async {
    codeSent('widgetbook-onboarding-verification-id', null);
  }

  @override
  Future<void> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {}

  @override
  Future<void> signInWithCredential(AuthCredential credential) async {}

  @override
  Future<void> signOut() async {}
}

class _WidgetbookOnboardingDraftRepository
    implements OnboardingDraftRepository {
  OnboardingDraft? _draft;

  @override
  Future<OnboardingDraft?> fetchDraft({required String uid}) async => _draft;

  @override
  Future<void> saveDraft({
    required String uid,
    required OnboardingDraft draft,
  }) async {
    _draft = draft;
  }

  @override
  Future<void> deleteDraft({required String uid}) async {
    _draft = null;
  }
}
