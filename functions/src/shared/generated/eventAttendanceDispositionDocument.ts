/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAttendanceDispositionDocument {
  dispositionId: string;
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  attendeeId: string;
  revision: number;
  binding: {
    sourceGeneration: string;
    attendeeGeneration: string;
    identityHash: string;
    attendanceHash: string;
    closureHash: string;
  };
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
  actorUid: string;
  recordedAt: number;
}
