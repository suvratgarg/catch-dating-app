/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Create or update a private program function (ceremony, reception, session).
 */
export interface UpsertProgramFunctionCallablePayload {
  programId: string;
  functionId?: string;
  expectedRevision?: number;
  name: string;
  startsAtMillis: number;
  endsAtMillis: number;
  venueName: string;
  venueNotes?: string | null;
  status?: "scheduled" | "completed" | "cancelled";
}
