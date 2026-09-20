/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Read-only operator review of one event messaging runtime, sender and its two spending ceilings. This artifact grants no dispatch or spending authority.
 */
export interface EventMessagingSetupReview {
  schemaVersion: 1;
  kind: "recordedSetupReview";
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  routeId: "catchEventSms" | "catchEventRcs" | "organizerEventWhatsapp";
  senderId: string;
  purpose:
    | "joiningUpdate"
    | "joiningInstructions"
    | "planChanged"
    | "eventCancelled"
    | "eventFinished"
    | "guestRequirement"
    | "assignmentChanged"
    | "participationCheck"
    | "followUp";
  observedAt: number;
  completedAt: number;
  grantsDispatchAuthority: false;
  runtime: {
    appliesToPurpose: boolean;
    status:
      | "unconfigured"
      | "paused"
      | "sourceChanged"
      | "expired"
      | "eventClosed"
      | "configured";
    revision: number | null;
    selected: boolean;
    sourceHash: string;
    eventEnd: number;
  };
  sender: {
    routeId: "catchEventSms" | "catchEventRcs" | "organizerEventWhatsapp";
    senderId: string;
    displayName: string;
    displayAddress: string | null;
    availability:
      | "eligible"
      | "setupRequired"
      | "approvalExpired"
      | "templateUnavailable";
    reviewHash: string;
  } | null;
  budgets:
    | {
        kind: "senderUnavailable";
      }
    | {
        kind: "reviewed";
        currency: string;
        sourceHash: string;
        event:
          | {
              budgetId: string;
              scope:
                | {
                    kind: "event";
                    context: {
                      mode: "live";
                      eventId: string;
                      organizerId: string;
                    };
                  }
                | {
                    kind: "senderDay";
                    day: string;
                  };
              kind: "unavailable";
              reason: "missing" | "invalid";
            }
          | {
              budgetId: string;
              scope:
                | {
                    kind: "event";
                    context: {
                      mode: "live";
                      eventId: string;
                      organizerId: string;
                    };
                  }
                | {
                    kind: "senderDay";
                    day: string;
                  };
              kind: "recorded";
              issue:
                | "paused"
                | "expired"
                | "currencyChanged"
                | "agentChanged"
                | "exhausted"
                | null;
              revision: number;
              approvalId: string;
              currency: string;
              limitMicros: number;
              chargedMicros: number;
              remainingMicros: number;
              startsAt: number;
              endsAt: number;
              reviewHash: string;
            };
        senderDay:
          | {
              budgetId: string;
              scope:
                | {
                    kind: "event";
                    context: {
                      mode: "live";
                      eventId: string;
                      organizerId: string;
                    };
                  }
                | {
                    kind: "senderDay";
                    day: string;
                  };
              kind: "unavailable";
              reason: "missing" | "invalid";
            }
          | {
              budgetId: string;
              scope:
                | {
                    kind: "event";
                    context: {
                      mode: "live";
                      eventId: string;
                      organizerId: string;
                    };
                  }
                | {
                    kind: "senderDay";
                    day: string;
                  };
              kind: "recorded";
              issue:
                | "paused"
                | "expired"
                | "currencyChanged"
                | "agentChanged"
                | "exhausted"
                | null;
              revision: number;
              approvalId: string;
              currency: string;
              limitMicros: number;
              chargedMicros: number;
              remainingMicros: number;
              startsAt: number;
              endsAt: number;
              reviewHash: string;
            };
      };
}
