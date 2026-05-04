import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_draft.freezed.dart';
part 'onboarding_draft.g.dart';

@freezed
abstract class OnboardingDraft with _$OnboardingDraft {
  const OnboardingDraft._();

  const factory OnboardingDraft({
    required int step,
    @Default('') String firstName,
    @Default('') String lastName,
    @TimestampConverter() DateTime? dateOfBirth,
    @Default('') String phoneNumber,
    @Default('+91') String countryCode,
    Gender? gender,
    @Default([]) List<Gender> interestedInGenders,
    String? instagramHandle,
  }) = _OnboardingDraft;

  factory OnboardingDraft.fromJson(Map<String, dynamic> json) =>
      _$OnboardingDraftFromJson(json);
}
