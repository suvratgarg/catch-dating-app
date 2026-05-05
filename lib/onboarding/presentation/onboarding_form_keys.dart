import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/widgets.dart';

abstract final class OnboardingFormKeys {
  static ValueKey<String> genderChip(Gender gender) =>
      ValueKey('onboarding-gender-${gender.name}');

  static ValueKey<String> interestedInChip(Gender gender) =>
      ValueKey('onboarding-interested-in-${gender.name}');
}
