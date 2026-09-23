/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-visible hostname state without a certificate operation or private form data.
 */
export interface ManageOrganizerFormDomainCallableResponse {
  hostname: string;
  status: "pending" | "verified" | "revoked";
  ownershipChallenge?: string;
  expectedCname?: string;
}
