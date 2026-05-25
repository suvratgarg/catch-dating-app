/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by decideEventJoinRequest.
 */
export interface EventJoinRequestDecisionCallablePayload {
  eventId: string;
  userId: string;
  decision: "approve" | "decline";
}
