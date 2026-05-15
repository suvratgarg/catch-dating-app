/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Canonical run club document stored at runClubs/{clubId}. The club id is the document id and is not stored in document data.
 */
export interface RunClubDocument {
  name: string;
  description: string;
  location: string | null;
  area: string;
  hostUserId: string;
  hostName: string;
  hostAvatarUrl: string | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  imageUrl: string | null;
  /**
   * @maxItems 20
   */
  tags: string[];
  memberCount: number;
  rating: number;
  reviewCount: number;
  nextRunAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  nextRunLabel: string | null;
  instagramHandle: string | null;
  phoneNumber: string | null;
  email: string | null;
  status: "active" | "archived";
  archived: boolean;
  archivedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  archiveReason: string | null;
  /**
   * Internal demo seed marker used for cleanup and diagnostics.
   */
  synthetic?: boolean;
  /**
   * Internal demo seed prefix used for cleanup and diagnostics.
   */
  seedPrefix?: string;
  /**
   * Internal demo seed scenario name used for cleanup and diagnostics.
   */
  scenario?: string;
  /**
   * Internal demo-operations marker used for cleanup and diagnostics.
   */
  demoOps?: boolean;
  /**
   * Internal demo-operations id used for cleanup and diagnostics.
   */
  demoOpsId?: string;
  /**
   * Internal demo-operations command name used for cleanup and diagnostics.
   */
  demoOpsCommand?: string;
}
