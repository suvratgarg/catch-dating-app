/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned reserved room inventory at a programHotels doc — a labelled block of rooms held for a stay window, optionally earmarked for guest groups. Stays consume capacity through roomBlockId; assignedCount is the server-maintained rollup.
 */
export interface ProgramRoomBlockDocument {
  programId: string;
  organizerId: string;
  /**
   * programHotels doc this block reserves rooms at; must belong to the same program.
   */
  hotelId: string;
  /**
   * Organizer-facing block name, e.g. 'Bride family — Deluxe'.
   */
  label: string;
  /**
   * Optional hotel room class (Deluxe, Suite). Null when the block is type-agnostic.
   */
  roomType: string | null;
  /**
   * Rooms held under this block.
   */
  totalRooms: number;
  /**
   * Server-maintained count of live programStays rows bound to this block; never written by clients.
   */
  assignedCount: number;
  /**
   * programGuestGroups this block is earmarked for; allocation prefers matching groups before general inventory.
   *
   * @maxItems 12
   */
  heldForGroupIds: string[];
  /**
   * First night of the stay window this block covers.
   */
  startsAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Checkout day of the stay window this block covers.
   */
  endsAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Operational notes visible to organizer and hotel desk (rate contact, holding conditions).
   */
  notes?: string | null;
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
