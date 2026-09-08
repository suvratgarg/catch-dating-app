/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Host lifecycle or virtual-clock control. Assistance additionally requires the reviewed setup generation so a reset cannot reuse an old runtime revision.
 */
export interface ControlEventRehearsalCallablePayload {
  sessionId: string;
  expectedRevision: number;
  clientActionId: string;
  action:
    | "markReady"
    | "start"
    | "pause"
    | "resume"
    | "advance"
    | "previous"
    | "advanceClock"
    | "complete"
    | "assistance";
  minutes?: number;
  assistance?:
    | {
        kind: "publish";
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
          routes: (
            | "catchEventSms"
            | "catchEventRcs"
            | "organizerEventWhatsapp"
          )[];
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
      }
    | {
        kind: "dispatch";
        actorId: string;
        messageId: string;
        outcome:
          | {
              kind: "accepted" | "delivered" | "read" | "revoked";
            }
          | {
              kind: "failed";
              classification:
                | "technical"
                | "policy"
                | "suppressed"
                | "invalidRecipient";
            }
          | {
              kind: "unknown";
              reason: "timeout" | "connectionLost" | "workerInterrupted";
            };
      }
    | {
        kind: "receipt";
        actorId: string;
        messageId: string;
        attemptId: string;
        outcome:
          | {
              kind: "accepted" | "delivered" | "read" | "revoked";
            }
          | {
              kind: "failed";
              classification:
                | "technical"
                | "policy"
                | "suppressed"
                | "invalidRecipient";
            };
      };
  expectedSetupRevision?: number;
}
