/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Explicit manager decision bound to an approved organizer-target native application and a reviewed membership revision.
 */
export type DecideOrganizerCommunityMembershipCallablePayload = {
  [k: string]: unknown;
} & {
  organizerId: string;
  uid: string;
  requestId: string;
  action: "grant" | "revoke";
  expectedRevision: number;
  applicationId: string | null;
  expectedApplicationRevision: number | null;
  reason: string;
};
