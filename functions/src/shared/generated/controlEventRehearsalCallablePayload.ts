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
    | "assistance"
    | "movement";
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
      }
    | {
        kind: "configureAutomation";
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
        /**
         * @minItems 1
         * @maxItems 6
         */
        outcomes: (
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
            }
        )[];
      }
    | {
        kind: "pauseAutomation";
        actorId: string;
      }
    | {
        kind: "resumeAutomation";
        actorId: string;
      }
    | {
        kind: "resolveAssistance";
        actorId: string;
        payload: {
          caseId: string;
          outcome: "resolved" | "declined" | "transferred";
          /**
           * Current organizer manager UID receiving a transferred request; otherwise the authenticated resolving manager UID.
           */
          owner: string;
          expectedRevision: number;
        };
        expectedSourceHash: string;
      }
    | {
        kind: "repairDelivery";
        actorId: string;
        payload: {
          deliveryId: string;
          action: "reconcile" | "retryDefiniteFailure" | "manualHandoff";
        } & {
          deliveryId?: string;
          [k: string]: unknown;
        };
        expectedMessageRevision: number;
        expectedReviewHash: string;
      }
    | {
        kind: "resolveAccountability";
        actorId: string;
        payload: {
          attendeeId: string;
          /**
           * Current assistance episode, or explicit absence. The command adapter separately fences the canonical physical check-in.
           */
          episodeId: string | null;
          disposition: "returned" | "departed" | "unresolved";
        };
        expectedSourceHash: string;
      }
    | {
        kind: "transferGroup";
        actorId: string;
        payload: {
          attendeeId: string;
          episodeId: string;
          expectedParticipationRevision: number;
          expectedMembershipRevision: number;
          decision:
            | {
                kind: "place";
                groupId: string;
              }
            | {
                kind: "propose";
                from: string | null;
                to: string;
                receivingOperatorId: string;
                expiresAtMillis: number;
              }
            | {
                kind: "accept";
                transferId: string;
              }
            | {
                kind: "reject";
                transferId: string;
              }
            | {
                kind: "cancel";
                transferId: string;
              }
            | {
                kind: "leave";
              };
        };
        expectedSourceHash: string;
      };
  expectedSetupRevision?: number;
  movement?:
    | {
        kind: "confirmDeparture";
        payload: {
          groupId: string;
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
          /**
           * Nonnegative safe integer revision.
           */
          expectedProgressRevision: number;
          departureRoster?: {
            /**
             * @maxItems 1000
             */
            attendeeIds: string[];
            expectedSourceHash: string;
          };
          checkpointRequest?: {
            responsibleOperatorId: string;
            dueAt: number;
          };
        };
        expectedSourceHash: string;
      }
    | {
        kind: "recordCheckpoint";
        payload: {
          groupId: string;
          checkpointId: string;
          /**
           * @maxItems 1000
           */
          accountedFor: string[];
          /**
           * Nonnegative safe integer revision.
           */
          expectedProgressRevision: number;
          expectedCheckpointRevision: number;
          correctionReason: string | null;
        };
        expectedSourceHash: string;
      };
}
