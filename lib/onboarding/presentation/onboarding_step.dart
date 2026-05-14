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
