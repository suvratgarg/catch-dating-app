/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Synthetic practical help requests, retained until rehearsal reset or expiry. No live guest or safety case is written.
 */
export type EventRehearsalCaseDocument =
  | {
      caseId: string;
      sessionId: string;
      actorId: string;
      clockId: string;
      source:
        | {
            kind: "guestAction";
            actionId: string;
          }
        | {
            kind: "messageResponse";
            messageId: string;
            responseId: string;
          };
      category: "eventLogistics" | "accessibility" | "other";
      receivedAt: number;
      status: "open";
      handling: {
        revision: number;
        assigneeUid: string | null;
        updatedAt: number;
        resolution: null;
      };
    }
  | {
      caseId: string;
      sessionId: string;
      actorId: string;
      clockId: string;
      source:
        | {
            kind: "guestAction";
            actionId: string;
          }
        | {
            kind: "messageResponse";
            messageId: string;
            responseId: string;
          };
      category: "eventLogistics" | "accessibility" | "other";
      receivedAt: number;
      status: "resolved";
      handling: {
        revision: number;
        assigneeUid: string | null;
        updatedAt: number;
        resolution: {
          outcome: "resolved" | "declined";
          actorUid: string;
          at: number;
        };
      };
    };
