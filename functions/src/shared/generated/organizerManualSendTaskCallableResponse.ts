/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-visible manual handoff task. Handoff-opened and host-marked-sent are assertions, never delivery receipts.
 */
export interface OrganizerManualSendTaskCallableResponse {
  organizerId: string;
  taskId: string;
  contactId: string;
  displayName: string;
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
  phoneE164: string;
  prefillText: string;
  openCount: number;
  createdAtMillis: number;
  updatedAtMillis: number;
  openedAtMillis: number | null;
  expiresAtMillis: number;
}
