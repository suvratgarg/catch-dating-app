/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Lifecycle transition on one moment: arm (approve the rule once), pause, or resume. Scope must match the stored moment.
 */
export interface OrganizerMomentActionCallablePayload {
  scope: {
    kind: "event" | "program";
    /**
     * Required when kind=event; must be null otherwise.
     */
    eventId?: string | null;
    /**
     * Required when kind=program; must be null otherwise.
     */
    programId?: string | null;
  };
  momentId: string;
}
