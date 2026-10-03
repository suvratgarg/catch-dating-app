/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private event lodging setup referencing canonical program guest/group/hotel/room-block IDs. Contains explicit demand and sharing choices, exact or provisional inventory, and verified layered 2D facts; no copied contact records or public hotel catalog.
 */
export interface ProgramLodgingConfigDocument {
  programId: string;
  organizerId: string;
  revision: number;
  /**
   * @maxItems 500
   */
  demand: {
    guestId: string;
    startsAtMillis: number;
    endsAtMillis: number;
    beds: number;
    /**
     * @maxItems 30
     */
    requiredFeatures: string[];
  }[];
  /**
   * @maxItems 500
   */
  parties: {
    id: string;
    /**
     * @minItems 1
     * @maxItems 100
     */
    guestIds: string[];
    confirmed: boolean;
    priority: number;
    requiredRoomType: string | null;
    pin: {
      inventoryId?: string;
      hotelId?: string;
      zoneId?: string;
    } | null;
  }[];
  /**
   * @maxItems 500
   */
  groupParents: {
    id: string;
    /**
     * @maxItems 20
     */
    parentIds: string[];
  }[];
  /**
   * @maxItems 500
   */
  rooms: {
    id: string;
    hotelId: string;
    zoneId: string;
    building: string | null;
    floor: string | null;
    wing: string | null;
    roomType: string;
    beds: number;
    maxOccupants: number;
    /**
     * @maxItems 30
     */
    verifiedFeatures: string[];
    /**
     * @minItems 1
     * @maxItems 100
     */
    resourceIds: string[];
    position: {
      x: number;
      y: number;
    } | null;
  }[];
  /**
   * @maxItems 500
   */
  inventory: {
    id: string;
    contractId: string;
    physicalRoomId: string | null;
    provisional: {
      hotelId: string;
      zoneId: string;
      building: string | null;
      floor: string | null;
      wing: string | null;
      roomType: string;
      beds: number;
      maxOccupants: number;
      /**
       * @maxItems 30
       */
      verifiedFeatures: string[];
    } | null;
    /**
     * @minItems 1
     * @maxItems 30
     */
    availability: {
      arrival: string;
      departure: string;
    }[];
  }[];
  /**
   * @maxItems 500
   */
  labels: {
    inventoryId: string;
    roomLabel: string | null;
  }[];
}
