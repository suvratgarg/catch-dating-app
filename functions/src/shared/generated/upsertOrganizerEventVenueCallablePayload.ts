/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Creates, updates, archives, or restores one organizer-owned reusable event venue.
 */
export interface UpsertOrganizerEventVenueCallablePayload {
  organizerId: string;
  venueId?: string | null;
  label: string;
  /**
   * Canonical meeting location selected from Google Places or a manually pinned map coordinate.
   */
  meetingLocation: {
    name: string;
    address?: string | null;
    placeId?: string | null;
    latitude: number;
    longitude: number;
    notes?: string | null;
  };
  defaultEventCapacity?: number | null;
  status?: "active" | "archived";
}
