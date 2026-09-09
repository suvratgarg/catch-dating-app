/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type EventRcsPermissionDocument =
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
      sourceGeneration: string;
      subjectUid: string;
      senderId: string;
      sender: {
        agentId: string;
        displayName: string;
      };
      routeId: "catchEventRcs";
      purpose: "eventService";
      phoneE164: string;
      recipientEndpointId: string;
      currentReceiptId: string;
      expiresAt: number;
      updatedAt: number;
      status: "granted";
      evidence: {
        receiptId: string;
        copyVersion: "catch-event-service-rcs-v1";
        acceptedAt: number;
        phoneVerifiedAt: number;
        reviewHash: string;
        senderHash: string;
        reviewedStopHash: null | string;
      };
      /**
       * Derived agent and phone conversation key for bounded STOP discovery; covered by the immutable permission receipt.
       */
      subscriptionId: string;
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
      sourceGeneration: string;
      subjectUid: string;
      senderId: string;
      sender: {
        agentId: string;
        displayName: string;
      };
      routeId: "catchEventRcs";
      purpose: "eventService";
      phoneE164: string;
      recipientEndpointId: string;
      currentReceiptId: string;
      expiresAt: number;
      updatedAt: number;
      status: "revoked";
      evidence: null | {
        receiptId: string;
        copyVersion: "catch-event-service-rcs-v1";
        acceptedAt: number;
        phoneVerifiedAt: number;
        reviewHash: string;
        senderHash: string;
        reviewedStopHash: null | string;
      };
      /**
       * Derived agent and phone conversation key for bounded STOP discovery; covered by the immutable permission receipt.
       */
      subscriptionId: string;
    };
