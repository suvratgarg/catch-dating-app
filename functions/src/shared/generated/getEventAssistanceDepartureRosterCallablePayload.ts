/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface GetEventAssistanceDepartureRosterCallablePayload {
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  groupId: string;
  /**
   * @maxItems 1000
   */
  attendeeIds: string[];
}
