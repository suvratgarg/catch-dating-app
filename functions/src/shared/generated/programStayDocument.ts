/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned per-guest lodging assignment. Roommates explicitly share a stable roomOccupancyId; roomLabel is display-only. Legacy rows remain separate until explicitly joined.
 */
export interface ProgramStayDocument {
  programId: string;
  organizerId: string;
  /**
   * Exactly one guest per stay; room sharing is explicit and independent of invitation household and social groups.
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
  /**
   * Identity/free-text scrub marker set by the archive retention sweep; null until anonymized.
   */
  anonymizedAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Server-minted shared-room identity. Missing legacy rows use stayId; labels and households never imply sharing.
   */
  roomOccupancyId?: string;
}
