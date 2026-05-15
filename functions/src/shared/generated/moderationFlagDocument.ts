/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Canonical moderation ticket stored at moderationFlags/{flagId}.
 */
export interface ModerationFlagDocument {
  targetUserId: string;
  flagType: "explicit_photo" | "banned_text" | "underage_content";
  source:
    | "profile_photo"
    | "club_image"
    | "chat_message"
    | "user_bio"
    | "club_description"
    | "review_comment";
  status: "pending" | "reviewed" | "dismissed";
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
  reviewedAt?: {
    _seconds: number;
    _nanoseconds: number;
  };
  contextId?: string;
  context?: string;
  safeSearchResults?: {
    [k: string]: string;
  };
}
