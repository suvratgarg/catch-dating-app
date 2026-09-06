/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Sanitized durable provider event queued after signature verification. Text and native reply labels follow the existing 30-day queue and 12-month Inbox retention. Native reply identifiers and provider correlation remain in the private queue and never authorize an action by themselves. Optional fields preserve compatibility with previously queued events.
 */
export interface OrganizerMessagingWebhookEventDocument {
  provider: "metaCloudApi";
  providerEventId: string;
  organizerId: string | null;
  connectionId: string | null;
  eventKind:
    | "status"
    | "inbound"
    | "template"
    | "quality"
    | "account"
    | "unmatched";
  providerMessageId: string | null;
  contextProviderMessageId: string | null;
  providerAccountId?: string | null;
  providerPhoneNumberId?: string | null;
  callbackData?: string | null;
  inboundReply?:
    | null
    | {
        kind: "templateQuickReply";
        payload: string;
        label: string;
      }
    | {
        kind: "replyButton";
        id: string;
        label: string;
      }
    | {
        kind: "listReply";
        id: string;
        label: string;
        description: string | null;
      };
  deliveryStatus: null | "sent" | "delivered" | "read" | "failed";
  endpointHash: string | null;
  isStop: boolean;
  hasReply: boolean;
  inboundBody: string | null;
  providerErrorCode: number | null;
  providerOccurredAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  processingStatus: "pending" | "processed" | "unmatched" | "failed";
  attemptCount: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  processedAt: {
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
