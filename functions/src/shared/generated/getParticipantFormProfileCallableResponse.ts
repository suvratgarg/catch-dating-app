/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Participant-only form review, with an optimistic profile revision and no unrelated CRM data.
 */
export interface GetParticipantFormProfileCallableResponse {
  responseId: string;
  organizerId: string;
  formId: string;
  formTitle: string;
  submittedAtMillis: number;
  /**
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
    label: string;
    kind:
      | "shortText"
      | "longText"
      | "singleChoice"
      | "multiChoice"
      | "date"
      | "phone"
      | "email"
      | "url"
      | "number"
      | "boolean"
      | "file"
      | "acknowledgement"
      | "signature";
    value: string | number | boolean | null | string[];
    /**
     * @maxItems 100
     */
    options: {
      optionId: string;
      label: string;
      value: string;
    }[];
  }[];
  profileRevision: number;
  termsVersion: "form-profile-claim-v1";
  intakeRevision: number;
  organizerName: string | null;
  /**
   * @maxItems 100
   */
  selectedCardQuestionIds: string[];
  claimedAtMillis: number | null;
  currentProfile: {
    name?: string;
    firstName?: string;
    lastName?: string;
    displayName: string;
    gender: "man" | "woman" | "nonBinary" | "other";
    email?: "" | string;
    instagramHandle?: string | null;
    city?: string | null;
    height?: number | null;
    occupation?: string | null;
    company?: string | null;
    education?:
      | "highSchool"
      | "someCollege"
      | "bachelors"
      | "masters"
      | "phd"
      | "tradeSchool"
      | "other"
      | null;
    religion?:
      | "hindu"
      | "muslim"
      | "christian"
      | "sikh"
      | "jain"
      | "buddhist"
      | "other"
      | "nonReligious"
      | null;
    /**
     * @maxItems 20
     */
    languages?: (
      | "english"
      | "hindi"
      | "marathi"
      | "tamil"
      | "telugu"
      | "kannada"
      | "bengali"
      | "gujarati"
      | "punjabi"
      | "malayalam"
      | "odia"
      | "other"
    )[];
    relationshipGoal?:
      | "relationship"
      | "casual"
      | "marriage"
      | "friendship"
      | "unsure"
      | null;
    drinking?: "never" | "socially" | "often" | null;
    smoking?: "never" | "occasionally" | "often" | null;
    workout?: "never" | "sometimes" | "often" | "everyday" | null;
    diet?: "omnivore" | "vegetarian" | "vegan" | "jain" | "other" | null;
    children?:
      | "dontHave"
      | "haveWantMore"
      | "haveNoMore"
      | "wantSomeday"
      | "dontWant"
      | null;
    dateOfBirth: string;
    /**
     * @minItems 0
     * @maxItems 8
     */
    interestedInGenders?: ("man" | "woman" | "nonBinary" | "other")[];
  } | null;
  currentLinkedinUrl: string | null;
  cardRevision: number;
}
