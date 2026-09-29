/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private durable form-automation delivery outbox. The immutable intent and bounded attempt history survive dispatch interruption and delayed provider callbacks. The companion organizerMomentRuns row remains the organizer-visible journal; this record is the execution authority. Recipient endpoints are references; transport credentials stay in their own private stores.
 */
export interface AutomationDeliveryMessageDocument {
  schemaVersion: 1;
  messageId: string;
  revision: number;
  intent: {
    schemaVersion: 1;
    intentId: string;
    revision: number;
    context: {
      mode: "live";
      organizerId: string;
      ruleId: string;
      /**
       * Approved rule revision the intent was authorized under. Claim re-reads the live rule; a changed revision stops the intent as superseded.
       */
      ruleRevision: number;
      actionId: string;
      eventKind:
        | "submitted"
        | "withdrawn"
        | "applicationAccepted"
        | "eventAttended";
      sourceId: string;
      /**
       * Source-event occurrence time; part of the durable occurrence identity alongside ruleId/actionId/eventKind/sourceId.
       */
      occurredAtMillis: number;
      /**
       * The business delay horizon the automation engine computed (max(occurredAt, eventEndAt) + delayMinutes). Claim re-derives it from the live event and rule.
       */
      dueAtMillis: number;
      /**
       * Contact identity resolved from the source event at handoff. Claim re-derives the current identity from the live source event, so a merge follows the send to the surviving contact.
       */
      contactId: string;
      /**
       * organizerCampaigns document id of the recipe the action pinned.
       */
      recipeCampaignId: string;
      recipeRevision: number;
    };
    ruleId: string;
    recipient: {
      kind: "organizerContact";
      /**
       * organizerContacts document id resolved at handoff. Endpoint and consent facts resolve at claim time, never in the intent.
       */
      recipientKey: string;
    };
    workflow: {
      kind: "automationSend";
      /**
       * The rule's server-managed companion moment.
       */
      momentId: string;
      /**
       * The occurrence-keyed moment run journaling this send.
       */
      runId: string;
    };
    createdAt: number;
    expiresAt: number;
    /**
     * @minItems 1
     * @maxItems 1
     */
    permittedRoutes: "organizerWhatsappAutomation"[];
    deliveryPolicy: {
      maxAttempts: number;
      maxAttemptsPerRoute: number;
      minimumRetrySeconds: number;
    };
    kind: "automationMessage";
    /**
     * The companion moment's revision at handoff. Reservation authority expires when the synced rule projection changes.
     */
    instructionRevision: number;
    /**
     * Approved WhatsApp template content frozen at handoff, including the rendered invite variables; sender credentials never appear here.
     */
    whatsapp: {
      connectionId: string;
      templateId: string;
      variables: {
        [k: string]: string;
      };
      /**
       * Event destination pinned by the recipe; claim re-verifies the event is still active and owned.
       */
      eventId: string | null;
      /**
       * Per-occurrence invitation link minted at handoff; claim re-reads its secret so a rotated or revoked link fails closed.
       */
      inviteLinkId: string | null;
    };
  };
  lifecycle: "active" | "cancelled" | "superseded" | "responded";
  /**
   * @maxItems 6
   */
  attempts: {
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
          kind: "accepted" | "delivered" | "read";
          at: number;
          providerMessageId: string | null;
        }
      | {
          kind: "failed";
          at: number;
          providerMessageId: string | null;
          classification:
            | "technical"
            | "policy"
            | "suppressed"
            | "invalidRecipient";
          evidenceId: string | null;
        }
      | {
          kind: "revoked";
          at: number;
          providerMessageId: string | null;
          evidenceId: string | null;
        }
      | {
          kind: "notDispatched";
          at: number;
          reason:
            | "superseded"
            | "expired"
            | "permissionRevoked"
            | "reservationExpired"
            | "permitExpired"
            | "campaignEnded"
            | "recipientWithdrawn";
        };
    mode: "live";
    context: {
      mode: "live";
      organizerId: string;
      ruleId: string;
      /**
       * Approved rule revision the intent was authorized under. Claim re-reads the live rule; a changed revision stops the intent as superseded.
       */
      ruleRevision: number;
      actionId: string;
      eventKind:
        | "submitted"
        | "withdrawn"
        | "applicationAccepted"
        | "eventAttended";
      sourceId: string;
      /**
       * Source-event occurrence time; part of the durable occurrence identity alongside ruleId/actionId/eventKind/sourceId.
       */
      occurredAtMillis: number;
      /**
       * The business delay horizon the automation engine computed (max(occurredAt, eventEndAt) + delayMinutes). Claim re-derives it from the live event and rule.
       */
      dueAtMillis: number;
      /**
       * Contact identity resolved from the source event at handoff. Claim re-derives the current identity from the live source event, so a merge follows the send to the surviving contact.
       */
      contactId: string;
      /**
       * organizerCampaigns document id of the recipe the action pinned.
       */
      recipeCampaignId: string;
      recipeRevision: number;
    };
    binding: {
      routeId: "organizerWhatsappAutomation";
      transport: "whatsapp";
      senderIdentity: "organizerManaged";
      provider: "meta";
      /**
       * organizerSenderConnections document id that owns the send.
       */
      senderId: string;
      bindingRevision: number;
      recipientEndpointId: string;
      fallbackOwner: "catch";
    };
    authorization: {
      permissionRevision: string;
      checkedAt: number;
      validUntil: number;
      instructionRevision: number;
    };
  }[];
  deliveryConflict: boolean;
  createdAt: number;
  updatedAt: number;
}
