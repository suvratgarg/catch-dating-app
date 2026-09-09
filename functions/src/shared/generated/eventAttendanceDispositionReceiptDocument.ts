/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAttendanceDispositionReceiptDocument {
  receiptId: string;
  dispositionId: string;
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  attendeeId: string;
  operationId: string;
  actorUid: string;
  requestHash: string;
  sourceIdentityHash: string;
  revision: number;
  decision:
    | {
        kind: "record";
        evidence:
          | {
              kind: "hostConfirmed";
            }
          | {
              kind: "guestDeclined";
              guestRevision: number;
              episodeId: string;
            };
      }
    | {
        kind: "clear";
        reason:
          | "recordingMistake"
          | "attendanceCorrected"
          | "noLongerApplicable";
      };
  createdAt: number;
}
