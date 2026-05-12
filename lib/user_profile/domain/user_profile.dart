import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

// ── Identity ──────────────────────────────────────────────────────────────────

enum Gender implements Labelled {
  man('Man'),
  woman('Woman'),
  nonBinary('Non-binary'),
  other('Other');

  const Gender(this.label);
  @override
  final String label;
}

// ── Background ────────────────────────────────────────────────────────────────

enum EducationLevel implements Labelled {
  highSchool('High school'),
  someCollege('Some college'),
  bachelors("Bachelor's"),
  masters("Master's"),
  phd('PhD'),
  tradeSchool('Vocational / Trade'),
  other('Other');

  const EducationLevel(this.label);
  @override
  final String label;
}

enum Religion implements Labelled {
  hindu('Hindu'),
  muslim('Muslim'),
  christian('Christian'),
  sikh('Sikh'),
  jain('Jain'),
  buddhist('Buddhist'),
  other('Other'),
  nonReligious('Non-religious');

  const Religion(this.label);
  @override
  final String label;
}

enum Language implements Labelled {
  english('English'),
  hindi('Hindi'),
  marathi('Marathi'),
  tamil('Tamil'),
  telugu('Telugu'),
  kannada('Kannada'),
  bengali('Bengali'),
  gujarati('Gujarati'),
  punjabi('Punjabi'),
  malayalam('Malayalam'),
  odia('Odia'),
  other('Other');

  const Language(this.label);
  @override
  final String label;
}

// ── Intentions ────────────────────────────────────────────────────────────────

enum RelationshipGoal implements Labelled {
  relationship('Long-term relationship'),
  casual('Something casual'),
  marriage('Marriage'),
  friendship('New friends'),
  unsure('Still figuring out');

  const RelationshipGoal(this.label);
  @override
  final String label;
}

// ── Lifestyle ─────────────────────────────────────────────────────────────────

enum DrinkingHabit implements Labelled {
  never('Never'),
  socially('Socially'),
  often('Often');

  const DrinkingHabit(this.label);
  @override
  final String label;
}

enum SmokingHabit implements Labelled {
  never('Never'),
  occasionally('Occasionally'),
  often('Often');

  const SmokingHabit(this.label);
  @override
  final String label;
}

enum WorkoutFrequency implements Labelled {
  never('Never'),
  sometimes('Sometimes'),
  often('Often'),
  everyday('Every day');

  const WorkoutFrequency(this.label);
  @override
  final String label;
}

enum DietaryPreference implements Labelled {
  omnivore('Omnivore'),
  vegetarian('Vegetarian'),
  vegan('Vegan'),
  jain('Jain'),
  other('Other');

  const DietaryPreference(this.label);
  @override
  final String label;
}

enum ChildrenStatus implements Labelled {
  dontHave("Don't have"),
  haveWantMore('Have & want more'),
  haveNoMore("Have, don't want more"),
  wantSomeday('Want someday'),
  dontWant("Don't want");

  const ChildrenStatus(this.label);
  @override
  final String label;
}

// ── Running preferences ───────────────────────────────────────────────────────

enum PreferredDistance implements Labelled {
  fiveK('5 km'),
  tenK('10 km'),
  halfMarathon('21 km'),
  marathon('42 km');

  const PreferredDistance(this.label);
  @override
  final String label;
}

enum RunReason implements Labelled {
  fitness('Stay fit'),
  community('Community'),
  mindfulness('Mindfulness'),
  challenge('Push limits'),
  weightLoss('Weight loss'),
  raceTraining('Race training'),
  social('Make friends');

  const RunReason(this.label);
  @override
  final String label;
}

// ── Domain model ──────────────────────────────────────────────────────────────

@freezed
abstract class UserProfile with _$UserProfile {
  const UserProfile._();

  const factory UserProfile({
    // Core (required at sign-up)
    @JsonKey(includeToJson: false) required String uid,
    required String name,
    @Default('') String firstName,
    @Default('') String lastName,
    @Default('') String displayName,
    @TimestampConverter() required DateTime dateOfBirth,
    required Gender gender,
    required String phoneNumber,
    required bool profileComplete,

    // Optional profile/contact field. Authentication is phone-only.
    @Default('') String email,
    @Default('') String bio,
    String? instagramHandle,

    // Photos
    @Default([]) List<String> photoUrls,
    @Default([]) List<String> photoThumbnailUrls,

    // Location
    String? city,
    double? latitude,
    double? longitude,

    // Matching preferences. Profile creation/update validators require at least
    // one value before a profile can be saved.
    @Default([]) List<Gender> interestedInGenders,
    @Default(18) int minAgePreference,
    @Default(maximumPreferredMatchAge) int maxAgePreference,

    // Background (optional)
    int? height,
    String? occupation,
    String? company,
    @JsonKey(unknownEnumValue: null) EducationLevel? education,
    @JsonKey(unknownEnumValue: null) Religion? religion,
    @Default([]) List<Language> languages,

    // Intentions (optional)
    @JsonKey(unknownEnumValue: null) RelationshipGoal? relationshipGoal,

    // Lifestyle (optional)
    @JsonKey(unknownEnumValue: null) DrinkingHabit? drinking,
    @JsonKey(unknownEnumValue: null) SmokingHabit? smoking,
    @JsonKey(unknownEnumValue: null) WorkoutFrequency? workout,
    @JsonKey(unknownEnumValue: null) DietaryPreference? diet,
    @JsonKey(unknownEnumValue: null) ChildrenStatus? children,

    // Running preferences (set during onboarding)
    @Default(300) int paceMinSecsPerKm,
    @Default(420) int paceMaxSecsPerKm,
    @Default([]) List<PreferredDistance> preferredDistances,
    @Default([]) List<RunReason> runningReasons,

    // Notification / discovery preferences
    @Default(true) bool prefsNewCatches,
    @Default(true) bool prefsMessages,
    @Default(true) bool prefsRunReminders,
    @Default(true) bool prefsRunStatusUpdates,
    @Default(true) bool prefsClubUpdates,
    @Default(false) bool prefsWeeklyDigest,
    @Default(true) bool prefsShowOnMap,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  int get age => calculateAge(dateOfBirth);

  String get accountDisplayName {
    final parts = [
      firstName.trim(),
      lastName.trim(),
    ].where((part) => part.isNotEmpty);
    final structuredName = parts.join(' ');
    return structuredName.isNotEmpty ? structuredName : name.trim();
  }

  String get publicDisplayName {
    final display = displayName.trim();
    if (display.isNotEmpty) return display;
    final first = firstName.trim();
    if (first.isNotEmpty) return first;
    final legacyName = name.trim();
    if (legacyName.isEmpty) return 'Runner';
    return legacyName.split(RegExp(r'\s+')).first;
  }

  /// Tiny first-photo URL for avatar-scale UI. Falls back to the full photo
  /// until the backend thumbnail generation queue has backfilled old profiles.
  String? get primaryPhotoThumbnailUrl {
    final thumbnailUrl = photoThumbnailUrls
        .where((url) => url.isNotEmpty)
        .firstOrNull;
    if (thumbnailUrl != null) return thumbnailUrl;
    final photoUrl = photoUrls.where((url) => url.isNotEmpty).firstOrNull;
    if (photoUrl != null) return photoUrl;
    return null;
  }
}
