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
                    state: "complete";
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
}
