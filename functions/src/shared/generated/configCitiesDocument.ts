/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Public launch-market configuration stored at config/cities. The app picks from launched markets; canonical market ids disambiguate same-name cities globally.
 */
export interface ConfigCitiesDocument {
  version: number;
  /**
   * Compatibility whitelist used by Firestore rules. Values are launched canonical market ids, not display city names.
   *
   * @minItems 1
   */
  cityNames: string[];
  /**
   * @minItems 1
   */
  marketIds: string[];
  /**
   * @minItems 1
   */
  launchMarketIds: string[];
  cities: {
    /**
     * App-facing selection id. Kept as name for existing CityData JSON, but stores the canonical market id.
     */
    name: string;
    cityId: string;
    marketId: string;
    slug: string;
    label: string;
    latitude: number;
    longitude: number;
    countryIsoCode: string;
    currencyCode: string;
    dialCode: string;
    timeZone: string;
    launchStatus: "launched" | "planned" | "paused" | "retired";
    profileSelectable: boolean;
    hostCreatable: boolean;
    eventCreatable: boolean;
    exploreVisible: boolean;
  }[];
  /**
   * @minItems 1
   */
  markets: {
    marketId: string;
    cityId: string;
    slug: string;
    label: string;
    cityLabel: string;
    regionCode: string;
    regionName: string;
    countryIsoCode: string;
    countryName: string;
    currencyCode: string;
    dialCode: string;
    timeZone: string;
    latitude: number;
    longitude: number;
    /**
     * @maxItems 40
     */
    aliases: string[];
    launchStatus: "launched" | "planned" | "paused" | "retired";
    profileSelectable: boolean;
    hostCreatable: boolean;
    eventCreatable: boolean;
    exploreVisible: boolean;
  }[];
}
