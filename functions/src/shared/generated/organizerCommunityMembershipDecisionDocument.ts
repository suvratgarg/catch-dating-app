/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable exact-request membership decision; replay never restores an older current entitlement.
 */
export interface OrganizerCommunityMembershipDecisionDocument {
  schemaVersion: 1;
  organizerId: string;
  uid: string;
  membershipId: string;
  requestId: string;
  requestHash: string;
  actorUid: string;
  action: "grant" | "revoke";
  reason: string;
  previousState: "none" | "active" | "revoked";
  expectedRevision: number;
  resultingRevision: number;
  source: {
    applicationId: string;
    responseId: string;
    formVersionId: string;
    applicationRevision: number;
  };
  decidedAtMillis: number;
}
