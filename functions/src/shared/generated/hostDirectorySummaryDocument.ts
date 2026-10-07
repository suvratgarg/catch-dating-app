/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {GetOrganizerCrmSummaryCallableResponse} from "./getOrganizerCrmSummaryCallableResponse";

/**
 * Server-maintained organizer-scoped Host read view. Never identity, permission or mutation authority.
 */
export interface HostDirectorySummaryDocument {
  organizerId: string;
  contactSummaryVersion: number;
  segmentCounts: {
    [k: string]: number;
  };
  summary: GetOrganizerCrmSummaryCallableResponse;
  /**
   * @maxItems 20
   */
  manualTagVocabulary: {
    tagId: string;
    label: string;
  }[];
  sourceCoverage: "exact" | "partial";
  projectionVersion: number;
}
