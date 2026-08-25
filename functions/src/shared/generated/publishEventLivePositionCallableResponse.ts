/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface PublishEventLivePositionCallableResponse {
  sharing: boolean;
  role: "host" | "operator";
  serverTimeMillis: number;
  staleAfterSeconds: number;
  expiresAtMillis: number | null;
}
