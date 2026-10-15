/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-maintained organizer-scoped Host read view. Never identity, permission or mutation authority.
 */
export interface HostGroupSummaryDocument {
  organizerId: string;
  audienceId: string;
  status: "active" | "archived";
  updatedAtMillis: number;
  row: {
    organizerId: string;
    audienceId: string;
    name: string;
    status: "active" | "archived";
    isStatic: boolean;
    revision: number;
    lastPreviewMatchCount: number | null;
    lastPreviewAtMillis: number | null;
    updatedAtMillis: number;
  };
  version: 1;
  searchName: string;
  isStatic: boolean;
  lastPreviewAtMillis: number;
}
