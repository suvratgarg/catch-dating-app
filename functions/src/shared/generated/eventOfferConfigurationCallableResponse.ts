/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {ResolvedEventPreferences} from "./resolvedEventPreferences";
import type {EventPaymentTerms} from "./eventPaymentTerms";

export interface EventOfferConfigurationCallableResponse {
  organizerId: string;
  eventId: string;
  eventSourceRevision: number;
  startsAtMillis: number;
  nowMillis: number;
  paymentTerms: null | EventPaymentTerms;
  suggestedExpiresAtMillis: number | null;
  preferencesRevision: number;
  preferences: null | ResolvedEventPreferences;
}
