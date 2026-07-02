import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/labs/design_fixtures/profile_surface_fixtures.dart';
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
import 'package:catch_dating_app/onboarding/presentation/widgets/onboarding_step_layout.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

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
        child: const _DeviceFrame(
          child: _OnboardingScope(
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
          color: CatchTokens.sunsetDark.bg,
          child: const SizedBox(
            height: 360,
            child: ReelBand(spinValue: 0.5, landingValue: 0, landed: false),
          ),
        ),
      ),
      _StateCard(
        label: 'landed focus',
        child: ColoredBox(
          color: CatchTokens.sunsetDark.bg,
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
          color: CatchTokens.sunsetDark.bg,
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
          color: CatchTokens.sunsetDark.bg,
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
          color: CatchTokens.sunsetDark.bg,
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
          color: CatchTokens.sunsetDark.bg,
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
    ],
  );
}

@widgetbook.UseCase(
  name: 'Photo grid states',
  type: PhotosPage,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget photosPageStates(BuildContext context) {
  return const _OnboardingCatalog(
    title: 'PhotosPage',
    children: [
      _StateCard(
        label: 'minimum photos',
        child: _DeviceFrame(child: _OnboardingScope(child: PhotosPage())),
      ),
      _StateCard(
        label: 'profile completion copy',
        child: _DeviceFrame(
          child: _OnboardingScope(
            child: PhotosPage(profileCompletionOnly: true),
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
  return const _OnboardingCatalog(
    title: 'ProfilePromptsPage',
    children: [
      _StateCard(
        label: 'default prompts',
        child: _DeviceFrame(
          child: _OnboardingScope(child: ProfilePromptsPage()),
        ),
      ),
      _StateCard(
        label: 'profile completion copy',
        child: _DeviceFrame(
          child: _OnboardingScope(
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
    ],
  );
}

class _OnboardingScope extends StatelessWidget {
  const _OnboardingScope({required this.child, this.uid = 'widgetbook-viewer'});

  final String? uid;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final viewer = ProfileSurfaceFixtures.viewer.copyWith(uid: uid ?? '');

    return ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(AsyncData<String?>(uid)),
        watchUserProfileProvider.overrideWith(
          (ref) => Stream.value(uid == null ? null : viewer),
        ),
      ],
      child: child,
    );
  }
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
