/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Canonical organizer post stored at organizers/{organizerId}/posts/{postId}.
 */
export interface OrganizerPostDocument {
  authorUid: string;
  text: string;
  photoPath?: string | null;
  eventId?: string | null;
  audience: "followers";
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  status: "active" | "removed";
}
