/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-only, evidence-bearing duplicate candidates. No candidate is produced from a name match alone.
 */
export interface ListOrganizerContactMergeCandidatesCallableResponse {
  organizerId: string;
  /**
   * @maxItems 50
   */
  candidates: {
    candidateId: string;
    /**
     * @minItems 2
     * @maxItems 2
     */
    contacts: {
      contactId: string;
      displayName: string;
      phoneE164: string | null;
      email: string | null;
      linkedAccount: boolean;
      primarySource:
        | "catchBooking"
        | "hostImport"
        | "hostManual"
        | "webOtp"
        | "providerSync"
        | "hostForm";
      revision: number;
    }[];
    /**
     * @minItems 1
     * @maxItems 4
     */
    matchKinds: (
      | "sameVerifiedUid"
      | "sameVerifiedPhone"
      | "sameImportedPhone"
      | "sameEmail"
    )[];
    confidence: "verified" | "proposed";
    /**
     * @minItems 1
     * @maxItems 6
     */
    sourceKinds: (
      | "catchBooking"
      | "hostImport"
      | "hostManual"
      | "webOtp"
      | "providerSync"
      | "hostForm"
    )[];
    /**
     * @maxItems 20
     */
    sharedEventIds: string[];
    sharedEventCount: number;
    updatedAtMillis: number;
    decisionState: "none" | "differentPeople" | "reopened";
    decisionRevision: number | null;
    canReopen: boolean;
  }[];
  /**
   * @maxItems 50
   */
  dismissedCandidates: {
    candidateId: string;
    /**
     * @minItems 2
     * @maxItems 2
     */
    contacts: {
      contactId: string;
      displayName: string;
      phoneE164: string | null;
      email: string | null;
      linkedAccount: boolean;
      primarySource:
        | "catchBooking"
        | "hostImport"
        | "hostManual"
        | "webOtp"
        | "providerSync"
        | "hostForm";
      revision: number;
    }[];
    /**
     * @minItems 1
     * @maxItems 4
     */
    matchKinds: (
      | "sameVerifiedUid"
      | "sameVerifiedPhone"
      | "sameImportedPhone"
      | "sameEmail"
    )[];
    confidence: "verified" | "proposed";
    /**
     * @minItems 1
     * @maxItems 6
     */
    sourceKinds: (
      | "catchBooking"
      | "hostImport"
      | "hostManual"
      | "webOtp"
      | "providerSync"
      | "hostForm"
    )[];
    /**
     * @maxItems 20
     */
    sharedEventIds: string[];
    sharedEventCount: number;
    updatedAtMillis: number;
    decisionState: "none" | "differentPeople" | "reopened";
    decisionRevision: number | null;
    canReopen: boolean;
  }[];
  nextCursor: string | null;
  truncated: boolean;
}
