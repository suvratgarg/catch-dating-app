/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AutomationDeliveryAttempt {
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
}
