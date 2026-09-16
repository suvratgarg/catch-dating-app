/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceDepartureRostersCallableResponse {
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  groupId: string;
  actorUid: string;
  validUntil: number;
  serverTime: number;
  progressRevision: number;
  coverage: "page";
  /**
   * @maxItems 10
   */
  rosters: {
    progressRevision: number;
    confirmedAt: number;
    destination:
      | (
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
            }
        )
      | null;
    label: string | null;
    sourceState: "current" | "setupChanged" | "destinationNotRecorded";
    rosterSize: number;
    checkpoint: {
      checkpointId: string;
      reportStatus: "unreported" | "partial" | "complete";
      reportRevision: number;
      accountedForCount: number;
      originalRequestedDueAt: number | null;
    } | null;
  }[];
  nextBeforeRevision: number | null;
}
