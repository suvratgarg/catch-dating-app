/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type EventRcsConsentReceiptDocument =
  | {
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
      sourceGeneration: string;
      actorUid: string;
      senderId: string;
      senderHash: string;
      routeId: "catchEventRcs";
      recipientEndpointId: string;
      source: "verifiedParticipant";
      permissionHash: string;
      appliedRevision: number;
      createdAt: number;
      decision: "grant";
      copyVersion: "catch-event-service-rcs-v1";
      copyHash: string;
      reviewHash: string;
      reviewedStopHash: null | string;
    }
  | {
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
      sourceGeneration: string;
      actorUid: string;
      senderId: string;
      senderHash: string;
      routeId: "catchEventRcs";
      recipientEndpointId: string;
      source: "verifiedParticipant";
      permissionHash: string;
      appliedRevision: number;
      createdAt: number;
      decision: "revoke";
      copyVersion: null;
      copyHash: null;
      reviewHash: null;
      reviewedStopHash: null;
    };
