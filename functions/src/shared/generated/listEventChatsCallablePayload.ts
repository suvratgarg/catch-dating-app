/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ListEventChatsCallablePayload {
  cursor: {
    source: "memberships" | "participations" | "attendees";
    after: string | null;
    accountUid: string;
  } | null;
  limit: number;
}
