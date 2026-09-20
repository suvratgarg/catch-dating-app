/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ListEventAssistanceCasesCallablePayload {
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  status: "open" | "resolved";
  cursor: string | null;
}
