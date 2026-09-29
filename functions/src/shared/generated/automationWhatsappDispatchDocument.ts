/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private claim-time binding between one automation delivery attempt and the exact Meta WhatsApp submission. Webhook status callbacks verify against this record before a receipt can merge into the automation delivery outbox.
 */
export interface AutomationWhatsappDispatchDocument {
  schemaVersion: 1;
  attemptId: string;
  messageId: string;
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
  /**
   * organizerSenderConnections document id that owned the send.
   */
  senderId: string;
  bindingRevision: number;
  providerAccountId: string;
  providerPhoneNumberId: string;
  /**
   * Content hash of the sender connection snapshot authorized at claim.
   */
  senderHash: string;
  recipientEndpointId: string;
  /**
   * Hash of the E.164 destination; the raw number never appears here.
   */
  endpointHash: string;
  templateDocumentId: string;
  templateHash: string;
  /**
   * Content hash of the rendered template + variables; the status callback must carry the matching correlation.
   */
  payloadHash: string;
  createdAt: number;
}
