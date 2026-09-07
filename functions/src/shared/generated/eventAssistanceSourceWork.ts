/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private bounded source-change fanout using Operations work items. Waking work grants no domain or provider authority.
 */
export interface EventAssistanceSourceWork {
  schemaVersion: 1;
  kind: "liveSourceWake";
  signalId: string;
  source: {
    eventId: string;
    collection:
      | "events"
      | "eventAttendees"
      | "eventSuccessPlans"
      | "eventAssistanceGuests"
      | "eventAssistanceSettings"
      | "eventAssistanceGroupProgress"
      | "eventAssistanceMemberships"
      | "eventAssistanceMessages"
      | "eventAssistanceRuntimeConfigs"
      | "eventAssistanceSmsPermissions"
      | "eventAssistanceWhatsappPermissions"
      | "eventAssistanceSmsSenders"
      | "eventAssistanceSmsBudgets"
      | "organizerSenderConnections"
      | "eventAssistanceWhatsappPolicies"
      | "organizerMessageTemplates"
      | "eventAssistanceWhatsappBudgets"
      | "organizerWhatsappEndpointStops"
      | "organizerContactChannelStates";
    documentId: string;
    occurredAt: number;
  };
  scope:
    | {
        context: {
          mode: "live";
          eventId: string;
          organizerId: string;
        };
        attendeeId: string | null;
      }
    | {
        kind: "sender";
        routeId: "catchEventSms" | "organizerEventWhatsapp";
        senderId: string;
      }
    | {
        kind: "whatsappEndpoint";
        organizerId: string;
        recipientEndpointId: string;
      };
  expiresAt: number;
  checkpoint: {
    phase: "scan" | "retry" | "complete" | "review" | "expired";
    cursor: string | null;
    visited: number;
    dueAt: number | null;
    /**
     * @maxItems 100
     */
    failures: (
      | {
          workItemId: string;
          reason: "busy" | "unavailable";
        }
      | {
          targetKey: string;
          reason: "busy" | "unavailable";
        }
    )[];
    retries: number;
  };
}
