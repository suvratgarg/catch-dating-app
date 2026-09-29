/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Hotel desk room-management view. Counts-only block capacity plus stay rows carrying display names already authorized to the caller's duty. Unplaced guests are program guests routed to this hotel (inbound legs or prior stays) with no capacity-consuming stay.
 */
export interface ProgramHotelRoomsCallableResponse {
  programId: string;
  hotelId: string;
  hotelName: string;
  accessExpiresAtMillis: number | null;
  generatedAtMillis: number;
  /**
   * @maxItems 500
   */
  roomBlocks: {
    roomBlockId: string;
    label: string;
    roomType: string | null;
    totalRooms: number;
    assignedCount: number;
    remainingRooms: number;
    /**
     * @maxItems 100
     */
    heldForGroupIds: string[];
    startsAtMillis: number;
    endsAtMillis: number;
  }[];
  /**
   * @maxItems 2000
   */
  stays: {
    stayId: string;
    guestId: string;
    guestDisplayName: string;
    roomBlockId: string | null;
    roomLabel: string | null;
    status: "held" | "confirmed" | "checkedIn" | "checkedOut" | "cancelled";
    startsAtMillis: number | null;
    endsAtMillis: number | null;
    roomReadyAtMillis: number | null;
    hotelArrivedAtMillis: number | null;
    revision: number;
  }[];
  /**
   * @maxItems 2000
   */
  unplacedGuests: {
    guestId: string;
    displayName: string;
    /**
     * Block the allocation policy would draw from for this guest; null when no block at this hotel has capacity.
     */
    suggestedRoomBlockId: string | null;
  }[];
}
