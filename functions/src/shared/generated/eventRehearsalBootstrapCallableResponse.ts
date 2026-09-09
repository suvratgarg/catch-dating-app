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
  helpRequests?: {
    clockId: string;
    coverage: "boundedSession";
    /**
     * @maxItems 500
     */
    cases: (
      | {
          caseId: string;
          revision: number;
          sourceHash: string;
          availability: "current";
          attendeeId: string;
          category: "eventLogistics" | "accessibility" | "other";
          receivedAt: number;
          status: "open";
          resolution: null;
          canChange: true;
          assignment:
            | {
                kind: "unassigned";
              }
            | {
                kind: "assigned";
                uid: string;
                authority: "current" | "revoked";
              };
        }
      | {
          caseId: string;
          revision: number;
          sourceHash: string;
          availability: "current";
          attendeeId: string;
          category: "eventLogistics" | "accessibility" | "other";
          receivedAt: number;
          status: "resolved";
          resolution: {
            outcome: "resolved" | "declined";
            actorUid: string;
            at: number;
          };
          canChange: false;
          assignment:
            | {
                kind: "unassigned";
              }
            | {
                kind: "assigned";
                uid: string;
                authority: "current" | "revoked";
              };
        }
      | {
          caseId: string;
          revision: number;
          sourceHash: string;
          availability: "sourceChanged";
          attendeeId: null;
          category: "eventLogistics" | "accessibility" | "other";
          receivedAt: number;
          status: "open" | "resolved";
          resolution: null;
          canChange: false;
          assignment: {
            kind: "unavailable";
          };
        }
      | {
          caseId: string;
          revision: null;
          sourceHash: string;
          availability: "legacy";
          attendeeId: null;
          category: "eventLogistics" | "accessibility" | "other";
          receivedAt: number;
          status: "open" | "resolved";
          resolution: null;
          canChange: false;
          assignment: {
            kind: "unavailable";
          };
        }
    )[];
    /**
     * @maxItems 50
     */
    untrackedActorIds: string[];
  };
  deliveryReviews?: {
    context: (
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
        }
    ) & {
      mode?: "rehearsal";
      [k: string]: unknown;
    };
    coverage: "currentActorMessages";
    /**
     * @maxItems 50
     */
    deliveries: ((
      | {
          messageId: string;
          revision: number;
          reviewHash: string;
          createdAt: number;
          expiresAt: number;
          lifecycle: "active" | "cancelled" | "superseded" | "responded";
          deliveryStatus:
            | "notSubmitted"
            | "reserved"
            | "unknown"
            | "accepted"
            | "delivered"
            | "read"
            | "failed"
            | "notDispatched"
            | "conflictingEvidence"
            | "revoked";
          /**
           * @maxItems 6
           */
          attempts: {
            channel: "sms" | "whatsapp" | "rcs";
            state:
              | "reserved"
              | "unknown"
              | "accepted"
              | "delivered"
              | "read"
              | "failed"
              | "notDispatched"
              | "revoked";
            at: number;
          }[];
          coordination:
            | {
                kind: "untracked";
              }
            | {
                kind: "tracked";
                phase: "queued" | "retry" | "receipt" | "review" | "complete";
                reason: string | null;
                dueAt: number | null;
              };
          handling:
            | {
                kind: "automatic";
              }
            | {
                kind: "manual";
                actorUid: string;
                at: number;
                authority: "current" | "revoked";
              };
          availability: "current";
          attendeeId: string;
          /**
           * @maxItems 1
           */
          actions: "manualHandoff"[];
          purpose:
            | "joiningUpdate"
            | "joiningInstructions"
            | "planChanged"
            | "guestRequirement"
            | "assignmentChanged"
            | "participationCheck"
            | "eventCancelled"
            | "eventFinished"
            | "followUp";
        }
      | {
          messageId: string;
          revision: number;
          reviewHash: string;
          createdAt: number;
          expiresAt: number;
          lifecycle: "active" | "cancelled" | "superseded" | "responded";
          deliveryStatus:
            | "notSubmitted"
            | "reserved"
            | "unknown"
            | "accepted"
            | "delivered"
            | "read"
            | "failed"
            | "notDispatched"
            | "conflictingEvidence"
            | "revoked";
          /**
           * @maxItems 6
           */
          attempts: {
            channel: "sms" | "whatsapp" | "rcs";
            state:
              | "reserved"
              | "unknown"
              | "accepted"
              | "delivered"
              | "read"
              | "failed"
              | "notDispatched"
              | "revoked";
            at: number;
          }[];
          coordination:
            | {
                kind: "untracked";
              }
            | {
                kind: "tracked";
                phase: "queued" | "retry" | "receipt" | "review" | "complete";
                reason: string | null;
                dueAt: number | null;
              };
          handling:
            | {
                kind: "automatic";
              }
            | {
                kind: "manual";
                actorUid: string;
                at: number;
                authority: "current" | "revoked";
              };
          availability: "sourceChanged";
          attendeeId: null;
          /**
           * @maxItems 0
           */
          actions: "manualHandoff"[];
          purpose:
            | "joiningUpdate"
            | "joiningInstructions"
            | "planChanged"
            | "guestRequirement"
            | "assignmentChanged"
            | "participationCheck"
            | "eventCancelled"
            | "eventFinished"
            | "followUp";
        }
    ) & {
      availability?: "current";
      purpose?: "joiningUpdate";
      coordination?: {
        kind: "untracked";
      };
      [k: string]: unknown;
    })[];
  };
  accountabilityReviews?: {
    clockId: string;
    coverage: "boundedSession";
    /**
     * @maxItems 50
     */
    rows: {
      attendeeId: string;
      episodeId: string;
      sourceHash: string;
      visitRevision: number | null;
      checkedInAtMillis: number | null;
      revision: number;
      disposition: "returned" | "departed" | "unresolved";
      availability:
        | {
            kind: "ready";
          }
        | {
            kind: "unavailable";
            reason:
              | "notApplicable"
              | "notCheckedIn"
              | "visitNotRecorded"
              | "invalidSource";
          };
      canResolve: boolean;
    }[];
  };
  membershipReviews?: {
    clockId: string;
    actorUid: string;
    coverage: "boundedSession";
    /**
     * @maxItems 42
     */
    receivingOperatorIds: string[];
    /**
     * @maxItems 50
     */
    rows: {
      attendeeId: string;
      sourceHash: string;
      serverTime: number;
      revision: number;
      episodeId: string | null;
      participationRevision: number;
      freshness: "uninitialized" | "current" | "sourceChanged";
      ready: boolean;
      accepted: {
        groupId: string;
        groupSourceHash: string;
        responsibleOperatorId: string;
        acceptedAt: number;
      } | null;
      transfer:
        | (
            | {
                transferId: string;
                from: string | null;
                to: string;
                targetSourceHash: string;
                receivingOperatorId: string;
                requestedBy: string;
                requestedAt: number;
                expiresAt: number;
                status: "pending";
                resolvedAt: null;
                resolvedBy: null;
              }
            | {
                transferId: string;
                from: string | null;
                to: string;
                targetSourceHash: string;
                receivingOperatorId: string;
                requestedBy: string;
                requestedAt: number;
                expiresAt: number;
                status: "accepted" | "rejected" | "cancelled";
                resolvedAt: number;
                resolvedBy: string;
              }
          )
        | null;
      transferState:
        | "none"
        | "pending"
        | "expired"
        | "sourceChanged"
        | "accepted"
        | "rejected"
        | "cancelled";
      /**
       * @maxItems 40
       */
      groups: {
        groupId: string;
        label: string;
      }[];
      /**
       * @maxItems 6
       */
      actions: (
        | "place"
        | "propose"
        | "accept"
        | "reject"
        | "cancel"
        | "leave"
      )[];
      availability:
        | "ready"
        | "notApplicable"
        | "participationNotRecorded"
        | "invalidSource";
    }[];
  };
  movementReview?: {
    sessionId: string;
    organizerId: string;
    clockId: string;
    setupRevision: number;
    runtimeRevision: number;
    actorUid: string;
    serverTime: number;
    groupId: string;
    /**
     * @maxItems 41
     */
    groups: {
      groupId: string;
      label: string;
    }[];
    progress: {
      revision: number;
      sourceHash: string;
      eventOpen: boolean;
      runtimeLive: boolean;
      /**
       * @maxItems 41
       */
      destinations: {
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
        label: string;
        text: string;
      }[];
      current: {
        sessionId: string;
        clockId: string;
        groupId: string;
        progressRevision: number;
        departure: {
          sourceHash: string;
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
          confirmedAt: number;
          confirmedBy: string;
          operationId: string;
          roster: {
            /**
             * @maxItems 50
             */
            members: {
              attendeeId: string;
              displayName: string;
              visitHash: string;
              episodeId: string | null;
              membershipHash: string | null;
            }[];
            selectionHash: string;
          } | null;
          checkpointRequest: {
            responsibleOperatorId: string;
            dueAt: number;
          } | null;
        };
        report: {
          revision: number;
          rosterHash: string;
          /**
           * @maxItems 50
           */
          accountedFor: string[];
          reportedAt: number;
          reportedBy: string;
          correctionReason: string | null;
        } | null;
        assignment?: {
          revision: number;
          responsibleOperatorId: string;
          previousResponsibleOperatorId: string;
          assignedBy: string;
          assignedAt: number;
          reason: string;
          operationId: string;
        };
        closeout?: {
          revision: number;
          previousRevision: number;
          changedBy: string;
          changedAt: number;
          reason: string;
          decision:
            | {
                kind: "close";
                report: {
                  revision: number;
                  rosterHash: string;
                  /**
                   * @maxItems 50
                   */
                  accountedFor: string[];
                  reportedAt: number;
                  reportedBy: string;
                  correctionReason: string | null;
                };
                /**
                 * @maxItems 50
                 */
                dispositions: {
                  kind: "resolved";
                  disposition: "returned" | "departed";
                  revision: number;
                  resolvedAt: number;
                  resolvedBy: string;
                  sourceHash: string;
                  attendeeId: string;
                }[];
              }
            | {
                kind: "reopen";
              };
          operationId: string;
        };
      } | null;
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
    };
    roster: {
      sourceHash: string;
      /**
       * @maxItems 50
       */
      members: {
        attendeeId: string;
        displayName: string;
        visitHash: string;
        episodeId: string | null;
        membershipHash: string | null;
      }[];
      /**
       * @maxItems 50
       */
      unavailable: {
        attendeeId: string;
        reason:
          | "notCheckedIn"
          | "participationUnavailable"
          | "membershipUnavailable"
          | "invalidSource";
      }[];
      coverage: "boundedSession";
    };
    checkpoint: {
      progressRevision: number;
      checkpointId: string;
      sourceHash: string;
      revision: number;
      availability:
        | {
            kind: "ready";
            rosterId: string;
            label: string;
            reportStatus: "unreported" | "partial" | "complete";
            /**
             * @maxItems 1000
             */
            members: {
              attendeeId: string;
              observation: "accountedFor" | "unconfirmed";
              visit:
                | {
                    kind: "current";
                  }
                | {
                    kind: "unavailable";
                    reason:
                      | "registrationMissing"
                      | "visitChanged"
                      | "notCheckedIn"
                      | "invalidSource";
                  };
              /**
               * Visit-bound event accountability evidence. A resolved disposition never means arrival at this checkpoint.
               */
              disposition?:
                | {
                    kind: "unresolved";
                  }
                | {
                    kind: "resolved";
                    disposition: "returned" | "departed";
                    revision: number;
                    resolvedAt: number;
                    resolvedBy: string;
                    sourceHash: string;
                  }
                | {
                    kind: "unavailable";
                    reason:
                      | "registrationMissing"
                      | "visitChanged"
                      | "notCheckedIn"
                      | "invalidSource"
                      | "beforeDeparture";
                  };
            }[];
          }
        | {
            kind: "unavailable";
            reason:
              | "rosterNotRecorded"
              | "destinationNotRecorded"
              | "differentCheckpoint"
              | "notCheckpoint"
              | "setupChanged";
          };
      report: {
        revision: number;
        rosterHash: string;
        /**
         * @maxItems 50
         */
        accountedFor: string[];
        reportedAt: number;
        reportedBy: string;
        correctionReason: string | null;
      } | null;
      request:
        | (
            | {
                responsibleOperatorId: string;
                dueAt: number;
                state:
                  | "awaitingReport"
                  | "overdue"
                  | "discrepancy"
                  | "sourceUnavailable";
                ownerAvailability: "current" | "needsReassignment";
              }
            | {
                responsibleOperatorId: string;
                dueAt: number;
                state: "complete" | "closedOut";
                ownerAvailability: "notRequired";
              }
          )
        | null;
      departure: {
        sourceHash: string;
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
        confirmedAt: number;
        confirmedBy: string;
        operationId: string;
        roster: {
          /**
           * @maxItems 50
           */
          members: {
            attendeeId: string;
            displayName: string;
            visitHash: string;
            episodeId: string | null;
            membershipHash: string | null;
          }[];
          selectionHash: string;
        } | null;
        checkpointRequest: {
          responsibleOperatorId: string;
          dueAt: number;
        } | null;
      };
      assignment?: {
        revision: number;
        sourceHash: string;
        change: {
          revision: number;
          responsibleOperatorId: string;
          previousResponsibleOperatorId: string;
          assignedBy: string;
          assignedAt: number;
          reason: string;
          operationId: string;
        } | null;
      } | null;
      closeout?: {
        revision: number;
        sourceHash: string;
        change: {
          revision: number;
          previousRevision: number;
          changedBy: string;
          changedAt: number;
          reason: string;
          decision:
            | {
                kind: "close";
                report: {
                  revision: number;
                  rosterHash: string;
                  /**
                   * @maxItems 50
                   */
                  accountedFor: string[];
                  reportedAt: number;
                  reportedBy: string;
                  correctionReason: string | null;
                };
                /**
                 * @maxItems 50
                 */
                dispositions: {
                  kind: "resolved";
                  disposition: "returned" | "departed";
                  revision: number;
                  resolvedAt: number;
                  resolvedBy: string;
                  sourceHash: string;
                  attendeeId: string;
                }[];
              }
            | {
                kind: "reopen";
              };
          operationId: string;
        } | null;
        state:
          | {
              kind: "open" | "reopened" | "closedOut" | "superseded";
            }
          | {
              kind: "needsReview";
              reason:
                | "sourceUnavailable"
                | "reportChanged"
                | "dispositionChanged";
            };
        eligibility:
          | {
              kind: "ready";
            }
          | {
              kind: "unavailable";
              reason:
                | "sourceUnavailable"
                | "reportMissing"
                | "reportComplete"
                | "unresolvedMembers"
                | "alreadyClosed";
              /**
               * @maxItems 1000
               */
              attendeeIds: string[];
            };
      } | null;
    } | null;
    /**
     * @maxItems 25
     */
    history: {
      progressRevision: number;
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
      confirmedAt: number;
      rosterSize: number | null;
      reportRevision: number;
      accountedForCount: number;
      checkpointRequest: {
        responsibleOperatorId: string;
        dueAt: number;
      } | null;
    }[];
    nextBeforeRevision: number | null;
    selected: {
      sessionId: string;
      clockId: string;
      groupId: string;
      progressRevision: number;
      departure: {
        sourceHash: string;
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
        confirmedAt: number;
        confirmedBy: string;
        operationId: string;
        roster: {
          /**
           * @maxItems 50
           */
          members: {
            attendeeId: string;
            displayName: string;
            visitHash: string;
            episodeId: string | null;
            membershipHash: string | null;
          }[];
          selectionHash: string;
        } | null;
        checkpointRequest: {
          responsibleOperatorId: string;
          dueAt: number;
        } | null;
      };
      report: {
        revision: number;
        rosterHash: string;
        /**
         * @maxItems 50
         */
        accountedFor: string[];
        reportedAt: number;
        reportedBy: string;
        correctionReason: string | null;
      } | null;
      assignment?: {
        revision: number;
        responsibleOperatorId: string;
        previousResponsibleOperatorId: string;
        assignedBy: string;
        assignedAt: number;
        reason: string;
        operationId: string;
      };
      closeout?: {
        revision: number;
        previousRevision: number;
        changedBy: string;
        changedAt: number;
        reason: string;
        decision:
          | {
              kind: "close";
              report: {
                revision: number;
                rosterHash: string;
                /**
                 * @maxItems 50
                 */
                accountedFor: string[];
                reportedAt: number;
                reportedBy: string;
                correctionReason: string | null;
              };
              /**
               * @maxItems 50
               */
              dispositions: {
                kind: "resolved";
                disposition: "returned" | "departed";
                revision: number;
                resolvedAt: number;
                resolvedBy: string;
                sourceHash: string;
                attendeeId: string;
              }[];
            }
          | {
              kind: "reopen";
            };
        operationId: string;
      };
    } | null;
  };
}
