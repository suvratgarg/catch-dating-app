/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable response returned by placeDetails.
 */
export interface PlaceDetailsCallableResponse {
  place: {
    placeId: string;
    displayName: string;
    formattedAddress: string;
    latitude: number;
    longitude: number;
  };
}
