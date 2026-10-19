import {HttpsError} from "firebase-functions/v2/https";
import {computeAge} from "./dates";
import type {
  EventDocument,
  Gender,
  UserProfileDocument,
} from "./generated/firestoreAdminTypes";
import {
  eventAgePolicy,
  missingProfileFields,
  type EventProfileRequirement,
  type ProfileRequirementField,
} from "./generated/profileRequirements";
import {profilePromptLimits} from "./generated/catalogs/profilePromptLimits";
import {profilePhotoPolicy} from "./generated/catalogs/profilePhotoPolicy";
import {
  normalizeProfilePhotos,
  normalizeProfilePrompts,
} from "./profileProjection";

const knownGenders = new Set<Gender>(["man", "woman", "nonBinary", "other"]);

/** Account identity excludes age, photos and matching details. */
export function isAccountReadyUserProfile(
  user: Partial<UserProfileDocument>,
  capability: "account" | "organizerFollow" = "account"
): boolean {
  return (
    user.deleted !== true &&
    user.deletedAt == null &&
    missingProfileFields(capability, (field) => hasProfileField(user, field))
      .length === 0
  );
}

/** Age ranges retain the existing open-ended 0..99 event convention. */
export function eventAgeRange(event: Pick<EventDocument, "constraints">) {
  const minimum =
    event.constraints?.minAge ?? eventAgePolicy.unrestrictedMinimum;
  const maximum =
    event.constraints?.maxAge ?? eventAgePolicy.openEndedMaximum;
  return minimum > eventAgePolicy.unrestrictedMinimum ||
    maximum < eventAgePolicy.openEndedMaximum ?
    {minimum, maximum} :
    null;
}

export function eventProfileRequirements(
  event: EventDocument
): EventProfileRequirement[] {
  const requirements: EventProfileRequirement[] = [];
  if (eventAgeRange(event)) requirements.push("ageRestricted");
  const admission = event.eventPolicy?.admission;
  if (
    (event.eventPolicy?.pricing.demandPricingRules?.length ?? 0) > 0 ||
    admission?.balancedRatioPolicy ||
    ["balancedRatio", "fixedCohortCaps"].includes(admission?.format ?? "") ||
    Object.keys(admission?.cohortCapacityLimits ?? {}).length > 0 ||
    Object.keys(event.eventPolicy?.pricing.cohortAdjustmentsInPaise ?? {})
      .length > 0 ||
    event.constraints?.maxMen != null ||
    event.constraints?.maxWomen != null
  ) {
    requirements.push("cohortRestricted");
  }
  return requirements;
}

/** Presence requirements; event admission separately enforces age range. */
export function isBookingReadyUserProfile(
  user: UserProfileDocument,
  event?: EventDocument
): boolean {
  return (
    isAccountReadyUserProfile(user) &&
    missingProfileFields(
      "eventBooking",
      (field) => hasProfileField(user, field),
      event ? eventProfileRequirements(event) : []
    ).length === 0
  );
}

export function assertBookingReadyUserProfile(
  user: UserProfileDocument,
  event?: EventDocument
): void {
  if (isBookingReadyUserProfile(user, event)) return;
  throw new HttpsError(
    "failed-precondition",
    "Complete the details this event requires before signing up."
  );
}

/** Only social capabilities require adult age, photos and matching answers. */
export function isSocialReadyUserProfile(user: UserProfileDocument): boolean {
  return (
    isAccountReadyUserProfile(user) &&
    missingProfileFields("socialDiscovery", (field) =>
      hasProfileField(user, field)
    ).length === 0 &&
    computeAge(user.dateOfBirth!.toDate()) >= 18
  );
}

function hasProfileField(
  user: Partial<UserProfileDocument>,
  field: ProfileRequirementField
): boolean {
  switch (field) {
  case "name":
    return (
      hasText(user.name) ||
        hasText(user.firstName) ||
        hasText(user.displayName)
    );
  case "phoneNumber":
    return hasText(user.phoneNumber);
  case "dateOfBirth": {
    const date =
        typeof user.dateOfBirth?.toDate === "function" ?
          user.dateOfBirth.toDate() :
          undefined;
    return (
      !!date && Number.isFinite(date.getTime()) && computeAge(date) >= 0
    );
  }
  case "gender":
    return user.gender != null && knownGenders.has(user.gender);
  case "interestedInGenders":
    return (user.interestedInGenders?.length ?? 0) > 0;
  case "profilePhotos":
    return (
      normalizeProfilePhotos(user as UserProfileDocument).length >=
        profilePhotoPolicy.minPhotos
    );
  case "profilePrompts":
    return (
      new Set(
        normalizeProfilePrompts(user as UserProfileDocument).map(
          (prompt) => prompt.promptId
        )
      ).size >= profilePromptLimits.maxAnswers
    );
  case "profileComplete":
    return user.profileComplete === true;
  }
}

function hasText(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}
