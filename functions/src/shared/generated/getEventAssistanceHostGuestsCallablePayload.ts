/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface GetEventAssistanceHostGuestsCallablePayload {
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  /**
   * @minItems 1
   * @maxItems 50
   */
  attendeeIds: string[];
}
