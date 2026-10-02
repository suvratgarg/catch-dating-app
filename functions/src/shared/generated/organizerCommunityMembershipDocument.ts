/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Current manager-controlled organizer community entitlement. Following, contact linkage, booking and attendance are separate.
 */
export interface OrganizerCommunityMembershipDocument {
  schemaVersion: 1;
  organizerId: string;
  uid: string;
  state: "active" | "revoked";
  revision: number;
  source: {
    applicationId: string;
    responseId: string;
    formVersionId: string;
    applicationRevision: number;
  };
  lastDecisionId: string;
  activatedAtMillis: number;
  updatedAtMillis: number;
}
