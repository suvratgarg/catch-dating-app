/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAttendanceReportCallableResponse {
  view: {
    context: {
      mode: "live";
      eventId: string;
      organizerId: string;
    };
    serverTime: number;
    sourceHash: string;
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
    source: "eventAttendees";
    coverage: "emptyRoster" | "completeRoster";
    rosterCount: number;
    counts: {
      attended: number;
      recordedNoShow: {
        hostConfirmed: number;
        guestDeclined: number;
      };
      unresolved: {
        unreviewed: number;
        cleared: number;
        sourceChanged: number;
        superseded: number;
      };
      notExpected: {
        invited: number;
        waitlisted: number;
        cancelled: number;
        eventCancelled: number;
      };
    };
    /**
     * @maxItems 1000
     */
    members: {
      attendeeId: string;
      classification:
        | {
            kind: "attended";
          }
        | {
            kind: "recordedNoShow";
            evidence: "hostConfirmed" | "guestDeclined";
          }
        | {
            kind: "unresolved";
            reason: "unreviewed" | "cleared" | "sourceChanged" | "superseded";
          }
        | {
            kind: "notExpected";
            reason: "invited" | "waitlisted" | "cancelled" | "eventCancelled";
          };
    }[];
  };
}
