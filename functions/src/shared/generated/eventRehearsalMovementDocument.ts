/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * An immutable synthetic departure manifest with a separately revised checkpoint observation.
 */
export interface EventRehearsalMovementDocument {
  sessionId: string;
  clockId: string;
  groupId: string;
  progressRevision: number;
  departure: {
    sourceHash: string;
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
    confirmedAt: number;
    confirmedBy: string;
    operationId: string;
    roster: {
      /**
       * @maxItems 50
       */
      members: {
        attendeeId: string;
        displayName: string;
        visitHash: string;
        episodeId: string | null;
        membershipHash: string | null;
      }[];
      selectionHash: string;
    } | null;
    checkpointRequest: {
      responsibleOperatorId: string;
      dueAt: number;
    } | null;
  };
  report: {
    revision: number;
    rosterHash: string;
    /**
     * @maxItems 50
     */
    accountedFor: string[];
    reportedAt: number;
    reportedBy: string;
    correctionReason: string | null;
  } | null;
}
