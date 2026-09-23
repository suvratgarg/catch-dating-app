/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Patch program fields. Omitted fields are unchanged; expectedRevision fences concurrent edits.
 */
export interface UpdateOrganizerProgramCallablePayload {
  programId: string;
  expectedRevision: number;
  title?: string;
  timezone?: string;
  startsAtMillis?: number;
  endsAtMillis?: number;
  status?: "draft" | "active" | "completed" | "archived";
  /**
   * @maxItems 8
   */
  capabilities?: (
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
