/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type ReassignEventAssistanceCheckpointReporterCallablePayload = {
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
    kind: "reassignCheckpointReporter";
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
      checkpointId: string;
      /**
       * Nonnegative safe integer revision.
       */
      expectedProgressRevision: number;
      expectedAssignmentRevision: number;
      responsibleOperatorId: string;
      reason: string;
    };
  };
  expectedSourceHash: string;
};
