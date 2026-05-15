/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Tool-owned synthetic-data manifest stored at seedRuns/{manifestId}.
 */
export interface SeedRunManifestDocument {
  seedId: string;
  manifestId: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  generatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  anchorUserIds: string[];
  counts: {
    [k: string]: number;
  };
  paths: string[];
  appendMode?: boolean;
  appendedAnchorUserIds?: string[];
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
