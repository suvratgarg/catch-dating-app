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
    return runningPreferences.hasCurrentRunPreferences;
  }

  bool get hasLegacyRunPreferenceSelections {
    return runningPreferences.hasLegacyRunPreferenceSelections;
  }

  bool get hasMinimumSocialPhotos =>
      effectiveProfilePhotos.length >= minimumProfilePhotoCount;

  bool get hasRequiredProfilePrompts {
    final answeredPromptIds = normalizeProfilePromptAnswers(
      profilePrompts,
    ).map((answer) => answer.promptId).toSet();
    // The prompts UI lets users freely swap any default slot for another
    // catalog prompt, so readiness requires N distinct answered prompts rather
    // than the specific default ids — otherwise choosing a non-default prompt
    // soft-locks profile completion (the router redirect never resolves).
    return answeredPromptIds.length >= maxProfilePromptAnswers;
  }
}

extension RunningPreferencesReadiness on RunningPreferences {
  bool get hasCurrentRunPreferences {
    return version >= currentRunPreferencesVersion ||
        hasLegacyRunPreferenceSelections;
  }

  bool get hasLegacyRunPreferenceSelections {
    return preferredDistances.isNotEmpty ||
        runningReasons.isNotEmpty ||
        preferredRunTimes.isNotEmpty ||
        paceMinSecsPerKm != defaultPaceMinSecsPerKm ||
        paceMaxSecsPerKm != defaultPaceMaxSecsPerKm;
  }
}
