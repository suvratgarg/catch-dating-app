/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by placesAutocomplete.
 */
export interface PlacesAutocompleteCallablePayload {
  input: string;
  sessionToken?: string;
  countryIsoCode?: "IN" | "NP" | "AU" | "US" | "in" | "np" | "au" | "us";
  latitude?: number;
  longitude?: number;
}
