import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';

enum OnboardingEntryMode {
  standard,
  profileCompletion,
  runPreferences;

  static OnboardingEntryMode fromFlags({
    required bool profileCompletionOnly,
    required bool runPreferencesOnly,
  }) {
    if (runPreferencesOnly) return OnboardingEntryMode.runPreferences;
    if (profileCompletionOnly) return OnboardingEntryMode.profileCompletion;
    return OnboardingEntryMode.standard;
  }
}

class OnboardingFlowState {
  const OnboardingFlowState({
    required this.entryMode,
    required this.step,
    required this.previousStep,
    required this.topBar,
  });

  final OnboardingEntryMode entryMode;
  final OnboardingStep step;
  final OnboardingStep? previousStep;
  final OnboardingTopBarState? topBar;

  bool get showsWelcome => step == OnboardingStep.welcome;

  bool get showsProgressShell => !showsWelcome;

  factory OnboardingFlowState.from({
    required OnboardingData data,
    required bool profileCompletionOnly,
    required bool runPreferencesOnly,
  }) {
    final entryMode = OnboardingEntryMode.fromFlags(
      profileCompletionOnly: profileCompletionOnly,
      runPreferencesOnly: runPreferencesOnly,
    );
    final minimumStep = entryMode.minimumBackStepFor(data.step);
    final previousStep = data.step.previousWithin(minimumStep);

    return OnboardingFlowState(
      entryMode: entryMode,
      step: data.step,
      previousStep: previousStep,
      topBar: data.step.showsProgress
          ? OnboardingTopBarState.from(
              step: data.step,
              entryMode: entryMode,
              canGoBack: previousStep != null,
            )
          : null,
    );
  }
}

extension OnboardingEntryModeX on OnboardingEntryMode {
  bool get profileCompletionOnly =>
      this == OnboardingEntryMode.profileCompletion;

  bool get runPreferencesOnly => this == OnboardingEntryMode.runPreferences;

  OnboardingStep minimumBackStepFor(OnboardingStep step) {
    if (this == OnboardingEntryMode.runPreferences) {
      return OnboardingStep.runningPrefs;
    }
    if (this == OnboardingEntryMode.profileCompletion &&
        step.index >= OnboardingStep.photos.index) {
      return OnboardingStep.photos;
    }
    return step.minimumBackStep;
  }
}

class OnboardingTopBarState {
  const OnboardingTopBarState({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.stepNumber,
    required this.stepTotal,
    required this.canGoBack,
  });

  final OnboardingStep step;
  final String title;
  final String? subtitle;
  final int stepNumber;
  final int stepTotal;
  final bool canGoBack;

  factory OnboardingTopBarState.from({
    required OnboardingStep step,
    required OnboardingEntryMode entryMode,
    required bool canGoBack,
  }) {
    final profileCompletionOnly = entryMode.profileCompletionOnly;
    final runPreferencesOnly = entryMode.runPreferencesOnly;
    final socialOnly =
        profileCompletionOnly && step.index >= OnboardingStep.photos.index;
    final progressIndex = runPreferencesOnly
        ? 0
        : socialOnly
        ? step.index - OnboardingStep.photos.index
        : step == OnboardingStep.genderInterest
        ? 1
        : 0;
    final progressTotal = runPreferencesOnly ? 1 : 2;
    final copy = step.headerCopy(
      profileCompletionOnly: profileCompletionOnly,
      runPreferencesOnly: runPreferencesOnly,
    );

    return OnboardingTopBarState(
      step: step,
      title: copy.title,
      subtitle: copy.subtitle,
      stepNumber: progressIndex + 1,
      stepTotal: progressTotal,
      canGoBack: canGoBack,
    );
  }
}
