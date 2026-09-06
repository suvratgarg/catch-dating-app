/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventWhatsappConsentReceiptDocument {
  schemaVersion: 1;
  receiptId: string;
  requestHash: string;
  context: {
    mode: "live";
    organizerId: string;
    eventId: string;
  };
  attendeeId: string;
  attendeeGeneration: string;
  senderId: string;
  routeId: "organizerEventWhatsapp";
  actorUid: string;
  recipientEndpointId: string;
  decision: "grant" | "revoke";
  copyVersion: null | "catch-event-service-whatsapp-v1";
  copyHash: null | string;
  appliedRevision: number;
  createdAt: number;
  permissionHash: string;
  source: "verifiedParticipant";
  linkId: null;
  senderHash: string;
}
