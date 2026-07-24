/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminCreateOrganizerDraftFromCandidateCallableResponse {
  organizerId: string;
  organizerPath: string;
  curationPath: string;
  created: boolean;
  appVisibility: "hidden";
  ownershipState: "programmatic";
  claimState: "unclaimed";
  publishStatus: "draft";
  indexStatus: "noindex";
  crawlStatus: "disabled";
}
