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
   * Peak simultaneous occupied rooms across local contract nights; recomputed from explicit occupancy identities, not guest rows.
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
  /**
   * Identity/free-text scrub marker set by the archive retention sweep; null until anonymized.
   */
  anonymizedAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Coordinator-verified occupant limit for each contracted room. Defaults to one when unknown; does not establish bed type or accessibility.
   */
  maxOccupantsPerRoom?: number;
}
