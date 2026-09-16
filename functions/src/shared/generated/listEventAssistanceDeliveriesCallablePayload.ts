/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ListEventAssistanceDeliveriesCallablePayload {
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  cursor: string | null;
}
