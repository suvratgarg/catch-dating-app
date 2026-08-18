/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Organizer-owned source-attributed stable public form link.
 */
export interface OrganizerFormShareLinkDocument {
  organizerId: string;
  formId: string;
  publicFormId: string;
  label: string;
  source: string | null;
  tokenHash: string;
  createdByUid: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  openCount: number;
  startCount: number;
  submissionCount: number;
}
