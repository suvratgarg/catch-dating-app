/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ConfigureEventRegistrationCallablePayload {
  organizerId: string;
  eventId: string;
  requestId: string;
  expectedRegistrationRevision: number;
  mode: "closed" | "free" | "paid";
}
