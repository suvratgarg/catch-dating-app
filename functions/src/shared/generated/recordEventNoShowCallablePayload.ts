/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type RecordEventNoShowCallablePayload = {
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
    kind: "recordNoShow";
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
      expectedAttendanceRevision: number;
      expectedDispositionRevision: number;
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
    };
  };
  expectedSourceHash: string;
};
