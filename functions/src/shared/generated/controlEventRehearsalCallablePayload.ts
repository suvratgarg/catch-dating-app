/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Host lifecycle or virtual-clock control. Assistance additionally requires the reviewed setup generation so a reset cannot reuse an old runtime revision.
 */
export type ControlEventRehearsalCallablePayload = {
  [k: string]: unknown;
} & {
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
    | "movement"
    | "staff"
    | "settings"
    | "requiredData"
    | "outcome";
  minutes?: number;
  assistance?:
    | {
        kind: "publish";
        actorId: string;
        plan: {
          /**
           * Explicit observe, prepare, execute or disabled practice mode. Absence preserves earlier executable recipes.
           */
          setting?:
            | {
                kind: "enabled";
                authority: "observe" | "prepare" | "executeWithinPolicy";
              }
            | {
                kind: "disabled";
                reason: "hostChoice" | "organizerDefault";
              };
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
          /**
           * Explicit observe, prepare, execute or disabled practice mode. Absence preserves earlier executable recipes.
           */
          setting?:
            | {
                kind: "enabled";
                authority: "observe" | "prepare" | "executeWithinPolicy";
              }
            | {
                kind: "disabled";
                reason: "hostChoice" | "organizerDefault";
              };
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
        groupId?: string;
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
        kind: "changeRoute";
        payload: {
          /**
           * Nonnegative safe integer revision.
           */
          routeRevision: number;
          groupId: string;
          expectedSourceHash: string;
          alternativeId: string;
          decisionId: string;
        };
      }
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
      }
    | {
        kind: "reassignCheckpointReporter";
        payload: {
          groupId: string;
          checkpointId: string;
          /**
           * Nonnegative safe integer revision.
           */
          expectedProgressRevision: number;
          expectedAssignmentRevision: number;
          responsibleOperatorId: string;
          reason: string;
        };
        expectedSourceHash: string;
      }
    | {
        kind: "setCheckpointCloseout";
        payload: {
          groupId: string;
          checkpointId: string;
          /**
           * Nonnegative safe integer revision.
           */
          expectedProgressRevision: number;
          reason: string;
          expectedCloseoutRevision: number;
          decision: "close" | "reopen";
        };
        expectedSourceHash: string;
      }
    | {
        kind: "resolveAccountability";
        expectedSourceHash: string;
        payload: {
          groupId: string;
          checkpointId: string;
          expectedProgressRevision: number;
          attendeeId: string;
          expectedAccountabilityRevision: number;
          disposition: "returned" | "departed" | "unresolved";
        };
      };
  staff?: {
    operatorId: string;
    displayName: string;
    groupId: string;
    expectedRevision: number;
    expectedSourceHash: string;
    decision:
      | {
          kind: "assign";
          duty: "lead" | "pacer" | "sweep";
          expiresAtMillis: number;
        }
      | {
          kind: "remove";
        };
  };
  practiceOperatorId?: string;
  settings?:
    | {
        kind: "setRule";
        expectedSourceHash: string;
        groupId: string;
        preference:
          | {
              kind: "inherit";
            }
          | {
              kind: "disabled";
            }
          | {
              kind: "configured";
              template: {
                kind: "lateJoin";
                version: 1;
                setting:
                  | {
                      kind: "enabled";
                      authority: "observe" | "prepare" | "executeWithinPolicy";
                    }
                  | {
                      kind: "disabled";
                      reason: "hostChoice" | "organizerDefault";
                    };
                config: {
                  destination:
                    | {
                        kind: "confirmedGroupProgress";
                      }
                    | (
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
                          }
                      );
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
              };
            };
      }
    | {
        kind: "configure";
        expectedSourceHash: string;
        configuration: {
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
          responseDeadline: number | null;
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
        };
      }
    | {
        kind: "pause";
        expectedSourceHash: string;
      };
  requiredData?: {
    attendeeId: string;
    /**
     * @minItems 1
     * @maxItems 10
     */
    fieldIds: (
      | "displayName"
      | "gender"
      | "interestedInGenders"
      | "relationshipGoal"
      | "dateOfBirth"
      | "paceBand"
      | "skillBand"
      | "dietaryAndSeatingNotes"
      | "questionnaireAnswerIds"
      | "teamName"
    )[];
    /**
     * UTC milliseconds.
     */
    expiresAt: number;
    expectedProfileRevision: number;
    expectedRequestRevision: number;
    expectedSourceHash: string;
  };
  outcome?: {
    unitId: string;
    round: number;
    outcome:
      | {
          kind: "completion";
          completed: boolean;
        }
      | {
          kind: "score";
          score: number;
        }
      | {
          kind: "rank";
          rank: number;
        };
    expectedOutcomeRevision: number;
  };
};
