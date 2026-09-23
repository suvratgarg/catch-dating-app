/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Bulk manifest import for a program. Preview mode plans without writing; commit mode applies idempotently via clientOperationId. Rows describe one guest and, optionally, that guest's inbound travel leg.
 */
export interface ImportProgramManifestCallablePayload {
  programId: string;
  mode: "preview" | "commit";
  clientOperationId: string;
  /**
   * @minItems 1
   * @maxItems 500
   */
  rows: {
    /**
     * Stable upstream id (CRM row id). Primary dedup key; without it, dedup falls back to displayName + flightNumber + arrival day.
     */
    externalReference?: string | null;
    displayName: string;
    phoneE164?: string | null;
    email?: string | null;
    /**
     * Matched against program households by case-insensitive label; unmatched labels create a household.
     */
    householdLabel?: string | null;
    /**
     * Ride-together travel party label; matched or created per program.
     */
    partyLabel?: string | null;
    flightNumber?: string | null;
    originIata?: string | null;
    destinationIata?: string | null;
    scheduledArrivalAtMillis?: number | null;
    international?: boolean | null;
    /**
     * Must match an existing program pickup point label; unmatched values are row errors.
     */
    pickupPointLabel?: string | null;
    /**
     * Must match an existing program hotel name; unmatched values are row errors.
     */
    destinationHotelName?: string | null;
    /**
     * Free-text destination fallback when no program hotel applies.
     */
    destinationLabel?: string | null;
    passengers?: number | null;
    luggageUnits?: number | null;
  }[];
}
