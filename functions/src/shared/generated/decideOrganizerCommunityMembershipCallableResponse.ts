/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Sanitized decision result and current entitlement; an exact replay may refer to an older decision revision.
 */
export interface DecideOrganizerCommunityMembershipCallableResponse {
  membershipId: string;
  decisionId: string;
  decisionRevision: number;
  currentRevision: number;
  currentState: "active" | "revoked";
  replayed: boolean;
}
