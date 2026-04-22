import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

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

enum SexualOrientation implements Labelled {
  straight('Straight'),
  gay('Gay'),
  bisexual('Bisexual'),
  pansexual('Pansexual'),
  asexual('Asexual'),
  other('Other');

  const SexualOrientation(this.label);
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
abstract class AppUser with _$AppUser {
  const AppUser._();

  const factory AppUser({
    // Core (required at sign-up)
    @JsonKey(includeToJson: false) required String uid,
    required String name,
    @TimestampConverter() required DateTime dateOfBirth,
    required Gender gender,
    required SexualOrientation sexualOrientation,
    required String phoneNumber,
    required bool profileComplete,

    // Filled in via edit profile or email sign-up
    @Default('') String email,
    @Default('') String bio,

    // Photos
    @Default([]) List<String> photoUrls,

    // Location
    @JsonKey(unknownEnumValue: null) IndianCity? city,

    // Matching preferences
    @Default([]) List<String> followedRunClubIds,
    @Default([]) List<Gender> interestedInGenders,
    @Default(18) int minAgePreference,
    @Default(99) int maxAgePreference,

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
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  int get age {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}
