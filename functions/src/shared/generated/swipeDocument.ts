/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Current storage contract for contextual profile decisions stored at swipes/{userId}/outgoing/{targetId}.
 */
export interface SwipeDocument {
  swiperId: string;
  targetId: string;
  runId: string;
  direction: "like" | "pass";
  reactionTargetId?: string | null;
  reactionTargetType?:
    | "heroPhoto"
    | "photo"
    | "profilePrompt"
    | "compatibility"
    | "running"
    | "details"
    | "lifestyle"
    | null;
  reactionTargetLabel?: string | null;
  reactionTargetPreview?: string | null;
  comment?: string | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
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
