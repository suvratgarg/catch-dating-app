/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Version- and draft-scoped metadata for private respondent uploads; bytes remain in protected Storage.
 */
export interface OrganizerFormAssetDocument {
  organizerId: string;
  formId: string;
  versionId: string;
  draftId: string;
  questionId: string;
  respondentUid: string | null;
  uploadTokenHash: string;
  storagePath: string;
  originalFileName: string;
  contentType: "image/jpeg" | "image/png" | "image/webp" | "application/pdf";
  declaredSizeBytes: number;
  declaredSha256: string;
  sizeBytes: number | null;
  status: "uploading" | "ready" | "rejected" | "deleted";
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
  finalizedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  deletedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
