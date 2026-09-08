/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Synthetic participant state stored only for an isolated rehearsal.
 */
export interface EventRehearsalActorDocument {
  sessionId: string;
  actorId: string;
  displayName: string;
  persona:
    | "firstTimer"
    | "regular"
    | "quiet"
    | "connector"
    | "external"
    | "sparseProfile"
    | "accessibilityNeeds"
    | "walkIn";
  status:
    | "expected"
    | "present"
    | "late"
    | "noShow"
    | "departed"
    | "returned"
    | "disconnected"
    | "walkIn"
    | "ambiguousClaim";
  connectionState?: "connected" | "disconnected";
  guestMoment:
    | "welcome"
    | "checkIn"
    | "firstHello"
    | "assignment"
    | "rotation"
    | "pause"
    | "reveal"
    | "afterglow"
    | "complete";
  optedOut: boolean;
  /**
   * @maxItems 10
   */
  keepApartActorIds: string[];
  helpRequested: boolean;
  promptCompleted: boolean;
  layoutUnitId: string | null;
  confirmedLayoutUnitId: string | null;
  lastActionAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  assistance?: {
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
    latestMessageId: string | null;
  };
  assistanceAutomation?: {
    clockId: string;
    status: "enabled" | "paused";
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
    nextOutcomeIndex: number;
    evaluation: {
      at: number;
      policy:
        | (
            | {
                kind: "resolved";
                reason: "joined" | "declined";
              }
            | {
                kind: "cancelled";
                reason:
                  | "eventClosed"
                  | "notAdmitted"
                  | "policyDisabled"
                  | "participationInactive";
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
                  | "unchanged"
                  | "participationUnknown";
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
              }
          )
        | null;
      delivery:
        | {
            kind: "paused";
          }
        | {
            kind: "notApplicable";
          }
        | {
            kind: "scriptExhausted";
          }
        | {
            kind: "stop";
            reason:
              | "responded"
              | "cancelled"
              | "superseded"
              | "expired"
              | "eventClosed"
              | "permissionRevoked"
              | "guestPresent"
              | "guestDeclined"
              | "notAdmitted"
              | "hostStopped"
              | "participationInactive";
          }
        | {
            kind: "delivered";
            /**
             * @maxItems 6
             */
            attemptIds: string[];
          }
        | {
            kind: "reconcile";
            /**
             * @maxItems 6
             */
            attemptIds: string[];
            notBefore: number;
          }
        | {
            kind: "refreshFacts";
            reason: "eventFactsStale" | "routeFactsStale";
          }
        | {
            kind: "wait";
            notBefore: number;
            reason: "retryBackoff";
          }
        | {
            kind: "hostDecision";
            reason:
              | "noEligibleRoute"
              | "attemptLimit"
              | "policyRejected"
              | "recipientNeedsReview"
              | "providerOwnsFallback"
              | "conflictingDeliveryEvidence"
              | "historyUnavailable";
          };
    } | null;
  };
  /**
   * Preserves a pre-existing help flag without fabricating a typed request. New actors initialize false.
   */
  untrackedHelpRequested?: boolean;
}
