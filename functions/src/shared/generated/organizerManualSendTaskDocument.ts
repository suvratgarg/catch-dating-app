/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * One durable host-performed external handoff. Catch may record preparation, external-app acceptance, and explicit host assertions, but never delivery or read state.
 */
export interface OrganizerManualSendTaskDocument {
  organizerId: string;
  taskId: string;
  contactId: string;
  sourceKind: "individualConversation" | "campaignRecipient";
  sourceId: string;
  intent: "individualConversation" | "savedAudienceCampaign";
  routeId: "personalWhatsappHandoff";
  deliveryMode: "byHand";
  status:
    | "queued"
    | "handoffOpened"
    | "hostMarkedSent"
    | "skipped"
    | "cancelled"
    | "superseded"
    | "expired";
  active: boolean;
  revision: number;
  idempotencyKey: string;
  requestHash: string;
  displayNameSnapshot: string;
  endpointE164Snapshot: string;
  endpointHash: string;
  permissionSnapshot: {
    whatsappStatus: "unknown" | "optedIn";
    adminSuppressed: false;
    /**
     * Serialized Firestore Timestamp fixture shape.
     */
    recordedAt: {
      _seconds: number;
      _nanoseconds: number;
    };
  };
  capabilitySnapshot: {
    version: number;
    managedRouteAvailable: boolean;
  };
  prefillText: string;
  prefillHash: string;
  openCount: number;
  createdByUid: string;
  updatedByUid: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  openedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  hostMarkedSentAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  skippedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  cancelledAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  supersededAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
