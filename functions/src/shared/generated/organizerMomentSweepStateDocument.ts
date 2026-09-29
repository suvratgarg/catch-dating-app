/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned pagination state for the moment sweep. The armed-moments scan advances a durable cursor so discovery stays bounded at any armed-moment count.
 */
export interface OrganizerMomentSweepStateDocument {
  sweepId: string;
  /**
   * Last armed-moment doc id scanned; null restarts the scan.
   */
  afterMomentId: string | null;
  updatedAtMillis: number;
}
