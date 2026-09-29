/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned organizer-defined guest grouping for a program. Guests carry groupIds[] on their own documents — that array is membership truth; the group document carries the queryable label, dimension, and denormalized memberCount used for headcount cuts, room allocation, and group-targeted Moments. Dimensions are free-form keys suggested per program kind (weddings: side/lineage/relation; corporate: company/delegation/country); labels are always organizer-defined. The wedding couple-side axis remains programHouseholds.side with organizerPrograms.householdSideLabels; groups are the general mechanism for every other cut.
 */
export interface ProgramGuestGroupDocument {
  programId: string;
  organizerId: string;
  /**
   * Organizer-defined display label, e.g. "Sharma family" or "Acme delegation".
   */
  label: string;
  /**
   * Grouping axis key. Conventional values per program kind (weddings: side/lineage/relation; corporate: company/delegation/country); other keys are allowed so organizers can model arbitrary cuts.
   */
  dimension: string;
  /**
   * Organizer-controlled ordering within a dimension; lower sorts first.
   */
  sortOrder: number;
  /**
   * Denormalized count of programGuests documents whose groupIds contain this group. Maintained transactionally by guest upsert, manifest import, and group delete.
   */
  memberCount: number;
  /**
   * Optional programHotels link: where members of this group stay. Distance-aware moment lead times (audience.travelTimeLead) resolve each guest to the hotel of their first hotel-linked group.
   */
  hotelId: string | null;
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
