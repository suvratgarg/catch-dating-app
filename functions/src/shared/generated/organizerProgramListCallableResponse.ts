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
    /**
     * IANA timezone used to recover the Program's civil calendar dates from its stored instants.
     */
    timezone: string;
    startsAtMillis: number;
    endsAtMillis: number;
    capabilities: (
      | "arrivalsTransport"
      | "accommodation"
      | "forms"
      | "messaging"
    )[];
    /**
     * Exact count of constituent program events for a completely read authorized batch. Omitted when unavailable or the bounded batch is incomplete; absence never means zero.
     */
    functionCount?: number;
    revision: number;
    /**
     * Set when the program is archived; null otherwise.
     */
    archivedAtMillis?: number | null;
    /**
     * Grace deadline after which identity fields are scrubbed.
     */
    anonymizeAtMillis?: number | null;
    /**
     * Set once identity/free-text fields were scrubbed.
     */
    anonymizedAtMillis?: number | null;
  }[];
  /**
   * Opaque stable cursor for the last returned startsAt/program-ID tuple when another page exists, otherwise null. Optional for legacy readers.
   */
  nextCursor?: string | null;
}
