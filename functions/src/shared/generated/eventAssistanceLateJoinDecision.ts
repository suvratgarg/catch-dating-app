/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type EventAssistanceLateJoinDecision =
  | {
      kind: "resolved";
      reason: "joined" | "declined";
    }
  | {
      kind: "cancelled";
      reason: "eventClosed" | "notAdmitted" | "policyDisabled";
    }
  | {
      kind: "expired";
      reason: "cutoff" | "lateEntryClosed";
    }
  | {
      kind: "wait";
      reason:
        | "departureUnconfirmed"
        | "attendanceUnknown"
        | "guidanceUnavailable"
        | "throttled"
        | "unchanged";
    }
  | {
      kind: "hostDecision";
      reason: "unreachable" | "entryDecision" | "missingInformation";
      guidance: {
        /**
         * Nonnegative safe integer revision.
         */
        revision: number;
        destination:
          | {
              kind: "fixedPlace";
              placeId: string;
              lateEntry: "allowed" | "hostDecision" | "closed";
            }
          | {
              kind: "itineraryStop";
              itineraryId: string;
              stopId: string;
            }
          | {
              kind: "groupCheckpoint";
              routeId: string;
              groupId: string;
              checkpointId: string;
            };
        materialKey: string;
        text: string;
        /**
         * UTC milliseconds.
         */
        validUntil: number;
      } | null;
    }
  | {
      kind: "update";
      guidance: {
        /**
         * Nonnegative safe integer revision.
         */
        revision: number;
        destination:
          | {
              kind: "fixedPlace";
              placeId: string;
              lateEntry: "allowed" | "hostDecision" | "closed";
            }
          | {
              kind: "itineraryStop";
              itineraryId: string;
              stopId: string;
            }
          | {
              kind: "groupCheckpoint";
              routeId: string;
              groupId: string;
              checkpointId: string;
            };
        materialKey: string;
        text: string;
        /**
         * UTC milliseconds.
         */
        validUntil: number;
      };
      messageKey: string;
      shouldSend: boolean;
      nextEvaluationAt: number | null;
    };
