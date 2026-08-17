/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Organizer-scoped application review summary with no provider-specific answer shape.
 */
export interface OrganizerApplicationDocument {
  organizerId: string;
  formId: string;
  formVersionId: string;
  targetKind: "organizer" | "event" | "campaign";
  targetId: string | null;
  linkedUid: string | null;
  contactId: string | null;
  applicantDisplayName: string;
  applicantDisplayNameNormalized: string;
  reviewStatus:
    | "submitted"
    | "inReview"
    | "approved"
    | "waitlisted"
    | "declined"
    | "withdrawn";
  latestResponseId: string;
  source: {
    kind: "native" | "tabularImport" | "connector";
    providerId: string | null;
    externalFormId: string | null;
    externalResponseId: string | null;
    importReceiptId: string | null;
  };
  assignedReviewerUid: string | null;
  reviewNote: string | null;
  revision: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  submittedAt: {
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
  reviewedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
