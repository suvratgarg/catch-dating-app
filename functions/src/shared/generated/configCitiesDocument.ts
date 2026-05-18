/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Public city configuration stored at config/cities.
 */
export interface ConfigCitiesDocument {
  /**
   * @minItems 1
   */
  cityNames: (string | null)[];
  cities?: {
    name: string | null;
    label: string;
    latitude: number | null;
    longitude: number | null;
    countryIsoCode: string;
    currencyCode: string;
    dialCode: string;
    timeZone: string;
  }[];
}
