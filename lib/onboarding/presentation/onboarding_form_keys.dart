import 'package:flutter/widgets.dart';

abstract final class OnboardingFormKeys {
  static const gender = ValueKey<String>('onboarding-gender');
  static const interestedIn = ValueKey<String>('onboarding-interested-in');
  static const dateOfBirth = ValueKey<String>('onboarding-date-of-birth');
  static const phone = ValueKey<String>('onboarding-phone');
  static const runningPace = ValueKey<String>('onboarding-running-pace');
  static const runningDistances = ValueKey<String>(
    'onboarding-running-distances',
  );
  static const runningReasons = ValueKey<String>('onboarding-running-reasons');
  static const runningTimes = ValueKey<String>('onboarding-running-times');
}
