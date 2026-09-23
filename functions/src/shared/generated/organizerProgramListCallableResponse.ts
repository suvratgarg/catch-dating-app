/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager's program inventory: summaries only, no guest or logistics data.
 */
export interface OrganizerProgramListCallableResponse {
  /**
   * @maxItems 50
   */
  programs: {
    programId: string;
    kind: "wedding" | "corporate" | "social" | "other";
    title: string;
    status: "draft" | "active" | "completed" | "archived";
    startsAtMillis: number;
    endsAtMillis: number;
    capabilities: (
      | "arrivalsTransport"
      | "accommodation"
      | "forms"
      | "messaging"
    )[];
    revision: number;
  }[];
}
