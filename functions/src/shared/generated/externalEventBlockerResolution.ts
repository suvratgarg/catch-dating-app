/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * One explicit, event-scoped resolution or policy-backed waiver for a governed external-event import blocker.
 */
export type ExternalEventBlockerResolution = {
  [k: string]: unknown;
} & {
  blockerCode:
    | "missing_exact_coordinates"
    | "missing_end_time"
    | "missing_location_detail"
    | "requires_event_defaults_policy"
    | "requires_owner_safe_copy_review"
    | "duplicate_normalized_event_key";
  outcome: "resolved" | "waived";
  policyGapDecisionId: string | null;
  note: string;
};
