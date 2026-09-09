/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceCaseCallableResponse {
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  serverTime: number;
  outcome: "applied" | "replayed";
  operationRevision: number;
  view:
    | {
        caseId: string;
        revision: number;
        sourceHash: string;
        availability: "current";
        attendeeId: string;
        category: "eventLogistics" | "accessibility" | "other";
        receivedAt: number;
        status: "open";
        resolution: null;
        canChange: true;
        assignment:
          | {
              kind: "unassigned";
            }
          | {
              kind: "assigned";
              uid: string;
              authority: "current" | "revoked";
            };
      }
    | {
        caseId: string;
        revision: number;
        sourceHash: string;
        availability: "current";
        attendeeId: string;
        category: "eventLogistics" | "accessibility" | "other";
        receivedAt: number;
        status: "resolved";
        resolution: {
          outcome: "resolved" | "declined";
          actorUid: string;
          at: number;
        };
        canChange: false;
        assignment:
          | {
              kind: "unassigned";
            }
          | {
              kind: "assigned";
              uid: string;
              authority: "current" | "revoked";
            };
      }
    | {
        caseId: string;
        revision: number;
        sourceHash: string;
        availability: "sourceChanged";
        attendeeId: null;
        category: "eventLogistics" | "accessibility" | "other";
        receivedAt: number;
        status: "open" | "resolved";
        resolution: null;
        canChange: false;
        assignment: {
          kind: "unavailable";
        };
      }
    | {
        caseId: string;
        revision: null;
        sourceHash: string;
        availability: "legacy";
        attendeeId: null;
        category: "eventLogistics" | "accessibility" | "other";
        receivedAt: number;
        status: "open" | "resolved";
        resolution: null;
        canChange: false;
        assignment: {
          kind: "unavailable";
        };
      };
}
