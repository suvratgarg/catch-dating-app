/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Canonical reusable venue returned after an organizer venue upsert.
 */
export interface UpsertOrganizerEventVenueCallableResponse {
  venue: {
    organizerId: string;
    venueId: string;
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
    status: "active" | "archived";
  };
}
