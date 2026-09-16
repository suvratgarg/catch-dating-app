/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {EventAssistanceLateJoinDecision} from "./eventAssistanceLateJoinDecision";

export interface EventAssistanceHostGuestsCallableResponse {
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  serverTime: number;
  coverage: "selectedAttendees";
  workflow: "lateJoin";
  runtimeStatus:
    | "unconfigured"
    | "paused"
    | "sourceChanged"
    | "expired"
    | "eventClosed"
    | "configured";
  /**
   * @minItems 1
   * @maxItems 50
   */
  guests: (
    | {
        kind: "unavailable";
        attendeeId: string;
      }
    | {
        kind: "ineligible";
        attendeeId: string;
        rosterStatus: "invited" | "waitlisted" | "cancelled";
      }
    | {
        kind: "uninitialized";
        attendeeId: string;
        checkedIn: boolean;
      }
    | {
        kind: "sourceChanged";
        attendeeId: string;
        checkedIn: boolean;
      }
    | {
        kind: "current";
        attendeeId: string;
        checkedIn: boolean;
        episodeId: string;
        participation:
          | {
              state: "active";
              resumeAtUnit: null;
            }
          | {
              state: "temporaryBreak";
              resumeAtUnit: string | null;
            }
          | {
              state: "departed";
              resumeAtUnit: null;
            };
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
        work:
          | {
              kind: "notEnrolled";
            }
          | {
              kind: "recorded";
              revision: number;
              runStatus: "running" | "paused" | "completed";
              configurationBinding:
                | "current"
                | "unbound"
                | "configurationChanged";
              expiresAt: number;
              nextEvaluationAt: number | null;
              lastEvaluation: {
                at: number;
                observation:
                  | {
                      kind: "decision";
                      decision: EventAssistanceLateJoinDecision;
                    }
                  | {
                      kind: "sourceNotReady";
                      reason:
                        | "episodeMissing"
                        | "guestSourceChanged"
                        | "membershipMissing"
                        | "membershipSourceChanged"
                        | "unconfigured"
                        | "disabled"
                        | "settingSourceChanged"
                        | "eventClosed"
                        | "runtimeNotLive"
                        | "progressUnconfirmed"
                        | "progressSourceChanged"
                        | "destinationUnavailable";
                    }
                  | {
                      kind: "historyUnavailable";
                      reason:
                        | "historyLimit"
                        | "deliveryConflict"
                        | "ambiguousHistory";
                    }
                  | {
                      kind: "responseDeadlineMissing";
                    }
                  | {
                      kind: "episodeChanged";
                    }
                  | {
                      kind: "workExpired";
                    }
                  | {
                      kind: "evaluationLimit";
                    }
                  | {
                      kind: "runtimeUnavailable";
                      reason:
                        | "missing"
                        | "paused"
                        | "configurationChanged"
                        | "sourceChanged"
                        | "expired"
                        | "eventClosed";
                    };
              } | null;
              publishedIntentCount: number;
            };
      }
  )[];
}
