/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by sendEventBroadcast.
 */
export interface SendEventBroadcastCallablePayload {
  requestId: string;
  eventId: string;
  audience: "booked" | "prospective" | "everyone";
  body: string;
}
