/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Participant-private reusable application values. This is neither a Catch dating profile nor organizer-visible CRM data.
 */
export interface ParticipantIntakeProfileDocument {
  /**
   * @maxItems 40
   */
  fields: {
    canonicalFieldId:
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
      | "children";
    value: {
      valueKind:
        | "empty"
        | "text"
        | "number"
        | "boolean"
        | "date"
        | "options"
        | "assets";
      textValue: string | null;
      numberValue: number | null;
      booleanValue: boolean | null;
      dateValue: string | null;
      /**
       * @maxItems 100
       */
      optionValues: string[];
      /**
       * @maxItems 10
       */
      assetIds: string[];
    };
    sourceApplicationId: string | null;
    /**
     * Serialized Firestore Timestamp fixture shape.
     */
    reviewedByParticipantAt: {
      _seconds: number;
      _nanoseconds: number;
    };
    /**
     * Serialized Firestore Timestamp fixture shape.
     */
    updatedAt: {
      _seconds: number;
      _nanoseconds: number;
    };
  }[];
  revision: number;
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
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
