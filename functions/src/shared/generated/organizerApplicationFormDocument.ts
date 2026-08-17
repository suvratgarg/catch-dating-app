/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Provider-neutral organizer-owned application form metadata. Published questions live in immutable version documents.
 */
export interface OrganizerApplicationFormDocument {
  organizerId: string;
  createdByUid: string;
  title: string;
  description: string | null;
  status: "draft" | "published" | "archived";
  defaultTargetKind: "organizer" | "event" | "campaign";
  activeVersionId: string | null;
  revision: number;
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
  archivedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
