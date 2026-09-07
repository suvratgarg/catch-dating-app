/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type EventAssistanceCommand =
  | {
      kind: "confirmDeparture";
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
      operationId: string;
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
      };
    }
  | {
      kind: "setJoinIntent";
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
      operationId: string;
      payload: {
        attendeeId: string;
        intent:
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
        episodeId: string;
        expectedParticipationRevision: number;
      };
    }
  | {
      kind: "checkInGuest";
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
      operationId: string;
      payload: {
        attendeeId: string;
        checkedIn: boolean;
        /**
         * Nonnegative safe integer revision.
         */
        expectedAttendanceRevision: number;
      };
    }
  | {
      kind: "publishGuidance";
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
      operationId: string;
      payload: {
        attendeeId: string;
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
      };
    }
  | {
      kind: "sendOperationalMessage";
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
      operationId: string;
      payload: {
        attendeeId: string;
        /**
         * Nonnegative safe integer revision.
         */
        guidanceRevision: number;
        intent: "joining" | "planChange" | "followUp";
        /**
         * UTC milliseconds.
         */
        expiresAt: number;
      };
    }
  | {
      kind: "openHostCase";
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
      operationId: string;
      payload: {
        attendeeId: string | null;
        reason:
          | "unreachable"
          | "entryDecision"
          | "missingInformation"
          | "assistance"
          | "accountability";
        owner: "eventLead" | "groupLead" | "sweep";
      };
    }
  | {
      kind: "setParticipation";
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
      operationId: string;
      payload: {
        attendeeId: string;
        state: "active" | "temporaryBreak" | "departed";
        resumeAtUnit: string | null;
      };
    }
  | {
      kind: "proposeAllocation";
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
      operationId: string;
      payload: {
        /**
         * @minItems 1
         * @maxItems 1000
         */
        attendeeIds: string[];
        targetUnitId: string;
        /**
         * Nonnegative safe integer revision.
         */
        expectedAllocationRevision: number;
      };
    }
  | {
      kind: "publishAllocation";
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
      operationId: string;
      payload: {
        proposalId: string;
        decisionId: string;
      };
    }
  | {
      kind: "confirmPlacement";
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
      operationId: string;
      payload: {
        attendeeId: string;
        resourceId: string;
        /**
         * Nonnegative safe integer revision.
         */
        expectedAssignmentRevision: number;
      };
    }
  | {
      kind: "changeResource";
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
      operationId: string;
      payload: {
        resourceId: string;
        status: "available" | "unavailable";
        decisionId: string;
      };
    }
  | {
      kind: "transferGroup";
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
      operationId: string;
      payload: {
        attendeeId: string;
        from: string;
        to: string;
        receivingOperatorId: string;
      };
    }
  | {
      kind: "recordCheckpoint";
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
      operationId: string;
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
      };
    }
  | {
      kind: "changeProgramme";
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
      operationId: string;
      payload: {
        changeId: string;
        action: "pause" | "resume" | "extend" | "skip" | "reorder";
        decisionId: string;
      };
    }
  | {
      kind: "recordOutcome";
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
      operationId: string;
      payload: {
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
        /**
         * Nonnegative safe integer revision.
         */
        expectedOutcomeRevision: number;
      };
    }
  | {
      kind: "changeRoute";
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
      operationId: string;
      payload: {
        /**
         * Nonnegative safe integer revision.
         */
        routeRevision: number;
        alternativeId: string;
        decisionId: string;
      };
    }
  | {
      kind: "resolveAccountability";
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
      operationId: string;
      payload: {
        attendeeId: string;
        episodeId: string;
        disposition: "returned" | "departed" | "unresolved";
      };
    }
  | {
      kind: "resolveClaim";
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
      operationId: string;
      payload: {
        claimId: string;
        outcome:
          | {
              kind: "link";
              attendeeId: string;
            }
          | {
              kind: "reject";
              reason: string;
            };
      };
    }
  | {
      kind: "admitGuest";
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
      operationId: string;
      payload: {
        attendeeId: string;
        entitlementDecisionId: string;
      };
    }
  | {
      kind: "assignResponsibility";
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
      operationId: string;
      payload: {
        operatorId: string;
        role: "lead" | "checkIn" | "pacer" | "sweep" | "marshal";
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
      };
    }
  | {
      kind: "resolveAssistance";
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
      operationId: string;
      payload: {
        caseId: string;
        outcome: "resolved" | "declined" | "transferred";
        owner: string;
      };
    }
  | {
      kind: "reconcileAttendance";
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
      operationId: string;
      payload: {
        attendeeId: string;
        /**
         * Nonnegative safe integer revision.
         */
        expectedAttendanceRevision: number;
      };
    }
  | {
      kind: "requestRequiredData";
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
      operationId: string;
      payload: {
        attendeeId: string;
        /**
         * @minItems 1
         * @maxItems 1000
         */
        fieldIds: string[];
        /**
         * UTC milliseconds.
         */
        expiresAt: number;
      };
    }
  | {
      kind: "reconcileRoster";
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
      operationId: string;
      payload: {
        sourceId: string;
        /**
         * Nonnegative safe integer revision.
         */
        sourceRevision: number;
      };
    }
  | {
      kind: "reconcileFinance";
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
      operationId: string;
      payload: {
        providerCaseId: string;
      };
    }
  | {
      kind: "repairDelivery";
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
      operationId: string;
      payload: {
        deliveryId: string;
        action: "reconcile" | "retryDefiniteFailure" | "manualHandoff";
      };
    }
  | {
      kind: "resumeOperation";
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
      operationId: string;
      payload: {
        instanceId: string;
        /**
         * Nonnegative safe integer revision.
         */
        expectedRevision: number;
      };
    }
  | {
      kind: "completeEvent";
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
      operationId: string;
      payload: {
        decisionId: string;
        disposition: "completed" | "aborted";
        /**
         * @maxItems 1000
         */
        unresolvedCaseIds: string[];
      };
    }
  | {
      kind: "controlUnitProgress";
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
      operationId: string;
      payload: {
        unitId: string;
        progress: "ready" | "active" | "paused" | "completed";
        /**
         * Nonnegative safe integer revision.
         */
        expectedRevision: number;
      };
    }
  | {
      kind: "controlReveal";
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
      operationId: string;
      payload: {
        action: "startCountdown" | "cancelPending" | "publish";
        /**
         * Nonnegative safe integer revision.
         */
        expectedLiveRevision: number;
        decisionId: string;
      };
    }
  | {
      kind: "applyOverride";
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
      operationId: string;
      payload: {
        constraintId: string;
        ruleKind: "softPreference" | "overrideableOperatingRule";
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
        reason: string;
        /**
         * UTC milliseconds.
         */
        expiresAt: number;
        decisionId: string;
      };
    }
  | {
      kind: "setLocationSharing";
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
      operationId: string;
      payload: {
        operatorId: string;
        enabled: boolean;
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
      };
    }
  | {
      kind: "requestCheckpointReport";
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
      operationId: string;
      payload: {
        groupId: string;
        checkpointId: string;
        /**
         * UTC milliseconds.
         */
        dueAt: number;
      };
    }
  | {
      kind: "recordNoShow";
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
      operationId: string;
      payload: {
        attendeeId: string;
        evidence: "guestDeclined" | "hostConfirmed";
        decisionId: string;
      };
    }
  | {
      kind: "routeRestrictedCase";
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
      operationId: string;
      payload: {
        restrictedCaseId: string;
        operationalNeed: "separation" | "pause" | "assistance";
      };
    }
  | {
      kind: "resolveRestrictedCase";
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
      operationId: string;
      payload: {
        restrictedCaseId: string;
        resolutionId: string;
      };
    };
