/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Lists bounded organizer form summaries using an opaque cursor.
 */
export interface ListOrganizerFormsCallablePayload {
  organizerId: string;
  /**
   * @maxItems 4
   */
  statuses: ("draft" | "published" | "paused" | "archived")[];
  /**
   * @maxItems 6
   */
  purposes: (
    | "application"
    | "registration"
    | "intake"
    | "waiver"
    | "feedback"
    | "survey"
  )[];
  query: string | null;
  cursor: string | null;
  limit: number;
}
