/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceGroupProgressDocument {
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
  departureRosterId?: string;
}
