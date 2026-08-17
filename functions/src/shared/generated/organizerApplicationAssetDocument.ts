/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Metadata for a private file uploaded with an organizer application; bytes remain in protected Storage.
 */
export interface OrganizerApplicationAssetDocument {
  organizerId: string;
  applicationId: string;
  responseId: string;
  questionId: string;
  uploadedByUid: string | null;
  storagePath: string;
  originalFileName: string;
  contentType: "image/jpeg" | "image/png" | "image/webp" | "application/pdf";
  sizeBytes: number;
  sha256: string;
  status: "pendingScan" | "ready" | "rejected" | "deleted";
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  deletedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
