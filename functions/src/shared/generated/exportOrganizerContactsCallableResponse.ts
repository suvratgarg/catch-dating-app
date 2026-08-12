/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Bounded UTF-8 CRM CSV that omits private Event Success, dating, feedback, and safety answers.
 */
export interface ExportOrganizerContactsCallableResponse {
  organizerId: string;
  fileName: string;
  csv: string;
  rowCount: number;
  truncated: boolean;
  generatedAtMillis: number;
  sourceCoverage: "exact" | "partial";
}
