import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';

/// Typed patch payload for `updateUserProfile`. Replaces the prior
/// `Map<String, dynamic> fields` API with named, type-checked optional fields.
///
/// Mirrors `contracts/patches/update_user_profile.schema.json` —
/// every schema field is a nullable named parameter. `toJson` includes only
/// the fields that were explicitly set, converts `DateTime` → millis, and
/// expands embedded objects via their own `toJson()`.
///
/// Parity between this class and the schema is asserted by
/// `test/core/update_user_profile_patch_test.dart`.
///
/// For dynamic-field callers (e.g. an enum mapping multiple toggles to a
/// single setter), use [UpdateUserProfilePatch.raw]; the schema-conformance
/// test still validates the raw key set.
final class UpdateUserProfilePatch {
  UpdateUserProfilePatch({
    String? name,
    String? displayName,
    String? email,
    Object? instagramHandle = _unset,
    List<ProfilePromptAnswer>? profilePrompts,
    String? phoneNumber,
    DateTime? dateOfBirth,
    Gender? gender,
    bool? profileComplete,
    List<String>? photoUrls,
    List<String>? photoThumbnailUrls,
    List<PhotoPromptAnswer>? photoPrompts,
    List<ProfilePhoto>? profilePhotos,
    Object? city = _unset,
    Object? latitude = _unset,
    Object? longitude = _unset,
    List<Gender>? interestedInGenders,
    int? minAgePreference,
    int? maxAgePreference,
    int? height,
    String? occupation,
    String? company,
    EducationLevel? education,
    Religion? religion,
    List<Language>? languages,
    RelationshipGoal? relationshipGoal,
    DrinkingHabit? drinking,
    SmokingHabit? smoking,
    WorkoutFrequency? workout,
    DietaryPreference? diet,
    ChildrenStatus? children,
    int? paceMinSecsPerKm,
    int? paceMaxSecsPerKm,
    List<PreferredDistance>? preferredDistances,
    List<RunReason>? runningReasons,
    List<PreferredRunTime>? preferredRunTimes,
    int? runPreferencesVersion,
    bool? prefsNewCatches,
    bool? prefsMessages,
    bool? prefsEventReminders,
    bool? prefsRunStatusUpdates,
    bool? prefsClubUpdates,
    bool? prefsWeeklyDigest,
    bool? prefsShowOnMap,
  }) : _fields = {
         if (name != null) 'name': name,
         if (displayName != null) 'displayName': displayName,
         if (email != null) 'email': email,
         if (!identical(instagramHandle, _unset))
           'instagramHandle': instagramHandle,
         if (profilePrompts != null)
           'profilePrompts': profilePrompts.map((e) => e.toJson()).toList(),
         if (phoneNumber != null) 'phoneNumber': phoneNumber,
         if (dateOfBirth != null)
           'dateOfBirth': dateOfBirth.millisecondsSinceEpoch,
         if (gender != null) 'gender': gender.name,
         if (profileComplete != null) 'profileComplete': profileComplete,
         if (photoUrls != null) 'photoUrls': photoUrls,
         if (photoThumbnailUrls != null)
           'photoThumbnailUrls': photoThumbnailUrls,
         if (photoPrompts != null)
           'photoPrompts': photoPrompts.map((e) => e.toJson()).toList(),
         if (profilePhotos != null)
           'profilePhotos': profilePhotos.map((e) => e.toJson()).toList(),
         if (!identical(city, _unset)) 'city': city,
         if (!identical(latitude, _unset)) 'latitude': latitude,
         if (!identical(longitude, _unset)) 'longitude': longitude,
         if (interestedInGenders != null)
           'interestedInGenders': interestedInGenders.map((e) => e.name).toList(),
         if (minAgePreference != null) 'minAgePreference': minAgePreference,
         if (maxAgePreference != null) 'maxAgePreference': maxAgePreference,
         if (height != null) 'height': height,
         if (occupation != null) 'occupation': occupation,
         if (company != null) 'company': company,
         if (education != null) 'education': education.name,
         if (religion != null) 'religion': religion.name,
         if (languages != null)
           'languages': languages.map((e) => e.name).toList(),
         if (relationshipGoal != null) 'relationshipGoal': relationshipGoal.name,
         if (drinking != null) 'drinking': drinking.name,
         if (smoking != null) 'smoking': smoking.name,
         if (workout != null) 'workout': workout.name,
         if (diet != null) 'diet': diet.name,
         if (children != null) 'children': children.name,
         if (paceMinSecsPerKm != null) 'paceMinSecsPerKm': paceMinSecsPerKm,
         if (paceMaxSecsPerKm != null) 'paceMaxSecsPerKm': paceMaxSecsPerKm,
         if (preferredDistances != null)
           'preferredDistances': preferredDistances.map((e) => e.name).toList(),
         if (runningReasons != null)
           'runningReasons': runningReasons.map((e) => e.name).toList(),
         if (preferredRunTimes != null)
           'preferredRunTimes': preferredRunTimes.map((e) => e.name).toList(),
         if (runPreferencesVersion != null)
           'runPreferencesVersion': runPreferencesVersion,
         if (prefsNewCatches != null) 'prefsNewCatches': prefsNewCatches,
         if (prefsMessages != null) 'prefsMessages': prefsMessages,
         if (prefsEventReminders != null)
           'prefsEventReminders': prefsEventReminders,
         if (prefsRunStatusUpdates != null)
           'prefsRunStatusUpdates': prefsRunStatusUpdates,
         if (prefsClubUpdates != null) 'prefsClubUpdates': prefsClubUpdates,
         if (prefsWeeklyDigest != null) 'prefsWeeklyDigest': prefsWeeklyDigest,
         if (prefsShowOnMap != null) 'prefsShowOnMap': prefsShowOnMap,
       };

  /// Escape hatch for callers that compute the field key dynamically
  /// (e.g. `SettingsPreference` enum → one of several boolean flags).
  /// The keys are still validated against the schema by the parity test;
  /// unknown keys will be caught there or by the Functions Ajv validator.
  UpdateUserProfilePatch.raw(Map<String, Object?> fields)
    : _fields = Map<String, Object?>.from(fields);

  final Map<String, Object?> _fields;

  /// The set of field keys this patch will write.
  Iterable<String> get keys => _fields.keys;

  bool get isEmpty => _fields.isEmpty;
  bool get isNotEmpty => _fields.isNotEmpty;

  Map<String, Object?> toFieldsJson() => Map<String, Object?>.unmodifiable(_fields);
}

/// Sentinel that lets us distinguish "omitted from the patch" from
/// "explicitly set to null" for nullable fields like `instagramHandle`,
/// `city`, `latitude`, `longitude`.
const Object _unset = Object();
