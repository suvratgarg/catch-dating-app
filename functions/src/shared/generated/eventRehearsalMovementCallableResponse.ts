/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventRehearsalMovementCallableResponse {
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
            displayName?: string | null;
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
    /**
     * @maxItems 50
     */
    accountabilityReviews?: {
      attendeeId: string;
      visitHash: string;
      sourceHash: string;
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
              | "departureNotRecorded"
              | "notOnDeparture"
              | "visitChanged"
              | "setupChanged"
              | "differentCheckpoint"
              | "destinationNotRecorded"
              | "notCheckpoint";
          };
      canResolve: boolean;
    }[];
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
  staffReview?: {
    clockId: string;
    revision: number;
    sourceHash: string;
    hostUid: string;
    actorUid: string;
    practiceOperatorId: string | null;
    serverTime: number;
    canAssign: boolean;
    /**
     * @maxItems 50
     */
    operators: {
      operatorId: string;
      displayName: string;
      /**
       * @maxItems 20
       */
      duties: {
        groupId: string;
        duty: "lead" | "pacer" | "sweep";
        expiresAtMillis: number;
        sourceHash: string;
        grantedBy: string;
        grantedAtMillis: number;
      }[];
    }[];
    /**
     * @maxItems 21
     */
    groups: {
      groupId: string;
      label: string;
      sourceHash: string;
      /**
       * @maxItems 5
       */
      permissions: (
        | "readProgress"
        | "confirmDeparture"
        | "transferGroup"
        | "recordCheckpoint"
        | "resolveAccountability"
      )[];
      validUntil: number;
      /**
       * @maxItems 3
       */
      availableDuties: ("lead" | "pacer" | "sweep")[];
    }[];
  };
}
