/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ReviewOrganizerContactMergeCandidateCallablePayload {
  organizerId: string;
  candidateId: string;
  /**
   * @minItems 2
   * @maxItems 2
   */
  contactIds: string[];
  decision: "differentPeople" | "reopen";
  expectedRevision: number | null;
}
