/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type TransferEventAssistanceGroupCallablePayload = {
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
    kind: "transferGroup";
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
      attendeeId: string;
      episodeId: string;
      expectedParticipationRevision: number;
      expectedMembershipRevision: number;
      decision:
        | {
            kind: "place";
            groupId: string;
          }
        | {
            kind: "propose";
            from: string | null;
            to: string;
            receivingOperatorId: string;
            expiresAtMillis: number;
          }
        | {
            kind: "accept";
            transferId: string;
          }
        | {
            kind: "reject";
            transferId: string;
          }
        | {
            kind: "cancel";
            transferId: string;
          }
        | {
            kind: "leave";
          };
    };
  };
  expectedSourceHash: string;
};
