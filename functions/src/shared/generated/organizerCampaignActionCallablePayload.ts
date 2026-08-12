/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Revision-bound campaign preview, approval, dispatch, cancellation or report request.
 */
export interface OrganizerCampaignActionCallablePayload {
  organizerId: string;
  campaignId: string;
  expectedRevision?: number | null;
}
