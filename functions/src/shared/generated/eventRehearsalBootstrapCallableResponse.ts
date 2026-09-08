/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Host projection of a rehearsal session, synthetic actors, and bounded action history.
 */
export interface EventRehearsalBootstrapCallableResponse {
  session: {
    id: string;
    organizerId: string;
    sourceEventId: string | null;
    scenarioId:
      | "smoothRun"
      | "lateAndNoShow"
      | "earlyExitAndReturn"
      | "rosterAndCapacity"
      | "walkInAndAmbiguousClaim"
      | "privacyAndKeepApart"
      | "lowConnectivity"
      | "concurrentHosts"
      | "revealInterrupted"
      | "externalProfiles"
      | "accountabilitySweep";
    seed: number;
    actorCount: number;
    actionCount: number;
    status: "draft" | "ready" | "running" | "paused" | "complete" | "expired";
    setup: {
      title: string;
      locationName: string;
      durationMinutes: number;
      hostGoal: string;
      attendeePrompt: string;
      /**
       * @minItems 1
       * @maxItems 8
       */
      moduleIds: (
        | "arrival"
        | "firstHello"
        | "pods"
        | "rotations"
        | "conversationCues"
        | "reveal"
        | "afterglow"
        | "accountability"
      )[];
      /**
       * Frozen, synthetic-only movement truth used by dress rehearsal. It never reads or writes a real person's live position.
       */
      movementSimulation?: {
        /**
         * @maxItems 40
         */
        itinerary: {
          id: string;
          kind:
            | "gather"
            | "activity"
            | "stop"
            | "break"
            | "transition"
            | "finish";
          offsetMinutes: number;
          durationMinutes?: number | null;
          title: string;
          description?: string | null;
          location?: {
            name: string;
            address?: string | null;
            placeId?: string | null;
            latitude: number;
            longitude: number;
            notes?: string | null;
          } | null;
          routeDistanceMeters?: number | null;
        }[];
        routePlan: null | {
          version: 1 | 2;
          movementMode: "run" | "walk" | "ride" | "mixed";
          routeShape: "loop" | "outAndBack" | "pointToPoint";
          groupStrategy: "together" | "paceGroups" | "selfDirected";
          stopCadence: "continuous" | "flexibleStops" | "hostedStops";
          /**
           * @minItems 1
           * @maxItems 7
           */
          stopKinds: (
            | "water"
            | "regroup"
            | "venue"
            | "photoSpot"
            | "viewpoint"
            | "hazard"
            | "turnaround"
          )[];
          /**
           * @minItems 1
           * @maxItems 6
           */
          roleKinds: (
            | "routeLead"
            | "sweep"
            | "pacer"
            | "stopHost"
            | "marshal"
            | "photographer"
          )[];
          /**
           * @minItems 2
           * @maxItems 500
           */
          path?: {
            latitude: number;
            longitude: number;
          }[];
          /**
           * @maxItems 12
           */
          paceGroups?: {
            id: string;
            label: string;
            targetPaceSecondsPerKm?: number | null;
            sortOrder: number;
          }[];
          liveTrackingPolicy?: {
            mode: "disabled" | "hostOnly" | "authorizedOperators";
            staleAfterSeconds: number;
            retentionMinutes: number;
          };
        };
        /**
         * @maxItems 2
         */
        livePositions: {
          role: "host" | "operator";
          latitude: number;
          longitude: number;
          recordedOffsetMinutes: number;
        }[];
        lateArrivalGuidance: string | null;
      };
    };
    setupRevision: number;
    runtimeRevision: number;
    activeStepIndex: number;
    virtualNowMillis: number;
    faultId:
      | "none"
      | "latency"
      | "oneShotFailure"
      | "listenerDisconnect"
      | "staleRevision"
      | "duplicateDelivery"
      | "legacyFixture"
      | "reducedMotion"
      | "lowBandwidth";
    expiresAtMillis: number;
    virtualStartedAtMillis: number;
  };
  /**
   * @maxItems 50
   */
  actors: {
    actorId: string;
    displayName: string;
    persona: string;
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
    keepApartActorIds: string[];
    helpRequested: boolean;
    promptCompleted: boolean;
    layoutUnitId: string | null;
    confirmedLayoutUnitId: string | null;
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
    assistanceMessage?: {
      messageId: string;
      intentId: string;
      intentRevision: number;
      text: string;
      /**
       * @maxItems 20
       */
      choices: {
        choiceId: string;
        label: string;
      }[];
      lifecycle: "active" | "cancelled" | "superseded" | "responded";
      expiresAt: number;
      canRespond: boolean;
      responseChoiceId: string | null;
    } | null;
    assistanceDelivery?: {
      conflictingEvidence: boolean;
      /**
       * @maxItems 6
       */
      attempts: {
        attemptId: string;
        routeId: "catchEventSms" | "catchEventRcs" | "organizerEventWhatsapp";
        status:
          | "notDispatched"
          | "reserved"
          | "unknown"
          | "accepted"
          | "delivered"
          | "read"
          | "failed"
          | "revoked";
      }[];
    } | null;
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
                  reason:
                    | "unreachable"
                    | "entryDecision"
                    | "missingInformation";
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
  }[];
  /**
   * @maxItems 500
   */
  actions: {
    clientActionId: string;
    actorId: string | null;
    kind: string;
    name: string;
    runtimeRevision: number;
    virtualNowMillis: number;
  }[];
  guestUrl: string;
  canUseInternalFaults: boolean;
}
