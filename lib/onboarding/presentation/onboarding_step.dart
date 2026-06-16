enum OnboardingStep {
  welcome,
  nameDob,
  genderInterest,
  instagram,
  photos,
  prompts,
  runningPrefs;

  static OnboardingStep? fromIndex(int index) {
    if (index < 0 || index >= OnboardingStep.values.length) return null;
    return OnboardingStep.values[index];
  }
}

extension OnboardingStepX on OnboardingStep {
  bool get showsProgress => this != OnboardingStep.welcome;

  /// The step's question + supporting line, surfaced in the flow header (the DS
  /// pattern: the header carries the question, the page carries only the form).
  /// Conditional copy mirrors the `profileCompletionOnly` / `runPreferencesOnly`
  /// entry modes the onboarding screen drives.
  ({String title, String? subtitle}) headerCopy({
    required bool profileCompletionOnly,
    required bool runPreferencesOnly,
  }) {
    return switch (this) {
      OnboardingStep.welcome => (title: 'Welcome', subtitle: null),
      OnboardingStep.nameDob => (
        title: "What's your name?",
        subtitle: 'Last name stays private until you catch.',
      ),
      OnboardingStep.genderInterest => (
        title: 'How do you identify?',
        subtitle: null,
      ),
      OnboardingStep.instagram => (
        title: 'Your Instagram',
        subtitle:
            'Helps us verify you for early access. Your handle is never shown to other users.',
      ),
      OnboardingStep.photos => profileCompletionOnly
          ? (
              title: 'Complete your profile for Catches',
              subtitle:
                  'Catches need photos so people can decide who they want to meet. You can still book events with your current details.',
            )
          : (
              title: 'Show yourself',
              subtitle: 'Add at least 2 photos so others can find you.',
            ),
      OnboardingStep.prompts => profileCompletionOnly
          ? (
              title: 'Add prompts to start catching',
              subtitle:
                  'Prompts give people something real to respond to before you match.',
            )
          : (
              title: 'Show your personality',
              subtitle: 'Answer 3 prompts to complete your profile.',
            ),
      OnboardingStep.runningPrefs => profileCompletionOnly
          ? (
              title: 'Finish your Catches profile',
              subtitle:
                  'These are optional, but they help us rank compatible people in Catches.',
            )
          : runPreferencesOnly
          ? (
              title: 'Set your run preferences',
              subtitle:
                  'We only ask for these before run events so hosts can plan pace groups and distances.',
            )
          : (
              title: 'Your running style',
              subtitle: 'Help us find compatible running partners.',
            ),
    };
  }

  String get appBarTitle {
    return switch (this) {
      OnboardingStep.welcome => 'Welcome',
      OnboardingStep.nameDob => 'Your name',
      OnboardingStep.genderInterest => 'Gender',
      OnboardingStep.instagram => 'Instagram',
      OnboardingStep.photos => 'Photos',
      OnboardingStep.prompts => 'Prompts',
      OnboardingStep.runningPrefs => 'Running style',
    };
  }

  OnboardingStep get minimumBackStep {
    if (index >= OnboardingStep.nameDob.index) {
      return OnboardingStep.nameDob;
    }
    return OnboardingStep.welcome;
  }

  OnboardingStep? previousWithin(OnboardingStep minimumStep) {
    if (index <= minimumStep.index) {
      return null;
    }
    return OnboardingStep.values[index - 1];
  }
}
