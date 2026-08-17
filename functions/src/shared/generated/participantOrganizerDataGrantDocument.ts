/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Append-stable consent receipt granting one organizer access to exact submitted fields for one application. Only revokedAt may transition after creation.
 */
export interface ParticipantOrganizerDataGrantDocument {
  participantUid: string;
  organizerId: string;
  applicationId: string;
  responseId: string;
  formVersionId: string;
  purpose: "organizerApplicationReview";
  /**
   * @minItems 1
   * @maxItems 100
   */
  grantedQuestionIds: string[];
  /**
   * @maxItems 40
   */
  grantedCanonicalFieldIds: (
    | "givenName"
    | "familyName"
    | "displayName"
    | "dateOfBirth"
    | "age"
    | "gender"
    | "phoneNumber"
    | "email"
    | "instagramHandle"
    | "linkedinUrl"
    | "profilePhoto"
    | "city"
    | "heightCm"
    | "occupation"
    | "company"
    | "education"
    | "languages"
    | "relationshipGoal"
    | "interestedInGenders"
    | "drinking"
    | "smoking"
    | "religion"
    | "workout"
    | "diet"
    | "children"
  )[];
  consentVersion: string;
  consentCopyHash: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  grantedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  revokedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
