enum OnboardingStep {
  welcome,
  phone,
  otp,
  nameDob,
  genderInterest,
  photos,
  runningPrefs,
}

extension OnboardingStepX on OnboardingStep {
  bool get showsProgress => this != OnboardingStep.welcome;

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
