/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned private wedding/corporate program root. Holds organizer ownership, lifecycle, enabled capabilities and transport tuning. Never publicly readable; guest logistics live in program-scoped collections.
 */
export interface OrganizerProgramDocument {
  organizerId: string;
  kind: "wedding" | "corporate" | "social" | "other";
  title: string;
  /**
   * IANA timezone identifier used for display and time-band boundaries.
   */
  timezone: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  startsAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  endsAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  status: "draft" | "active" | "completed" | "archived";
  /**
   * @maxItems 8
   */
  capabilities: (
    | "arrivalsTransport"
    | "accommodation"
    | "forms"
    | "messaging"
  )[];
  transportSettings: {
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
  createdBy: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  revision: number;
}
