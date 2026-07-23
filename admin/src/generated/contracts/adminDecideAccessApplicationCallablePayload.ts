/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminDecideAccessApplicationCallablePayload {
  applicationUid: string;
  decision: "approve" | "deny";
  note: string;
  cohortId?: string | null;
}
