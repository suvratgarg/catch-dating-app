/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private pointers to explicitly designated applicant-submitted profile and organizer-card answers. Submission prepares a proposal, never a claimed or public profile.
 */
export interface ParticipantFormProfileProposalDocument {
  uid: string;
  organizerId: string;
  formId: string;
  versionId: string;
  responseId: string;
  /**
   * @minItems 1
   * @maxItems 100
   */
  fields: {
    questionId: string;
    destination: "catchProfile" | "organizerCard";
    canonicalFieldId:
      | (
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
        )
      | null;
  }[];
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  claimedAt?: {
    _seconds: number;
    _nanoseconds: number;
  };
}
