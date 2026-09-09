/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAttendanceDispositionCallableResponse {
  outcome: "read" | "applied" | "replayed";
  operationRevision: number | null;
  view: {
    context: {
      mode: "live";
      eventId: string;
      organizerId: string;
    };
    attendeeId: string;
    displayName: string;
    serverTime: number;
    sourceHash: string;
    attendance: {
      status:
        | "invited"
        | "registered"
        | "waitlisted"
        | "checkedIn"
        | "cancelled";
      checkedIn: boolean;
      revision: number;
    };
    closure:
      | {
          kind: "open" | "cancelled";
        }
      | {
          kind: "runtimeComplete";
          completedAt: number;
        }
      | {
          kind: "scheduledEnd";
          endedAt: number;
        };
    declineEvidence: {
      kind: "guestDeclined";
      guestRevision: number;
      episodeId: string;
    } | null;
    disposition:
      | {
          kind: "unreviewed";
          revision: 0;
        }
      | {
          kind: "recorded";
          revision: number;
          evidence:
            | {
                kind: "hostConfirmed";
              }
            | {
                kind: "guestDeclined";
                guestRevision: number;
                episodeId: string;
              };
          actorUid: string;
          recordedAt: number;
        }
      | {
          kind: "cleared";
          revision: number;
          reason:
            | "recordingMistake"
            | "attendanceCorrected"
            | "noLongerApplicable";
          actorUid: string;
          recordedAt: number;
        }
      | {
          kind: "sourceChanged";
          revision: number;
        }
      | {
          kind: "superseded";
          revision: number;
          reason:
            | "attendanceChanged"
            | "eventChanged"
            | "guestIntentionChanged";
        };
    recordability:
      | {
          kind: "allowed";
        }
      | {
          kind: "unavailable";
          reason:
            | "eventNotFinished"
            | "eventCancelled"
            | "notAdmitted"
            | "alreadyAttended";
        };
    canClear: boolean;
  };
}
