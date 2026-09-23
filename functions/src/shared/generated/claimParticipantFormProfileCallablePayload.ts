/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Claim reviewed form data for the authenticated participant without enabling dating discovery or event admission.
 */
export interface ClaimParticipantFormProfileCallablePayload {
  responseId: string;
  expectedProfileRevision: number;
  requestId: string;
  termsVersion: "form-profile-claim-v1";
  /**
   * @maxItems 100
   */
  selectedQuestionIds: string[];
  /**
   * Explicit participant-reviewed core values. Phone identity comes from verified Auth, never a form answer.
   */
  profile: {
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
  };
  expectedIntakeRevision: number;
  reviewedLinkedinUrl?: string;
}
