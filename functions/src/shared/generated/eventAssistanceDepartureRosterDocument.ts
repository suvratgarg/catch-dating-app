/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceDepartureRosterDocument {
  schemaVersion: 1;
  rosterId: string;
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  groupId: string;
  progressId: string;
  progressRevision: number;
  sourceHash: string;
  confirmedBy: string;
  confirmedAt: number;
  /**
   * @maxItems 1000
   */
  members: {
    attendeeId: string;
    sourceGeneration: string;
    attendeeGeneration: string;
    checkInHash: string;
    episodeId: string | null;
    membershipHash: string | null;
  }[];
  destination?:
    | {
        kind: "fixedPlace";
        placeId: string;
        lateEntry: "allowed" | "hostDecision" | "closed";
      }
    | {
        kind: "itineraryStop";
        itineraryId: string;
        stopId: string;
      }
    | {
        kind: "groupCheckpoint";
        routeId: string;
        groupId: string;
        checkpointId: string;
      };
  checkpointRequest?: {
    responsibleOperatorId: string;
    dueAt: number;
  };
}
