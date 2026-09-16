/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * An immutable synthetic route override layered on a recorded rehearsal departure.
 */
export interface EventRehearsalRouteDecisionDocument {
  sessionId: string;
  clockId: string;
  groupId: string;
  progressRevision: number;
  previousRevision: number;
  departureRevision: number;
  sourceHash: string;
  alternativeId: string;
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
  decisionId: string;
  operationId: string;
  decidedBy: string;
  decidedAt: number;
}
