import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
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
    @Default(defaultCountryDialCode) String countryCode,
    Gender? gender,
    @Default([]) List<Gender> interestedInGenders,
    String? instagramHandle,
    @Default([]) List<ProfilePromptAnswer> profilePrompts,
  }) = _OnboardingProfileDraft;

  String get fullName => '$firstName $lastName'.trim();
}
