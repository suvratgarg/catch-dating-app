/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * List all moments for one event or program scope.
 */
export interface ListOrganizerMomentsCallablePayload {
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
}
