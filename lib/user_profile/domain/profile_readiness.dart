import 'package:catch_dating_app/user_profile/domain/profile_photo_policy.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';

extension UserProfileReadiness on UserProfile {
  bool get hasBookingReadyIdentity {
    return hasBookingReadyName &&
        validateRequiredDateOfBirth(dateOfBirth) == null &&
        validateRequiredPhoneNumber(phoneNumber) == null &&
        interestedInGenders.isNotEmpty;
  }

  bool get hasBookingReadyName {
    return name.trim().isNotEmpty ||
        firstName.trim().isNotEmpty ||
        displayName.trim().isNotEmpty;
  }

  bool get hasSocialReadyProfile {
    return hasBookingReadyIdentity &&
        profileComplete &&
        hasMinimumSocialPhotos &&
        hasRequiredProfilePrompts;
  }

  bool get hasCurrentRunPreferences {
    return runPreferencesVersion >= currentRunPreferencesVersion ||
        hasLegacyRunPreferenceSelections;
  }

  bool get hasLegacyRunPreferenceSelections {
    return preferredDistances.isNotEmpty ||
        runningReasons.isNotEmpty ||
        preferredRunTimes.isNotEmpty ||
        paceMinSecsPerKm != defaultPaceMinSecsPerKm ||
        paceMaxSecsPerKm != defaultPaceMaxSecsPerKm;
  }

  bool get hasMinimumSocialPhotos =>
      effectiveProfilePhotos.length >= minimumProfilePhotoCount;

  bool get hasRequiredProfilePrompts {
    final answeredPromptIds = normalizeProfilePromptAnswers(
      profilePrompts,
    ).map((answer) => answer.promptId).toSet();
    return defaultProfilePromptIds.every(answeredPromptIds.contains);
  }
}
