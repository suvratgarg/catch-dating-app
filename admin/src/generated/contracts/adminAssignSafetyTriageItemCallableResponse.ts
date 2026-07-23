/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminAssignSafetyTriageItemCallableResponse {
  targetPath: string;
  assignment: {
    ownerTeam: string;
    assigneeUid: string | null;
    queue: string;
    severity: "high" | "medium" | "watch";
  };
}
