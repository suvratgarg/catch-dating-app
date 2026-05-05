import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingStepX', () {
    test('shows progress for every step after welcome', () {
      expect(OnboardingStep.welcome.showsProgress, isFalse);
      expect(OnboardingStep.nameDob.showsProgress, isTrue);
      expect(OnboardingStep.runningPrefs.showsProgress, isTrue);
    });

    test('locks back navigation to name step once profile steps begin', () {
      expect(OnboardingStep.welcome.minimumBackStep, OnboardingStep.welcome);
      expect(OnboardingStep.nameDob.minimumBackStep, OnboardingStep.nameDob);
      expect(
        OnboardingStep.runningPrefs.minimumBackStep,
        OnboardingStep.nameDob,
      );
    });

    test('returns the previous step only when still above the minimum', () {
      expect(
        OnboardingStep.genderInterest.previousWithin(OnboardingStep.welcome),
        OnboardingStep.nameDob,
      );
      expect(
        OnboardingStep.nameDob.previousWithin(OnboardingStep.nameDob),
        isNull,
      );
      expect(
        OnboardingStep.photos.previousWithin(OnboardingStep.nameDob),
        OnboardingStep.instagram,
      );
    });
  });
}
