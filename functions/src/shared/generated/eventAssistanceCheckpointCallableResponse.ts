/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceCheckpointCallableResponse {
  outcome: "read" | "applied" | "replayed";
  operationRevision: number | null;
  view: {
    context: {
      mode: "live";
      eventId: string;
      organizerId: string;
    };
    groupId: string;
    checkpointId: string;
    progressRevision: number;
    serverTime: number;
    sourceHash: string;
    revision: number;
    report: {
      schemaVersion: 1;
      reportId: string;
      context: {
        mode: "live";
        eventId: string;
        organizerId: string;
      };
      groupId: string;
      checkpointId: string;
      progressRevision: number;
      rosterId: string;
      rosterHash: string;
      revision: number;
      /**
       * @maxItems 1000
       */
      accountedFor: string[];
      reportedBy: string;
      reportedAt: number;
      correctionReason: string | null;
      createdAt: number;
    } | null;
    availability:
      | {
          kind: "ready";
          rosterId: string;
          label: string;
          reportStatus: "unreported" | "partial" | "complete";
          /**
           * @maxItems 1000
           */
          members: {
            attendeeId: string;
            observation: "accountedFor" | "unconfirmed";
            visit:
              | {
                  kind: "current";
                }
              | {
                  kind: "unavailable";
                  reason:
                    | "registrationMissing"
                    | "visitChanged"
                    | "notCheckedIn"
                    | "invalidSource";
                };
          }[];
        }
      | {
          kind: "unavailable";
          reason:
            | "rosterNotRecorded"
            | "destinationNotRecorded"
            | "differentCheckpoint"
            | "notCheckpoint"
            | "setupChanged";
        };
  };
}
