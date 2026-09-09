/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {EventAssistanceMessageDocument} from "./eventAssistanceMessageDocument";

/**
 * Synthetic message evidence isolated from the live outbox; deleted with its rehearsal session.
 */
export type EventRehearsalMessageDocument = {
  record?: {
    intent?: {
      context?: {
        mode?: "rehearsal";
        [k: string]: unknown;
      };
      [k: string]: unknown;
    };
    [k: string]: unknown;
  };
  [k: string]: unknown;
} & {
  sessionId: string;
  actorId: string;
  plan: {
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
    departureConfirmed: boolean;
    responseDeadline: number | null;
    /**
     * @minItems 1
     * @maxItems 3
     */
    routes: ("catchEventSms" | "catchEventRcs" | "organizerEventWhatsapp")[];
    deliveryPolicy: {
      maxAttempts: number;
      maxAttemptsPerRoute: number;
      minimumRetrySeconds: number;
    };
    /**
     * @maxItems 17
     */
    laterChoices?: {
      label: string;
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
    }[];
  };
  record: EventAssistanceMessageDocument;
  handoff?: {
    actorUid: string;
    at: number;
    operationId: string;
  };
};
