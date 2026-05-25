import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'public_profile.freezed.dart';
part 'public_profile.g.dart';

@freezed
abstract class PublicProfile with _$PublicProfile {
  const factory PublicProfile({
    @JsonKey(includeToJson: false) required String uid,
    required String name,
    required int age,
    required Gender gender,
    @Default([]) List<ProfilePromptAnswer> profilePrompts,
    @Default([]) List<ProfilePhoto> profilePhotos,

    // Location
    String? city,

    // Background
    int? height,
    String? occupation,
    String? company,
    @JsonKey(unknownEnumValue: null) EducationLevel? education,
    @JsonKey(unknownEnumValue: null) Religion? religion,
    @Default([]) List<Language> languages,

    // Intentions
    @JsonKey(unknownEnumValue: null) RelationshipGoal? relationshipGoal,

    // Lifestyle
    @JsonKey(unknownEnumValue: null) DrinkingHabit? drinking,
    @JsonKey(unknownEnumValue: null) SmokingHabit? smoking,
    @JsonKey(unknownEnumValue: null) WorkoutFrequency? workout,
    @JsonKey(unknownEnumValue: null) DietaryPreference? diet,
    @JsonKey(unknownEnumValue: null) ChildrenStatus? children,

    // Activity preferences
    @Default(ActivityPreferences()) ActivityPreferences activityPreferences,
  }) = _PublicProfile;

  factory PublicProfile.fromJson(Map<String, dynamic> json) =>
      _$PublicProfileFromJson(_migratePublicProfileJson(json));
}

/// Builds a [PublicProfile] from a [UserProfile], projecting only the fields
/// that are visible to other users.
///
/// This is still useful on the client for previews and tests, but the
/// persisted `publicProfiles/{uid}` document is owned by Cloud Functions.
PublicProfile publicProfileFromUserProfile(UserProfile user) => PublicProfile(
  uid: user.uid,
  name: user.publicDisplayName,
  age: user.age,
  gender: user.gender,
  profilePrompts: user.profilePrompts,
  profilePhotos: user.effectiveProfilePhotos,
  city: user.city,
  height: user.height,
  occupation: user.occupation,
  company: user.company,
  education: user.education,
  religion: user.religion,
  languages: user.languages,
  relationshipGoal: user.relationshipGoal,
  drinking: user.drinking,
  smoking: user.smoking,
  workout: user.workout,
  diet: user.diet,
  children: user.children,
  activityPreferences: user.activityPreferences,
);

Map<String, dynamic> _migratePublicProfileJson(Map<String, dynamic> json) {
  final migrated = Map<String, dynamic>.from(json);
  final legacyBio = migrated['bio'];
  final hasStructuredPrompts =
      migrated['profilePrompts'] is List &&
      (migrated['profilePrompts'] as List).isNotEmpty;

  if (!hasStructuredPrompts &&
      legacyBio is String &&
      legacyBio.trim().isNotEmpty) {
    migrated['profilePrompts'] = profilePromptsToJson(
      normalizeProfilePromptAnswers(const [], legacyBio: legacyBio),
    );
  }

  migrated.remove('bio');
  _migrateActivityPreferences(migrated);
  return migrated;
}

extension PublicProfilePhotos on PublicProfile {
  /// Tiny first-photo URL for avatar-scale UI. Falls back to the full photo
  /// until the backend thumbnail generation queue has backfilled old profiles.
  String? get primaryPhotoThumbnailUrl {
    final photo = effectiveProfilePhotos.firstOrNull;
    if (photo != null) {
      if (photo.thumbnailUrl.trim().isNotEmpty) return photo.thumbnailUrl;
      if (photo.url.trim().isNotEmpty) return photo.url;
    }
    return null;
  }

  List<ProfilePhoto> get effectiveProfilePhotos {
    return normalizeProfilePhotos(profilePhotos);
  }
}

extension PublicProfileRunPreferences on PublicProfile {
  RunningPreferences get runningPreferences => activityPreferences.running;
  int get paceMinSecsPerKm => runningPreferences.paceMinSecsPerKm;
  int get paceMaxSecsPerKm => runningPreferences.paceMaxSecsPerKm;
  List<PreferredDistance> get preferredDistances =>
      runningPreferences.preferredDistances;
  List<RunReason> get runningReasons => runningPreferences.runningReasons;
  List<PreferredRunTime> get preferredRunTimes =>
      runningPreferences.preferredRunTimes;
  int get runPreferencesVersion => runningPreferences.version;

  bool get hasCurrentRunPreferences {
    return runPreferencesVersion >= currentRunPreferencesVersion ||
        preferredDistances.isNotEmpty ||
        runningReasons.isNotEmpty ||
        preferredRunTimes.isNotEmpty ||
        paceMinSecsPerKm != defaultPaceMinSecsPerKm ||
        paceMaxSecsPerKm != defaultPaceMaxSecsPerKm;
  }
}

void _migrateActivityPreferences(Map<String, dynamic> migrated) {
  final activityPreferences = _stringKeyedMap(migrated['activityPreferences']);
  final running = _stringKeyedMap(activityPreferences['running']);

  running['paceMinSecsPerKm'] ??=
      migrated['paceMinSecsPerKm'] ?? defaultPaceMinSecsPerKm;
  running['paceMaxSecsPerKm'] ??=
      migrated['paceMaxSecsPerKm'] ?? defaultPaceMaxSecsPerKm;
  running['preferredDistances'] ??= migrated['preferredDistances'] ?? const [];
  running['runningReasons'] ??= migrated['runningReasons'] ?? const [];
  running['preferredRunTimes'] ??= migrated['preferredRunTimes'] ?? const [];
  running['version'] ??= migrated['runPreferencesVersion'] ?? 0;

  activityPreferences['running'] = running;
  migrated['activityPreferences'] = activityPreferences;
}

Map<String, dynamic> _stringKeyedMap(Object? value) {
  if (value is Map) {
    return value.map((key, child) => MapEntry(key.toString(), child));
  }
  return <String, dynamic>{};
}
