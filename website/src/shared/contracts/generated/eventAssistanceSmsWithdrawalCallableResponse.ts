/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceSmsWithdrawalCallableResponse {
  outcome: "read" | "applied" | "replayed" | "conflict";
  view: {
    serverTime: number;
    revision: number;
    preference: "enabled" | "disabled" | "expired";
    expiresAt: number;
  };
}
