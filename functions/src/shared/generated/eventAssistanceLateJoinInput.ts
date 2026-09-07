/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type EventAssistanceLateJoinInput = {
  [k: string]: unknown;
} & {
  eventId: string;
  eventOpen: boolean;
  departureConfirmed: boolean;
  /**
   * UTC milliseconds.
   */
  now: number;
  policy: {
    destination:
      | {
          kind: "fixedPlace";
          placeId: string;
          lateEntry: "allowed" | "hostDecision" | "closed";
        }
      | {
          kind: "itineraryStop";
          itineraryId: string;
          /**
           * @minItems 1
           * @maxItems 1000
           */
          permittedStopIds: string[];
        }
      | {
          kind: "groupCheckpoint";
          routeId: string;
          groupId: string;
          /**
           * @minItems 1
           * @maxItems 1000
           */
          permittedCheckpointIds: string[];
        };
    cutoff:
      | {
          kind: "eventEnd";
        }
      | {
          kind: "time";
          /**
           * UTC milliseconds.
           */
          at: number;
        };
    maxMessagesPerEpisode: number;
    minimumMinutesBetweenMessages: number;
    updateOn: "materialGuidanceChange";
    unanswered: "keepUnknownUntilCutoff" | "hostReviewAtDeadline";
  };
  guest: {
    attendeeId: string;
    episodeId: string;
    admission: "admitted" | "pending" | "declined";
    attendance:
      | {
          kind: "known";
          value: {
            checkedIn: boolean;
          };
          /**
           * Nonnegative safe integer revision.
           */
          revision: number;
          /**
           * UTC milliseconds.
           */
          observedAt: number;
          source: "host" | "guest" | "provider" | "system";
        }
      | {
          kind: "unknown";
          reason: "notCollected" | "notConfirmed" | "sourceUnavailable";
        }
      | {
          kind: "stale";
          lastValue: {
            checkedIn: boolean;
          };
          /**
           * UTC milliseconds.
           */
          observedAt: number;
          /**
           * UTC milliseconds.
           */
          staleAt: number;
        };
    intention:
      | {
          kind: "unknown";
        }
      | {
          kind: "onMyWay";
          claimedEta: number | null;
        }
      | {
          kind: "joinLater";
          target:
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
        }
      | {
          kind: "notComing";
        };
    deliveryEligibility: "eligible" | "unreachable" | "unknown";
  };
  guidance:
    | {
        kind: "known";
        value: {
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
        /**
         * Nonnegative safe integer revision.
         */
        revision: number;
        /**
         * UTC milliseconds.
         */
        observedAt: number;
        source: "host" | "guest" | "provider" | "system";
      }
    | {
        kind: "unknown";
        reason: "notCollected" | "notConfirmed" | "sourceUnavailable";
      }
    | {
        kind: "stale";
        lastValue: {
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
        /**
         * UTC milliseconds.
         */
        observedAt: number;
        /**
         * UTC milliseconds.
         */
        staleAt: number;
      };
  lastMessage: {
    materialKey: string;
    /**
     * UTC milliseconds.
     */
    at: number;
  } | null;
  messagesThisEpisode: number;
  /**
   * UTC milliseconds.
   */
  responseDeadline?: number;
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
  setting:
    | {
        kind: "enabled";
        authority: "observe" | "prepare" | "executeWithinPolicy";
        policyVersion: string;
      }
    | {
        kind: "disabled";
        reason: "hostChoice" | "organizerDefault";
      };
};
