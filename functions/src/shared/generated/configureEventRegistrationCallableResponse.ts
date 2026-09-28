/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ConfigureEventRegistrationCallableResponse {
  eventId: string;
  registrationRevision: number;
  mode: "closed" | "free" | "paid";
  replayed: boolean;
}
