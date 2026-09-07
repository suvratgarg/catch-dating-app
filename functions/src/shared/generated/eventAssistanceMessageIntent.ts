/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type EventAssistanceMessageIntent =
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
