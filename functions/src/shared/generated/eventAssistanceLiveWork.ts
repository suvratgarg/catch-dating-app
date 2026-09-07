/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {EventAssistanceLateJoinDecision} from "./eventAssistanceLateJoinDecision";

/**
 * Private normalized payload for one durable live guest episode. Due times and evaluation state are explicit; publication is not provider delivery.
 */
export interface EventAssistanceLiveWork {
  schemaVersion: 1;
  kind: "liveLateJoin";
  scope: {
    context: {
      mode: "live";
      eventId: string;
      organizerId: string;
    };
    attendeeId: string;
    episodeId: string;
  };
  options: {
    /**
     * @minItems 1
     * @maxItems 3
     */
    routes: (
      | {
          routeId: "catchEventSms";
          senderId: string;
        }
      | {
          routeId: "organizerEventWhatsapp";
          senderId: string;
        }
      | {
          routeId: "catchEventRcs";
        }
    )[];
    responseDeadline: number | null;
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
  expiresAt: number;
  maxEvaluations: number;
  checkpoint: {
    dueAt: number | null;
    evaluatedAt: number | null;
    evaluations: number;
    sourceHash: string | null;
    observation:
      | (
          | {
              kind: "decision";
              decision: EventAssistanceLateJoinDecision;
            }
          | {
              kind: "sourceNotReady";
              reason:
                | "episodeMissing"
                | "guestSourceChanged"
                | "membershipMissing"
                | "membershipSourceChanged"
                | "unconfigured"
                | "disabled"
                | "settingSourceChanged"
                | "eventClosed"
                | "runtimeNotLive"
                | "progressUnconfirmed"
                | "progressSourceChanged"
                | "destinationUnavailable";
            }
          | {
              kind: "historyUnavailable";
              reason: "historyLimit" | "deliveryConflict" | "ambiguousHistory";
            }
          | {
              kind: "responseDeadlineMissing";
            }
          | {
              kind: "episodeChanged";
            }
          | {
              kind: "workExpired";
            }
          | {
              kind: "evaluationLimit";
            }
        )
      | null;
    publication: {
      messageId: string;
      threadId: string;
    } | null;
  };
}
