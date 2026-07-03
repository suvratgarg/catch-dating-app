import 'package:catch_dating_app/user_profile/domain/user_profile.dart';

class OnboardingGenderInterestState {
  const OnboardingGenderInterestState({
    required this.gender,
    required this.interestedIn,
    required this.isSaving,
    required this.saveErrorMessage,
  });

  factory OnboardingGenderInterestState.fromDraft({
    required Gender? gender,
    required Iterable<Gender> interestedIn,
    bool isSaving = false,
    String? saveErrorMessage,
  }) {
    return OnboardingGenderInterestState(
      gender: gender,
      interestedIn: Set<Gender>.unmodifiable(interestedIn),
      isSaving: isSaving,
      saveErrorMessage: saveErrorMessage,
    );
  }

  final Gender? gender;
  final Set<Gender> interestedIn;
  final bool isSaving;
  final String? saveErrorMessage;

  Set<Gender> get selectedGender =>
      gender == null ? const <Gender>{} : {gender!};

  bool get hasSaveError => saveErrorMessage != null;

  String? validateGender(Set<Gender>? value) =>
      gender == null ? 'Please select your gender' : null;

  String? validateInterestedIn(Set<Gender>? value) =>
      interestedIn.isEmpty ? 'Please select who you want to see' : null;

  OnboardingGenderInterestSubmitIntent? submitIntent() {
    final gender = this.gender;
    if (gender == null || interestedIn.isEmpty) return null;
    return OnboardingGenderInterestSubmitIntent(
      gender: gender,
      interestedInGenders: List<Gender>.unmodifiable(interestedIn),
    );
  }
}

class OnboardingGenderInterestSubmitIntent {
  const OnboardingGenderInterestSubmitIntent({
    required this.gender,
    required this.interestedInGenders,
  });

  final Gender gender;
  final List<Gender> interestedInGenders;
}

class OnboardingGenderInterestCallbacks {
  const OnboardingGenderInterestCallbacks({
    required this.onGenderChanged,
    required this.onInterestedInChanged,
    required this.onContinue,
  });

  final void Function(Set<Gender> next) onGenderChanged;
  final void Function(Set<Gender> next) onInterestedInChanged;
  final void Function() onContinue;
}
