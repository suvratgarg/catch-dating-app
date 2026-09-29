/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Create or update one guest's stay at a hotel. hotelDesk callers may only touch stays at hotels their duty covers; program coordinators and managers are unscoped. Null fields clear the stored value; omitted fields keep it. Room-block capacity is re-counted from live stays server-side, so a stale client never overbooks.
 */
export interface UpsertProgramStayCallablePayload {
  programId: string;
  /**
   * Existing stay to update. Omit to create a new stay row.
   */
  stayId?: string;
  /**
   * Required on updates; the write fails when the stored revision moved.
   */
  expectedRevision?: number;
  guestId: string;
  /**
   * Hotel the stay is at. Immutable on existing stays — cancel and recreate to move a guest.
   */
  hotelId: string;
  /**
   * Block to draw capacity from. Null keeps/creates an ad-hoc stay outside any block. The write fails when the block has no remaining rooms.
   */
  roomBlockId?: string | null;
  /**
   * Room or suite label shared by roommates (e.g. "312").
   */
  roomLabel?: string | null;
  /**
   * Omitted on create defaults to held; on update keeps the stored status.
   */
  status?: "held" | "confirmed" | "checkedIn" | "checkedOut" | "cancelled";
  /**
   * Planned check-in; null while the stay is undated.
   */
  startsAtMillis?: number | null;
  /**
   * Planned check-out; null while the stay is undated.
   */
  endsAtMillis?: number | null;
  notes?: string | null;
  /**
   * When true, stamps roomReadyAt with the server time.
   */
  markRoomReady?: boolean;
  /**
   * When true, stamps hotelArrivedAt with the server time.
   */
  markHotelArrived?: boolean;
}
