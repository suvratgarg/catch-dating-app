/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {OrganizerEventSetupPreferences} from "./organizerEventSetupPreferences";

export interface OrganizerEventSetupDefaultsCallableResponse {
  organizerId: string;
  city: {
    cityId: string;
    marketId: string;
  } | null;
  timezone: string | null;
  organizerDefaultsRevision: number | null;
  basicsReviewedHash: string;
  preferencesRevision: number;
  preferences: OrganizerEventSetupPreferences;
  preferencesHash: string;
  reviewedDefaultsHash: string;
}
