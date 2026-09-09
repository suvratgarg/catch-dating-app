/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type EventAssistanceSmsPermissionDocument =
  | {
      schemaVersion: 1;
      permissionId: string;
      revision: number;
      context: {
        mode: "live";
        organizerId: string;
        eventId: string;
      };
      attendeeId: string;
      attendeeGeneration: string;
      senderId: string;
      routeId: "catchEventSms";
      purpose: "eventService";
      phoneE164: string;
      recipientEndpointId: string;
      status: "granted";
      evidence: {
        receiptId: string;
        copyVersion: "catch-event-service-sms-v1";
        acceptedAt: number;
        phoneVerifiedAt: number;
        subjectUid: string;
      };
      expiresAt: number;
      updatedAt: number;
      currentReceiptId: string;
    }
  | {
      schemaVersion: 1;
      permissionId: string;
      revision: number;
      context: {
        mode: "live";
        organizerId: string;
        eventId: string;
      };
      attendeeId: string;
      attendeeGeneration: string;
      senderId: string;
      routeId: "catchEventSms";
      purpose: "eventService";
      phoneE164: string;
      recipientEndpointId: string;
      status: "revoked";
      evidence: null | {
        receiptId: string;
        copyVersion: "catch-event-service-sms-v1";
        acceptedAt: number;
        phoneVerifiedAt: number;
        subjectUid: string;
      };
      expiresAt: number;
      updatedAt: number;
      currentReceiptId: string;
    };
