/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Participant-private runtime identity stored at eventRuntimeParticipants/{eventId_uid}.
 */
export interface EventRuntimeParticipantDocument {
  eventId: string;
  clubId: string;
  organizerId: string;
  uid: string;
  eventAttendeeId: string | null;
  identityVersion: 1;
  claimMethod:
    | "verifiedPhone"
    | "signedAttendeeToken"
    | "verifiedEmail"
    | "hostApproval"
    | "catchParticipation";
  accessStatus:
    | "pendingApproval"
    | "needsInput"
    | "ready"
    | "optedOut"
    | "revoked";
  /**
   * @maxItems 5
   */
  requiredFieldIds: (
    | "displayName"
    | "gender"
    | "interestedInGenders"
    | "relationshipGoal"
    | "dateOfBirth"
  )[];
  /**
   * @maxItems 5
   */
  completedFieldIds: (
    | "displayName"
    | "gender"
    | "interestedInGenders"
    | "relationshipGoal"
    | "dateOfBirth"
  )[];
  runtimeProfile: {
    displayName: string;
    gender: ("man" | "woman" | "nonBinary" | "other") | null;
    /**
     * @maxItems 4
     */
    interestedInGenders: ("man" | "woman" | "nonBinary" | "other")[];
    relationshipGoal:
      | "relationship"
      | "casual"
      | "marriage"
      | "friendship"
      | "unsure"
      | null;
    dateOfBirth: {
      _seconds: number;
      _nanoseconds: number;
    } | null;
  };
  consents: {
    runtimeTermsVersion: string;
    sensitiveDataTermsVersion: string | null;
    saveAsCatchPrefill: boolean;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  claimedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  readyAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  revokedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
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
