/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private durable event-service outbox. The immutable intent and bounded attempt history survive workflow completion and delayed callbacks. Recipient endpoints are references; transport credentials and guest bearer grants belong to their own private stores.
 */
export type EventAssistanceMessageDocument = {
  [k: string]: unknown;
} & {
  schemaVersion: 1;
  messageId: string;
  revision: number;
  intent:
    | {
        schemaVersion: 1;
        intentId: string;
        revision: number;
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
        eventId: string;
        attendeeId: string;
        episodeId: string;
        workflow: {
          kind:
            | "venueReadiness"
            | "routeReadiness"
            | "formatReadiness"
            | "rosterReadiness"
            | "requiredGuestData"
            | "resourceReadiness"
            | "staffingReadiness"
            | "messagingReadiness"
            | "admissionReview"
            | "financialReadiness"
            | "joiningInstructions"
            | "identityResolution"
            | "guestAdmission"
            | "guestCheckIn"
            | "lateJoin"
            | "participationChange"
            | "guestPrerequisite"
            | "allocationRepair"
            | "placementConfirmation"
            | "resourceRecovery"
            | "fairParticipation"
            | "roundPublication"
            | "unitProgress"
            | "outcomeRecording"
            | "programmeRecovery"
            | "departure"
            | "checkpoint"
            | "groupTransfer"
            | "routeRecovery"
            | "locationFreshness"
            | "accountability"
            | "planChangeCommunication"
            | "deliveryRecovery"
            | "replyOwnership"
            | "guestAssistance"
            | "comfortSafety"
            | "attendanceSync"
            | "concurrencyRecovery"
            | "operationRecovery"
            | "contextBoundary"
            | "overrideReview"
            | "eventClosure"
            | "attendanceReconciliation"
            | "financialReconciliation"
            | "postEventFollowUp"
            | "eventLearning";
          occurrenceId: string;
        };
        createdAt: number;
        expiresAt: number;
        /**
         * @minItems 1
         * @maxItems 3
         */
        permittedRoutes: (
          | "catchEventSms"
          | "catchEventRcs"
          | "organizerEventWhatsapp"
        )[];
        deliveryPolicy: {
          maxAttempts: number;
          maxAttemptsPerRoute: number;
          minimumRetrySeconds: number;
        };
        kind: "joiningUpdate";
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
        /**
         * @minItems 1
         * @maxItems 20
         */
        choices: {
          choiceId: string;
          label: string;
          value:
            | {
                kind: "joinIntent";
                intention:
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
              }
            | {
                kind: "requestHelp";
                category:
                  | "eventLogistics"
                  | "accessibility"
                  | "comfortSafety"
                  | "other";
              };
        }[];
      }
    | {
        schemaVersion: 1;
        intentId: string;
        revision: number;
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
        eventId: string;
        attendeeId: string;
        episodeId: string;
        workflow: {
          kind:
            | "venueReadiness"
            | "routeReadiness"
            | "formatReadiness"
            | "rosterReadiness"
            | "requiredGuestData"
            | "resourceReadiness"
            | "staffingReadiness"
            | "messagingReadiness"
            | "admissionReview"
            | "financialReadiness"
            | "joiningInstructions"
            | "identityResolution"
            | "guestAdmission"
            | "guestCheckIn"
            | "lateJoin"
            | "participationChange"
            | "guestPrerequisite"
            | "allocationRepair"
            | "placementConfirmation"
            | "resourceRecovery"
            | "fairParticipation"
            | "roundPublication"
            | "unitProgress"
            | "outcomeRecording"
            | "programmeRecovery"
            | "departure"
            | "checkpoint"
            | "groupTransfer"
            | "routeRecovery"
            | "locationFreshness"
            | "accountability"
            | "planChangeCommunication"
            | "deliveryRecovery"
            | "replyOwnership"
            | "guestAssistance"
            | "comfortSafety"
            | "attendanceSync"
            | "concurrencyRecovery"
            | "operationRecovery"
            | "contextBoundary"
            | "overrideReview"
            | "eventClosure"
            | "attendanceReconciliation"
            | "financialReconciliation"
            | "postEventFollowUp"
            | "eventLearning";
          occurrenceId: string;
        };
        createdAt: number;
        expiresAt: number;
        /**
         * @minItems 1
         * @maxItems 3
         */
        permittedRoutes: (
          | "catchEventSms"
          | "catchEventRcs"
          | "organizerEventWhatsapp"
        )[];
        deliveryPolicy: {
          maxAttempts: number;
          maxAttemptsPerRoute: number;
          minimumRetrySeconds: number;
        };
        kind: "operationalNotice";
        noticeKind:
          | "joiningInstructions"
          | "planChanged"
          | "eventCancelled"
          | "eventFinished"
          | "guestRequirement"
          | "assignmentChanged"
          | "participationCheck"
          | "followUp";
        title: string;
        body: string;
        instructionRevision: number;
        /**
         * @minItems 0
         * @maxItems 20
         */
        choices: {
          choiceId: string;
          label: string;
          value:
            | {
                kind: "acknowledge";
                instructionRevision: number;
              }
            | {
                kind: "requestHelp";
                category:
                  | "eventLogistics"
                  | "accessibility"
                  | "comfortSafety"
                  | "other";
              };
        }[];
      };
  lifecycle: "active" | "cancelled" | "superseded" | "responded";
  /**
   * @maxItems 6
   */
  attempts: (
    | {
        schemaVersion: 1;
        attemptId: string;
        intentId: string;
        intentRevision: number;
        ordinal: number;
        createdAt: number;
        state:
          | {
              kind: "reserved";
              at: number;
              reconcileAfter: number;
            }
          | {
              kind: "unknown";
              at: number;
              providerMessageId: string | null;
              reason: "timeout" | "connectionLost" | "workerInterrupted";
              reconcileAfter: number;
            }
          | {
              kind: "accepted";
              at: number;
              providerMessageId: string;
            }
          | {
              kind: "delivered";
              at: number;
              providerMessageId: string;
            }
          | {
              kind: "read";
              at: number;
              providerMessageId: string;
            }
          | {
              kind: "failed";
              at: number;
              providerMessageId: string | null;
              classification:
                | "technical"
                | "invalidRecipient"
                | "policy"
                | "suppressed";
              evidenceId: string;
            }
          | {
              kind: "revoked";
              at: number;
              providerMessageId: string;
              evidenceId: string;
            }
          | {
              kind: "notDispatched";
              at: number;
              reason:
                | "superseded"
                | "eventClosed"
                | "responded"
                | "expired"
                | "permissionRevoked"
                | "hostStopped";
            };
        mode: "live";
        context: {
          mode: "live";
          eventId: string;
          organizerId: string;
        };
        binding:
          | {
              routeId: "catchEventSms";
              transport: "sms";
              senderIdentity: "catchPlatform";
              provider: "sinch" | "gupshup";
              senderId: string;
              bindingRevision: number;
              recipientEndpointId: string;
              fallbackOwner: "catch" | "provider";
            }
          | {
              routeId: "catchEventRcs";
              transport: "rcs";
              senderIdentity: "catchPlatform";
              provider: "sinch" | "gupshup";
              senderId: string;
              bindingRevision: number;
              recipientEndpointId: string;
              fallbackOwner: "catch" | "provider";
            }
          | {
              routeId: "organizerEventWhatsapp";
              transport: "whatsapp";
              senderIdentity: "organizerManaged";
              provider: "meta";
              senderId: string;
              bindingRevision: number;
              recipientEndpointId: string;
              fallbackOwner: "catch" | "provider";
            };
        authorization: {
          permissionRevision: string;
          checkedAt: number;
          validUntil: number;
          instructionRevision: number;
        };
      }
    | {
        schemaVersion: 1;
        attemptId: string;
        intentId: string;
        intentRevision: number;
        ordinal: number;
        createdAt: number;
        state:
          | {
              kind: "reserved";
              at: number;
              reconcileAfter: number;
            }
          | {
              kind: "unknown";
              at: number;
              providerMessageId: string | null;
              reason: "timeout" | "connectionLost" | "workerInterrupted";
              reconcileAfter: number;
            }
          | {
              kind: "accepted";
              at: number;
              providerMessageId: string;
            }
          | {
              kind: "delivered";
              at: number;
              providerMessageId: string;
            }
          | {
              kind: "read";
              at: number;
              providerMessageId: string;
            }
          | {
              kind: "failed";
              at: number;
              providerMessageId: string | null;
              classification:
                | "technical"
                | "invalidRecipient"
                | "policy"
                | "suppressed";
              evidenceId: string;
            }
          | {
              kind: "revoked";
              at: number;
              providerMessageId: string;
              evidenceId: string;
            }
          | {
              kind: "notDispatched";
              at: number;
              reason:
                | "superseded"
                | "eventClosed"
                | "responded"
                | "expired"
                | "permissionRevoked"
                | "hostStopped";
            };
        mode: "rehearsal";
        context: {
          mode: "rehearsal";
          rehearsalId: string;
          virtualEventId: string;
          clockId: string;
        };
        routeId: "catchEventSms" | "catchEventRcs" | "organizerEventWhatsapp";
        authorization: {
          permissionRevision: string;
          checkedAt: number;
          validUntil: number;
          instructionRevision: number;
        };
      }
  )[];
  deliveryConflict: boolean;
  createdAt: number;
  updatedAt: number;
  response:
    | (
        | {
            schemaVersion: 1;
            responseId: string;
            intentId: string;
            intentRevision: number;
            eventId: string;
            attendeeId: string;
            episodeId: string;
            choiceId: string;
            receivedAt: number;
            value:
              | {
                  kind: "joinIntent";
                  intention:
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
                }
              | {
                  kind: "acknowledge";
                  instructionRevision: number;
                }
              | {
                  kind: "requestHelp";
                  category:
                    | "eventLogistics"
                    | "accessibility"
                    | "comfortSafety"
                    | "other";
                };
            context: {
              mode: "live";
              eventId: string;
              organizerId: string;
            };
            source: {
              kind: "guestWeb";
              linkId: string;
            };
          }
        | {
            schemaVersion: 1;
            responseId: string;
            intentId: string;
            intentRevision: number;
            eventId: string;
            attendeeId: string;
            episodeId: string;
            choiceId: string;
            receivedAt: number;
            value:
              | {
                  kind: "joinIntent";
                  intention:
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
                }
              | {
                  kind: "acknowledge";
                  instructionRevision: number;
                }
              | {
                  kind: "requestHelp";
                  category:
                    | "eventLogistics"
                    | "accessibility"
                    | "comfortSafety"
                    | "other";
                };
            context: {
              mode: "live";
              eventId: string;
              organizerId: string;
            };
            source: {
              kind: "provider";
              attemptId: string;
              providerEventId: string;
            };
          }
        | {
            schemaVersion: 1;
            responseId: string;
            intentId: string;
            intentRevision: number;
            eventId: string;
            attendeeId: string;
            episodeId: string;
            choiceId: string;
            receivedAt: number;
            value:
              | {
                  kind: "joinIntent";
                  intention:
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
                }
              | {
                  kind: "acknowledge";
                  instructionRevision: number;
                }
              | {
                  kind: "requestHelp";
                  category:
                    | "eventLogistics"
                    | "accessibility"
                    | "comfortSafety"
                    | "other";
                };
            context: {
              mode: "rehearsal";
              rehearsalId: string;
              virtualEventId: string;
              clockId: string;
            };
            source: {
              kind: "simulation";
              actionId: string;
            };
          }
      )
    | null;
};
