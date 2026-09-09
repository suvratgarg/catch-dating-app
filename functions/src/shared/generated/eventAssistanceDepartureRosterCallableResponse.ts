/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceDepartureRosterCallableResponse {
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  groupId: string;
  serverTime: number;
  progressRevision: number;
  selection: {
    /**
     * @maxItems 1000
     */
    attendeeIds: string[];
    expectedSourceHash: string;
  };
}
