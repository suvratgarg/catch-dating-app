/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceAccountabilityCallableResponse {
  outcome: "read" | "applied" | "replayed";
  operationRevision: number | null;
  view: {
    context: {
      mode: "live";
      eventId: string;
      organizerId: string;
    };
    groupId: string;
    attendeeId: string;
    serverTime: number;
    sourceHash: string;
    revision: number;
    episodeId: string | null;
    disposition: "returned" | "departed" | "unresolved";
    availability:
      | {
          kind: "ready";
        }
      | {
          kind: "unavailable";
          reason: "notApplicable" | "notCheckedIn";
        };
  };
}
