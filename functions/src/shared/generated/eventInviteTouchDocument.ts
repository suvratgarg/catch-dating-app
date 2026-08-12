/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Short-lived privacy-minimized evidence that an invitation URL was resolved.
 */
export interface EventInviteTouchDocument {
  eventId: string;
  organizerId: string;
  inviteLinkId: string;
  touchKind: "open" | "redirect";
  surface:
    | "consumerApp"
    | "hostApp"
    | "runtimeWeb"
    | "marketingWeb"
    | "unknown";
  actorUid: string | null;
  sessionHash: string | null;
  likelyHuman: boolean;
  botReason: "previewCrawler" | "knownBot" | "missingClientSignal" | null;
  attributionEligible: boolean;
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
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
