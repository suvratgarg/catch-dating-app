/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Host-created named invite link stored at eventInviteLinks/{inviteLinkId}. The document tracks live attribution counters while preserving disabled links for historical reporting.
 */
export interface EventInviteLinkDocument {
  eventId: string;
  clubId: string;
  organizerId?: string;
  hostUid: string;
  label: string;
  source: string | null;
  tokenHash: string;
  openCount: number;
  requestCount: number;
  confirmedCount: number;
  paidCount: number;
  checkedInCount: number;
  catcherCount: number;
  matchCount: number;
  chatStartedCount: number;
  disabledAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
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
}
