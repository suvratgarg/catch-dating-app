/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventSetupDefaults {
  city: {
    value: {
      cityId: string;
      marketId: string;
    };
    source: "organizer" | "event";
  };
  timezone: {
    value: string;
    source: "organizer" | "event";
  };
  organizerDefaultsRevision: number | null;
  organizerDefaultsHash: string;
}
