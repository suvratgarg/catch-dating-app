import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_profile_draft.freezed.dart';

@freezed
abstract class OnboardingProfileDraft with _$OnboardingProfileDraft {
  const OnboardingProfileDraft._();

  const factory OnboardingProfileDraft({
    @Default('') String firstName,
    @Default('') String lastName,
    DateTime? dateOfBirth,
    @Default('') String phoneNumber,
    @Default('+91') String countryCode,
    Gender? gender,
    @Default([]) List<Gender> interestedInGenders,
    String? instagramHandle,
  }) = _OnboardingProfileDraft;

  String get fullName => '$firstName $lastName'.trim();
}
