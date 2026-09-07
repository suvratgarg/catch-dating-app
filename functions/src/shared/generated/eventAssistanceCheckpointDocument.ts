/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceCheckpointDocument {
  schemaVersion: 1;
  reportId: string;
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  groupId: string;
  checkpointId: string;
  progressRevision: number;
  rosterId: string;
  rosterHash: string;
  revision: number;
  /**
   * @maxItems 1000
   */
  accountedFor: string[];
  reportedBy: string;
  reportedAt: number;
  correctionReason: string | null;
  createdAt: number;
}
