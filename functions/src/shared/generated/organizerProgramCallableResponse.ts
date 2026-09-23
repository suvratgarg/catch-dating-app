/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-facing program detail: settings, resources and coverage counts. No guest rows.
 */
export interface OrganizerProgramCallableResponse {
  program: {
    programId: string;
    kind: "wedding" | "corporate" | "social" | "other";
    title: string;
    timezone: string;
    status: "draft" | "active" | "completed" | "archived";
    startsAtMillis: number;
    endsAtMillis: number;
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
    revision: number;
  };
  /**
   * @maxItems 40
   */
  functions: {
    functionId: string;
    name: string;
    startsAtMillis: number;
    endsAtMillis: number;
    venueName: string;
    status: "scheduled" | "completed" | "cancelled";
  }[];
  /**
   * @maxItems 32
   */
  pickupPoints: {
    pickupPointId: string;
    kind: "airport" | "railway" | "venue" | "other";
    label: string;
    iataCode?: string | null;
    terminal?: string | null;
    meetingZone?: string | null;
    instructions?: string | null;
    active: boolean;
    revision: number;
  }[];
  /**
   * @maxItems 64
   */
  hotels: {
    hotelId: string;
    name: string;
    address: string;
    receptionContact?: string | null;
    active: boolean;
    revision: number;
  }[];
  counts: {
    guests: number;
    households: number;
    inboundLegs: number;
    activeStaff: number;
  };
}
