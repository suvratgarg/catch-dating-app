/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Callable response returned by placesAutocomplete.
 */
export interface PlacesAutocompleteCallableResponse {
  /**
   * @maxItems 10
   */
  predictions: {
    placeId: string;
    description: string;
    mainText: string;
    secondaryText: string;
  }[];
}
