/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by adminResolveOrganizerEventLocation. This records reviewed coordinates for a private external event candidate without importing the event.
 */
export interface AdminResolveOrganizerEventLocationCallablePayload {
  candidateId: string;
  location: {
    name: string;
    address?: string | null;
    placeId?: string | null;
    latitude: number | null;
    longitude: number | null;
    notes?: string | null;
  };
  checklist: {
    sourceLocationReviewed: boolean;
    coordinatesReviewed: boolean;
    placeIdentityReviewed: boolean;
    importSafetyReviewed: boolean;
  };
  note: string;
}
