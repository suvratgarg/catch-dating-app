/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private durable campaign delivery outbox. The immutable intent and bounded attempt history survive dispatch interruption and delayed provider callbacks. The organizerCampaignRecipients row remains the CRM/report mirror; this record is the execution authority. Recipient endpoints are references; transport credentials stay in their own private stores.
 */
export interface CampaignDeliveryMessageDocument {
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
      campaignId: string;
      recipientId: string;
    };
    campaignId: string;
    recipient: {
      kind: "campaignRecipient";
      /**
       * organizerCampaignRecipients document id — the frozen per-recipient campaign row. Endpoint and consent facts resolve at claim time, never in the intent.
       */
      recipientKey: string;
    };
    workflow: {
      kind: "campaignDispatch";
      campaignId: string;
      recipientId: string;
    };
    createdAt: number;
    expiresAt: number;
    /**
     * @minItems 1
     * @maxItems 1
     */
    permittedRoutes: "organizerWhatsappCampaign"[];
    deliveryPolicy: {
      maxAttempts: number;
      maxAttemptsPerRoute: number;
      minimumRetrySeconds: number;
    };
    kind: "campaignMessage";
    /**
     * The campaign dispatch epoch (dispatchedAt millis) this intent was issued under. Reservation authority expires when the campaign's dispatch epoch changes.
     */
    instructionRevision: number;
    /**
     * Approved WhatsApp template content frozen from the campaign/recipient snapshot; sender credentials never appear here.
     */
    whatsapp: {
      connectionId: string;
      templateId: string;
      variables: {
        [k: string]: string;
      };
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
      campaignId: string;
      recipientId: string;
    };
    binding: {
      routeId: "organizerWhatsappCampaign";
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
