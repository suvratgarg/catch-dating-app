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
            /**
             * Visit-bound event accountability evidence. A resolved disposition never means arrival at this checkpoint.
             */
            disposition?:
              | {
                  kind: "unresolved";
                }
              | {
                  kind: "resolved";
                  disposition: "returned" | "departed";
                  revision: number;
                  resolvedAt: number;
                  resolvedBy: string;
                  sourceHash: string;
                }
              | {
                  kind: "unavailable";
                  reason:
                    | "registrationMissing"
                    | "visitChanged"
                    | "notCheckedIn"
                    | "invalidSource"
                    | "beforeDeparture";
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
    request:
      | (
          | {
              responsibleOperatorId: string;
              dueAt: number;
              state:
                | "awaitingReport"
                | "overdue"
                | "discrepancy"
                | "sourceUnavailable";
              ownerAvailability: "current" | "needsReassignment";
            }
          | {
              responsibleOperatorId: string;
              dueAt: number;
              state: "complete" | "closedOut";
              ownerAvailability: "notRequired";
            }
        )
      | null;
    /**
     * Present in current responses; null when no durable checkpoint request exists. Independent of the report revision.
     */
    assignment?: {
      revision: number;
      sourceHash: string;
      change: {
        revision: number;
        receiptId: string;
        responsibleOperatorId: string;
        previousResponsibleOperatorId: string;
        assignedBy: string;
        assignedAt: number;
        reason: string;
      } | null;
    } | null;
    closeout?: {
      revision: number;
      sourceHash: string;
      change: {
        revision: number;
        previousRevision: number;
        receiptId: string;
        changedBy: string;
        changedAt: number;
        reason: string;
        decision:
          | {
              kind: "close";
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
              };
              /**
               * @maxItems 1000
               */
              dispositions: {
                kind: "resolved";
                disposition: "returned" | "departed";
                revision: number;
                resolvedAt: number;
                resolvedBy: string;
                sourceHash: string;
                attendeeId: string;
              }[];
            }
          | {
              kind: "reopen";
            };
      } | null;
      state:
        | {
            kind: "open" | "reopened" | "closedOut" | "superseded";
          }
        | {
            kind: "needsReview";
            reason:
              | "sourceUnavailable"
              | "reportChanged"
              | "dispositionChanged";
          };
      eligibility:
        | {
            kind: "ready";
          }
        | {
            kind: "unavailable";
            reason:
              | "sourceUnavailable"
              | "reportMissing"
              | "reportComplete"
              | "unresolvedMembers"
              | "alreadyClosed";
            /**
             * @maxItems 1000
             */
            attendeeIds: string[];
          };
    } | null;
  };
}
