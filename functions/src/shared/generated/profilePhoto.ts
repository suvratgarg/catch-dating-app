/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

import {PhotoPromptAnswer} from "./photoPromptAnswer";

/**
 * Future canonical profile-photo object that groups display URLs, Firebase Storage object paths, prompt metadata, moderation state, order, and lifecycle timestamps.
 */
export interface ProfilePhoto {
  id: string;
  url: string;
  thumbnailUrl: string;
  storagePath: string;
  thumbnailStoragePath: string;
  prompt?: PhotoPromptAnswer | null;
  moderation?: {
    status: "pending" | "approved" | "rejected";
    reason?: string | null;
    reviewedAt?: {
      _seconds: number;
      _nanoseconds: number;
    } | null;
  } | null;
  position: number;
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
