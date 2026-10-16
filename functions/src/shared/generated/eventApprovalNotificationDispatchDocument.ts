/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private immutable approval WhatsApp dispatch correlation, created atomically with its shared outbox claim.
 */
export interface EventApprovalNotificationDispatchDocument {
  schemaVersion: 1;
  attemptId: string;
  messageId: string;
  context: {
    mode: "live";
    applicationId: string;
    organizerId: string;
    eventId: string;
    uid: string;
    sourceResponseId: string;
    approvedAtMillis: number;
    approvalRevision: number;
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
