/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface CreateOrganizerFormAssetIntentCallableResponse {
  assetId: string;
  uploadToken: string;
  uploadUrl: string;
  uploadFields: {
    [k: string]: string;
  };
  expiresAtMillis: number;
}
