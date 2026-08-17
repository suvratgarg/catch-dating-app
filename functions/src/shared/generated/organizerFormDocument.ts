/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Organizer-owned generic form metadata and lifecycle. Editable content lives in a draft and published content in immutable versions.
 */
export interface OrganizerFormDocument {
  organizerId: string;
  createdByUid: string;
  title: string;
  description: string | null;
  purpose:
    | "application"
    | "registration"
    | "intake"
    | "waiver"
    | "feedback"
    | "survey";
  status: "draft" | "published" | "paused" | "archived";
  templateId: string | null;
  publicFormId: string;
  defaultTargetKind: "organizer" | "event" | "campaign";
  defaultTargetId: string | null;
  activeVersionId: string | null;
  draftRevision: number;
  publishedVersion: number;
  submittedResponseCount: number;
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
  publishedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  pausedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  archivedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  lastResponseAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
