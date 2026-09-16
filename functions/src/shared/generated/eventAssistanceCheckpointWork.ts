/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceCheckpointWork {
  schemaVersion: 1;
  kind: "liveCheckpointReport";
  scope: {
    context: {
      mode: "live";
      eventId: string;
      organizerId: string;
    };
    groupId: string;
    checkpointId: string;
    progressRevision: number;
  };
  rosterId: string;
  rosterHash: string;
  request: {
    responsibleOperatorId: string;
    dueAt: number;
  };
  requestedAt: number;
  checkpoint: {
    dueAt: number | null;
    evaluatedAt: number | null;
    failures: number;
    observation:
      | (
          | {
              kind: "observed";
              request:
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
                  };
              reportRevision: number;
              sourceHash: string;
              ownerValidUntil: number;
            }
          | {
              kind: "unavailable";
              reason: "factsUnavailable";
            }
        )
      | null;
  };
  reassignment?: {
    revision: number;
    receiptId: string;
    responsibleOperatorId: string;
    previousResponsibleOperatorId: string;
    assignedBy: string;
    assignedAt: number;
    reason: string;
  };
  closeout?: {
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
  };
}
