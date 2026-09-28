/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned per-guest stay assignment: which hotel (and optionally which room block / room label) a guest occupies, with planned dates and hotel-side progression timestamps. One document per guest per stay; guests sharing a room have separate stays with the same roomLabel.
 */
export interface ProgramStayDocument {
  programId: string;
  organizerId: string;
  /**
   * Exactly one guest per stay; roommates are separate stays sharing roomLabel.
   */
  guestId: string;
  /**
   * programHotels doc the guest stays at; must belong to the same program.
   */
  hotelId: string;
  /**
   * programRoomBlocks doc this stay draws capacity from; null for ad-hoc assignments outside any block.
   */
  roomBlockId: string | null;
  /**
   * Physical room assignment (e.g. '412') set by the hotel desk; null until allocated.
   */
  roomLabel: string | null;
  /**
   * Planned check-in; null while the stay is requested but undated.
   */
  startsAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Planned check-out; null while undated.
   */
  endsAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Stay lifecycle: held (reserved, not confirmed) → confirmed → checkedIn → checkedOut; cancelled releases block capacity.
   */
  status: "held" | "confirmed" | "checkedIn" | "checkedOut" | "cancelled";
  /**
   * When the hotel marked the room ready for this guest.
   */
  roomReadyAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * When the guest actually reached the hotel (hotel-desk observed).
   */
  hotelArrivedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  notes: string | null;
  /**
   * How the stay row entered the program — mirrors programTravelLegs.source.
   */
  source: "manual" | "import" | "planner";
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
