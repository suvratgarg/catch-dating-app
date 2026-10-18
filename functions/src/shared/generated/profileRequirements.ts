// GENERATED from contracts/catalogs/profile_requirements.json. Do not edit.

export const profileRequiredFields = {
  "account": [
    "name",
    "phoneNumber"
  ],
  "organizerFollow": [
    "name",
    "phoneNumber"
  ],
  "eventBooking": [
    "name",
    "phoneNumber"
  ],
  "socialDiscovery": [
    "name",
    "phoneNumber",
    "dateOfBirth",
    "gender",
    "interestedInGenders",
    "profilePhotos",
    "profilePrompts",
    "profileComplete"
  ]
} as const;
export const eventProfileRequirements = {
  "ageRestricted": [
    "dateOfBirth"
  ],
  "cohortRestricted": [
    "gender",
    "interestedInGenders"
  ]
} as const;
export const optionalAccountFields = [
  "dateOfBirth"
] as const;
export const eventAgePolicy = {
  "unrestrictedMinimum": 0,
  "openEndedMaximum": 99
} as const;
export type ProfileCapability = keyof typeof profileRequiredFields;
export type EventProfileRequirement = keyof typeof eventProfileRequirements;
export type ProfileRequirementField =
  (typeof profileRequiredFields)[ProfileCapability][number];

export function missingProfileFields(
  capability: ProfileCapability,
  hasField: (field: ProfileRequirementField) => boolean,
  eventRequirements: readonly EventProfileRequirement[] = [],
): ProfileRequirementField[] {
  const fields = new Set<ProfileRequirementField>(profileRequiredFields[capability]);
  if (capability === "eventBooking") {
    for (const requirement of eventRequirements) {
      for (const field of eventProfileRequirements[requirement]) fields.add(field);
    }
  }
  return [...fields].filter((field) => !hasField(field));
}
