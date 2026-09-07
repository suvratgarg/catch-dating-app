/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceGroupProgressCallableResponse {
  outcome: "read" | "applied" | "replayed";
  view: {
    context: {
      mode: "live";
      eventId: string;
      organizerId: string;
    };
    groupId: string;
    serverTime: number;
    revision: number;
    sourceHash: string;
    eventOpen: boolean;
    runtimeLive: boolean;
    freshness: "unconfirmed" | "current" | "sourceChanged";
    progress: {
      schemaVersion: 1;
      progressId: string;
      context: {
        mode: "live";
        eventId: string;
        organizerId: string;
      };
      groupId: string;
      revision: number;
      destination:
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
      sourceHash: string;
      confirmedBy: string;
      confirmedAt: number;
      operationId: string;
      requestHash: string;
      createdAt: number;
      updatedAt: number;
    } | null;
    guidance: {
      /**
       * Nonnegative safe integer revision.
       */
      revision: number;
      destination:
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
      materialKey: string;
      text: string;
      /**
       * UTC milliseconds.
       */
      validUntil: number;
    } | null;
    /**
     * @maxItems 41
     */
    destinations: {
      target:
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
      label: string;
      /**
       * Canonical meeting location selected from Google Places or a manually pinned map coordinate.
       */
      location: {
        name: string;
        address?: string | null;
        placeId?: string | null;
        latitude: number;
        longitude: number;
        notes?: string | null;
      };
    }[];
  };
  operationRevision: number | null;
}
