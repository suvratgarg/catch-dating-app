/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface GetEventAssistanceAccountabilityCallablePayload {
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  groupId: string;
  attendeeId: string;
  /**
   * An explicitly recorded departure at a named checkpoint; it never infers a roster or changes event-wide sweep configuration.
   */
  checkpoint?: {
    checkpointId: string;
    progressRevision: number;
  };
}
