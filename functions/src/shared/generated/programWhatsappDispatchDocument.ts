/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private claim-time binding between one program delivery attempt and the exact Meta WhatsApp submission. Webhook status callbacks verify against this record before a receipt can merge into the program delivery outbox.
 */
export interface ProgramWhatsappDispatchDocument {
  schemaVersion: 1;
  attemptId: string;
  messageId: string;
  context: {
    mode: "live";
    programId: string;
    organizerId: string;
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
