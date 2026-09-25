/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {EventPreferenceIntents} from "./eventPreferenceIntents";

export interface ConfigureEventOfferPreferencesCallablePayload {
  organizerId: string;
  eventId: string;
  requestId: string;
  expectedPreferencesRevision: number;
  reviewedDefaultsHash: string;
  intents: EventPreferenceIntents;
  expectedEventSourceRevision: number;
}
