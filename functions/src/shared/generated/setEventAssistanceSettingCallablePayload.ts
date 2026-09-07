/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface SetEventAssistanceSettingCallablePayload {
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  groupId: string;
  workflowKind:
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
  requestId: string;
  expectedRevision: number;
  expectedSourceHash: string;
  preference:
    | {
        kind: "inherit";
      }
    | {
        kind: "disabled";
      }
    | {
        kind: "configured";
        template:
          | {
              kind: "venueReadiness";
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
                requirement: "meetingPlace";
                dueBeforeStartMinutes: number;
                disposition:
                  | "blockSelectedOperation"
                  | "hostMayAcceptException";
              };
            }
          | {
              kind: "routeReadiness";
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
                requirement: "route";
                dueBeforeStartMinutes: number;
                disposition:
                  | "blockSelectedOperation"
                  | "hostMayAcceptException";
              };
            }
          | {
              kind: "formatReadiness";
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
                requirement: "format";
                dueBeforeStartMinutes: number;
                disposition:
                  | "blockSelectedOperation"
                  | "hostMayAcceptException";
              };
            }
          | {
              kind: "rosterReadiness";
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
                requirement: "roster";
                dueBeforeStartMinutes: number;
                disposition:
                  | "blockSelectedOperation"
                  | "hostMayAcceptException";
              };
            }
          | {
              kind: "requiredGuestData";
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
                requirement: "guestData";
                dueBeforeStartMinutes: number;
                disposition:
                  | "blockSelectedOperation"
                  | "hostMayAcceptException";
              };
            }
          | {
              kind: "resourceReadiness";
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
                requirement: "resources";
                dueBeforeStartMinutes: number;
                disposition:
                  | "blockSelectedOperation"
                  | "hostMayAcceptException";
              };
            }
          | {
              kind: "staffingReadiness";
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
                requirement: "responsibilities";
                dueBeforeStartMinutes: number;
                disposition:
                  | "blockSelectedOperation"
                  | "hostMayAcceptException";
              };
            }
          | {
              kind: "messagingReadiness";
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
                requirement: "messaging";
                dueBeforeStartMinutes: number;
                disposition:
                  | "blockSelectedOperation"
                  | "hostMayAcceptException";
              };
            }
          | {
              kind: "admissionReview";
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
                offerExpiryMinutes: number;
                admission: "existingEntitlementPolicy";
                releaseCapacity: "confirmedOnly";
              };
            }
          | {
              kind: "financialReadiness";
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
                requirement: "paymentProvider";
                dueBeforeStartMinutes: number;
                disposition:
                  | "blockSelectedOperation"
                  | "hostMayAcceptException";
              };
            }
          | {
              kind: "joiningInstructions";
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
                templateIntent: "joining";
                audience: "affectedGuests";
                maximumPerGuest: number;
                expiryMinutes: number;
              };
            }
          | {
              kind: "identityResolution";
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
                ambiguousIdentity: "humanResolution";
                fallback: "hostAssistedOperationalOnly";
              };
            }
          | {
              kind: "guestAdmission";
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
                admission: "existingEntitlementPolicy";
                overCapacity: "deny";
                exception: "authorizedHost";
              };
            }
          | {
              kind: "guestCheckIn";
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
                operation: "absolute";
                conflict: "revisionFence";
                attendanceProof: "configuredEventPolicy";
              };
            }
          | {
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
            }
          | {
              kind: "participationChange";
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
                eligibility: "explicitParticipation";
                reentry: "newEpisode";
                guestOptOut: "honor";
              };
            }
          | {
              kind: "guestPrerequisite";
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
                requirementsFrom: "selectedCapabilities";
                fallback: "explicitlySupportedOnly";
              };
            }
          | {
              kind: "allocationRepair";
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
                scope: "futureOnly";
                publication: "hostConfirmed";
                preserveCompleted: true;
                hardConstraints: "neverRelax";
              };
            }
          | {
              kind: "placementConfirmation";
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
                observation: "explicitHost";
                assignmentIsNotObservation: true;
              };
            }
          | {
              kind: "resourceRecovery";
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
                scope: "futureOnly";
                publication: "hostConfirmed";
                preserveCompleted: true;
                hardConstraints: "neverRelax";
                resourceChange: "hostConfirmed";
              };
            }
          | {
              kind: "fairParticipation";
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
                objective: "minimizeRepeatedExclusion";
                hardConstraints: "neverRelax";
                publication: "hostConfirmed";
              };
            }
          | {
              kind: "roundPublication";
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
                futureDrafts: "private";
                publication: "hostConfirmed";
                publishedHistory: "immutableWithCorrections";
              };
            }
          | {
              kind: "unitProgress";
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
                clock: "perUnit";
                progress: "hostConfirmed";
                completedResults: "preserve";
              };
            }
          | {
              kind: "outcomeRecording";
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
                kind: "completion" | "score" | "rank";
                correction: "revisionedFullRound";
                publication: "existingRevealGate";
              };
            }
          | {
              kind: "programmeRecovery";
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
                scope: "remainingProgramme";
                publication: "hostConfirmed";
                alreadyPublished: "correctExplicitly";
              };
            }
          | {
              kind: "departure";
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
                confirmation: "responsibleOperator";
                scope: "perMovingGroup";
                plannedTimeIsNotProof: true;
              };
            }
          | {
              kind: "checkpoint";
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
                reportBy: "responsibleOperator";
                scope: "departureRoster";
                reportDeadlineMinutes: number;
              };
            }
          | {
              kind: "groupTransfer";
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
                handover: "receivingOperatorAcknowledges";
                membership: "singleActiveGroup";
              };
            }
          | {
              kind: "routeRecovery";
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
                scope: "remainingProgramme";
                publication: "hostConfirmed";
                alreadyPublished: "correctExplicitly";
                alternative: "hostApproved";
              };
            }
          | {
              kind: "locationFreshness";
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
                staleAfterSeconds: number;
                fallback: "confirmedJoiningPoint";
                tracking: "authorizedOperatorOnly";
              };
            }
          | {
              kind: "accountability";
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
                mode: "rollCall" | "sweep";
                evidence: "explicitDisposition";
                unknownIsNotIncident: true;
              };
            }
          | {
              kind: "planChangeCommunication";
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
                templateIntent: "planChange";
                audience: "affectedGuests";
                maximumPerGuest: number;
                expiryMinutes: number;
              };
            }
          | {
              kind: "deliveryRecovery";
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
                maximumAttempts: number;
                onUnknown: "reconcileBeforeRetry";
                expiresAfterMinutes: number;
              };
            }
          | {
              kind: "replyOwnership";
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
                owner:
                  | "eventLead"
                  | "groupLead"
                  | "sweep"
                  | "checkIn"
                  | "specialist";
                visibility: "operational" | "restricted";
                dueMinutes: number;
              };
            }
          | {
              kind: "guestAssistance";
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
                owner:
                  | "eventLead"
                  | "groupLead"
                  | "sweep"
                  | "checkIn"
                  | "specialist";
                visibility: "operational" | "restricted";
                dueMinutes: number;
              };
            }
          | {
              kind: "comfortSafety";
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
                owner:
                  | "eventLead"
                  | "groupLead"
                  | "sweep"
                  | "checkIn"
                  | "specialist";
                visibility: "restricted";
                dueMinutes: number;
              };
            }
          | {
              kind: "attendanceSync";
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
                maximumAttempts: number;
                onUnknown: "reconcileBeforeRetry";
                expiresAfterMinutes: number;
              };
            }
          | {
              kind: "concurrencyRecovery";
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
                staleWrite: "reject";
                retry: "revalidateIntent";
              };
            }
          | {
              kind: "operationRecovery";
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
                maximumAttempts: number;
                onUnknown: "reconcileBeforeRetry";
                expiresAfterMinutes: number;
              };
            }
          | {
              kind: "contextBoundary";
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
                context: "eventAndModeBound";
                crossContext: "deny";
              };
            }
          | {
              kind: "overrideReview";
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
                hardLimits: "neverOverride";
                permittedOverride: "scopedReasonedExpiring";
              };
            }
          | {
              kind: "eventClosure";
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
                pendingLiveWork: "cancel";
                survivingObligations: "handoff";
                unresolvedAccountability: "explicitPolicy";
              };
            }
          | {
              kind: "attendanceReconciliation";
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
                silence: "notEvidence";
                corrections: "revisioned";
                pendingSync: "retain";
              };
            }
          | {
              kind: "financialReconciliation";
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
                owner: "paymentProviderWorkflow";
                moneyMovement: "separatelyAuthorized";
              };
            }
          | {
              kind: "postEventFollowUp";
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
                templateIntent: "followUp";
                audience: "affectedGuests";
                maximumPerGuest: number;
                expiryMinutes: number;
              };
            }
          | {
              kind: "eventLearning";
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
                metrics: "observedOutcomes";
                missingCoverage: "explicit";
                sensitiveDetails: "excluded";
              };
            };
      };
}
