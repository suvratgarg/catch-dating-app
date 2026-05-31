/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Canonical uploaded image object for ordered media galleries, logos, and event photos.
 */
export interface UploadedPhoto {
  id: string;
  url: string;
  storagePath: string;
  thumbnailUrl: string | null;
  thumbnailStoragePath: string | null;
  position: number;
  moderation?: {
    status: "pending" | "approved" | "rejected";
    reason?: string | null;
    reviewedAt?: {
      _seconds: number;
      _nanoseconds: number;
    } | null;
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
