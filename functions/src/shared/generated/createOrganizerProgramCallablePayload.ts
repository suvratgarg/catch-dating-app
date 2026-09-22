/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Create a private wedding/corporate program. Manager-only.
 */
export interface CreateOrganizerProgramCallablePayload {
  organizerId: string;
  kind: "wedding" | "corporate" | "social" | "other";
  title: string;
  timezone: string;
  startsAtMillis: number;
  endsAtMillis: number;
  /**
   * @maxItems 8
   */
  capabilities: (
    | "arrivalsTransport"
    | "accommodation"
    | "forms"
    | "messaging"
  )[];
  transportSettings?: {
    /**
     * Anchored curb-time window used by grouping suggestions. Default 30 minutes.
     */
    bandWindowMillis: number;
    /**
     * Ceiling on how long a physically ready party waits before a group is flagged overdue. Default 10 minutes for premium events.
     */
    maxReadyWaitMillis: number;
    /**
     * Default landing-to-curb lag for domestic arrivals.
     */
    domesticExitLagMillis: number;
    /**
     * Default landing-to-curb lag for international arrivals.
     */
    internationalExitLagMillis: number;
    /**
     * Program-scoped vehicle catalog consumed by grouping suggestions; ids are unique per program.
     *
     * @maxItems 16
     */
    vehicleClasses: {
      id: string;
      label: string;
      passengerCapacity: number;
      luggageCapacity: number;
      /**
       * @maxItems 12
       */
      capabilities: ("wheelchairAccessible" | "extraLuggage" | "childSeat")[];
      sortOrder: number;
    }[];
  };
}
