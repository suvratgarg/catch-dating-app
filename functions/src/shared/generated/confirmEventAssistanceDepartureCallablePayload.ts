/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type ConfirmEventAssistanceDepartureCallablePayload = {
  command?: {
    context?: {
      mode?: "live";
      [k: string]: unknown;
    };
    [k: string]: unknown;
  };
  [k: string]: unknown;
} & {
  command: {
    kind: "confirmDeparture";
    context:
      | {
          mode: "live";
          eventId: string;
          organizerId: string;
        }
      | {
          mode: "rehearsal";
          rehearsalId: string;
          virtualEventId: string;
          clockId: string;
        };
    eventId: string;
    operationId: string;
    payload: {
      groupId: string;
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
      /**
       * Nonnegative safe integer revision.
       */
      expectedProgressRevision: number;
      departureRoster?: {
        /**
         * @maxItems 1000
         */
        attendeeIds: string[];
        expectedSourceHash: string;
      };
      checkpointRequest?: {
        responsibleOperatorId: string;
        dueAt: number;
      };
    };
  };
  expectedSourceHash: string;
};
