/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type EventAssistancePolicy =
  | {
      kind: "venueReadiness";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        requirement: "meetingPlace";
        dueBeforeStartMinutes: number;
        disposition: "blockSelectedOperation" | "hostMayAcceptException";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "routeReadiness";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        requirement: "route";
        dueBeforeStartMinutes: number;
        disposition: "blockSelectedOperation" | "hostMayAcceptException";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "formatReadiness";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        requirement: "format";
        dueBeforeStartMinutes: number;
        disposition: "blockSelectedOperation" | "hostMayAcceptException";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "rosterReadiness";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        requirement: "roster";
        dueBeforeStartMinutes: number;
        disposition: "blockSelectedOperation" | "hostMayAcceptException";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "requiredGuestData";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        requirement: "guestData";
        dueBeforeStartMinutes: number;
        disposition: "blockSelectedOperation" | "hostMayAcceptException";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "resourceReadiness";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        requirement: "resources";
        dueBeforeStartMinutes: number;
        disposition: "blockSelectedOperation" | "hostMayAcceptException";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "staffingReadiness";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        requirement: "responsibilities";
        dueBeforeStartMinutes: number;
        disposition: "blockSelectedOperation" | "hostMayAcceptException";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "messagingReadiness";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        requirement: "messaging";
        dueBeforeStartMinutes: number;
        disposition: "blockSelectedOperation" | "hostMayAcceptException";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "admissionReview";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        offerExpiryMinutes: number;
        admission: "existingEntitlementPolicy";
        releaseCapacity: "confirmedOnly";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "financialReadiness";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        requirement: "paymentProvider";
        dueBeforeStartMinutes: number;
        disposition: "blockSelectedOperation" | "hostMayAcceptException";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "joiningInstructions";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        templateIntent: "joining";
        audience: "affectedGuests";
        maximumPerGuest: number;
        expiryMinutes: number;
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "identityResolution";
      version: 1;
      scope: {
        kind: "guest";
        eventId: string;
        attendeeId: string;
        episodeId: string;
      };
      config: {
        ambiguousIdentity: "humanResolution";
        fallback: "hostAssistedOperationalOnly";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "guestAdmission";
      version: 1;
      scope: {
        kind: "guest";
        eventId: string;
        attendeeId: string;
        episodeId: string;
      };
      config: {
        admission: "existingEntitlementPolicy";
        overCapacity: "deny";
        exception: "authorizedHost";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "guestCheckIn";
      version: 1;
      scope: {
        kind: "guest";
        eventId: string;
        attendeeId: string;
        episodeId: string;
      };
      config: {
        operation: "absolute";
        conflict: "revisionFence";
        attendanceProof: "configuredEventPolicy";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "lateJoin";
      version: 1;
      scope: {
        kind: "guest";
        eventId: string;
        attendeeId: string;
        episodeId: string;
      };
      config: {
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
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "participationChange";
      version: 1;
      scope: {
        kind: "guest";
        eventId: string;
        attendeeId: string;
        episodeId: string;
      };
      config: {
        eligibility: "explicitParticipation";
        reentry: "newEpisode";
        guestOptOut: "honor";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "guestPrerequisite";
      version: 1;
      scope: {
        kind: "guest";
        eventId: string;
        attendeeId: string;
        episodeId: string;
      };
      config: {
        requirementsFrom: "selectedCapabilities";
        fallback: "explicitlySupportedOnly";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "allocationRepair";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        scope: "futureOnly";
        publication: "hostConfirmed";
        preserveCompleted: true;
        hardConstraints: "neverRelax";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "placementConfirmation";
      version: 1;
      scope: {
        kind: "guest";
        eventId: string;
        attendeeId: string;
        episodeId: string;
      };
      config: {
        observation: "explicitHost";
        assignmentIsNotObservation: true;
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "resourceRecovery";
      version: 1;
      scope: {
        kind: "resource";
        eventId: string;
        resourceId: string;
      };
      config: {
        scope: "futureOnly";
        publication: "hostConfirmed";
        preserveCompleted: true;
        hardConstraints: "neverRelax";
        resourceChange: "hostConfirmed";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "fairParticipation";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        objective: "minimizeRepeatedExclusion";
        hardConstraints: "neverRelax";
        publication: "hostConfirmed";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "roundPublication";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        futureDrafts: "private";
        publication: "hostConfirmed";
        publishedHistory: "immutableWithCorrections";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "unitProgress";
      version: 1;
      scope: {
        kind: "unit";
        eventId: string;
        unitId: string;
        round: number;
      };
      config: {
        clock: "perUnit";
        progress: "hostConfirmed";
        completedResults: "preserve";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "outcomeRecording";
      version: 1;
      scope: {
        kind: "unit";
        eventId: string;
        unitId: string;
        round: number;
      };
      config: {
        kind: "completion" | "score" | "rank";
        correction: "revisionedFullRound";
        publication: "existingRevealGate";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "programmeRecovery";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        scope: "remainingProgramme";
        publication: "hostConfirmed";
        alreadyPublished: "correctExplicitly";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "departure";
      version: 1;
      scope: {
        kind: "group";
        eventId: string;
        groupId: string;
      };
      config: {
        confirmation: "responsibleOperator";
        scope: "perMovingGroup";
        plannedTimeIsNotProof: true;
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "checkpoint";
      version: 1;
      scope: {
        kind: "group";
        eventId: string;
        groupId: string;
      };
      config: {
        reportBy: "responsibleOperator";
        scope: "departureRoster";
        reportDeadlineMinutes: number;
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "groupTransfer";
      version: 1;
      scope: {
        kind: "group";
        eventId: string;
        groupId: string;
      };
      config: {
        handover: "receivingOperatorAcknowledges";
        membership: "singleActiveGroup";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "routeRecovery";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        scope: "remainingProgramme";
        publication: "hostConfirmed";
        alreadyPublished: "correctExplicitly";
        alternative: "hostApproved";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "locationFreshness";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        staleAfterSeconds: number;
        fallback: "confirmedJoiningPoint";
        tracking: "authorizedOperatorOnly";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "accountability";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        mode: "rollCall" | "sweep";
        evidence: "explicitDisposition";
        unknownIsNotIncident: true;
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "planChangeCommunication";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        templateIntent: "planChange";
        audience: "affectedGuests";
        maximumPerGuest: number;
        expiryMinutes: number;
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "deliveryRecovery";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        maximumAttempts: number;
        onUnknown: "reconcileBeforeRetry";
        expiresAfterMinutes: number;
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "replyOwnership";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        owner: "eventLead" | "groupLead" | "sweep" | "checkIn" | "specialist";
        visibility: "operational" | "restricted";
        dueMinutes: number;
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "guestAssistance";
      version: 1;
      scope: {
        kind: "guest";
        eventId: string;
        attendeeId: string;
        episodeId: string;
      };
      config: {
        owner: "eventLead" | "groupLead" | "sweep" | "checkIn" | "specialist";
        visibility: "operational" | "restricted";
        dueMinutes: number;
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "comfortSafety";
      version: 1;
      scope: {
        kind: "guest";
        eventId: string;
        attendeeId: string;
        episodeId: string;
      };
      config: {
        owner: "eventLead" | "groupLead" | "sweep" | "checkIn" | "specialist";
        visibility: "restricted";
        dueMinutes: number;
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "attendanceSync";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        maximumAttempts: number;
        onUnknown: "reconcileBeforeRetry";
        expiresAfterMinutes: number;
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "concurrencyRecovery";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        staleWrite: "reject";
        retry: "revalidateIntent";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "operationRecovery";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        maximumAttempts: number;
        onUnknown: "reconcileBeforeRetry";
        expiresAfterMinutes: number;
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "contextBoundary";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        context: "eventAndModeBound";
        crossContext: "deny";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "overrideReview";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        hardLimits: "neverOverride";
        permittedOverride: "scopedReasonedExpiring";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "eventClosure";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        pendingLiveWork: "cancel";
        survivingObligations: "handoff";
        unresolvedAccountability: "explicitPolicy";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "attendanceReconciliation";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        silence: "notEvidence";
        corrections: "revisioned";
        pendingSync: "retain";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "financialReconciliation";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        owner: "paymentProviderWorkflow";
        moneyMovement: "separatelyAuthorized";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "postEventFollowUp";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        templateIntent: "followUp";
        audience: "affectedGuests";
        maximumPerGuest: number;
        expiryMinutes: number;
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    }
  | {
      kind: "eventLearning";
      version: 1;
      scope:
        | {
            kind: "event";
            eventId: string;
          }
        | {
            kind: "guest";
            eventId: string;
            attendeeId: string;
            episodeId: string;
          }
        | {
            kind: "group";
            eventId: string;
            groupId: string;
          }
        | {
            kind: "resource";
            eventId: string;
            resourceId: string;
          }
        | {
            kind: "unit";
            eventId: string;
            unitId: string;
            round: number;
          };
      config: {
        metrics: "observedOutcomes";
        missingCoverage: "explicit";
        sensitiveDetails: "excluded";
      };
      setting:
        | {
            kind: "enabled";
            authority: "observe" | "prepare" | "executeWithinPolicy";
            policyVersion: string;
          }
        | {
            kind: "disabled";
            reason: "hostChoice" | "organizerDefault";
          };
    };
