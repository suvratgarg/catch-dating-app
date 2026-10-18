import 'package:catch_dating_app/core/schema_contracts/generated/profile_requirements.g.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/user_profile/domain/profile_readiness.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';

extension EventProfileRequirements on Event {
  bool get requiresAgeDetails =>
      constraints.minAge > unrestrictedEventMinimumAge ||
      constraints.maxAge < openEndedEventMaximumAge;

  bool get requiresCohortDetails {
    final policy = effectiveEventPolicy;
    final admission = policy.admissionPolicy;
    return admission.balancedRatioPolicy != null ||
        {
          EventAdmissionFormat.balancedRatio,
          EventAdmissionFormat.fixedCohortCaps,
        }.contains(admission.format) ||
        admission.cohortCapacityLimits.isNotEmpty ||
        policy.pricingPolicy.cohortAdjustments.isNotEmpty ||
        policy.pricingPolicy.demandPricingRules.isNotEmpty;
  }

  bool hasRequiredProfileDetails(UserProfile user, DateTime now) =>
      user.hasBookingReadyIdentityOn(
        now,
        ageRestricted: requiresAgeDetails,
        cohortRestricted: requiresCohortDetails,
      );
}
