/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {ResolvedEventPreferences} from "./resolvedEventPreferences";
import type {EventPaymentTerms} from "./eventPaymentTerms";

export interface PreviewEventOfferPreferencesCallableResponse {
  organizerId: string;
  eventId: string;
  requestId: string;
  eventSourceRevision: number;
  current: null | {
    revision: number;
    preferences: ResolvedEventPreferences;
    paymentTerms: EventPaymentTerms;
  };
  candidate: {
    revision: number;
    preferences: ResolvedEventPreferences;
    paymentTerms: EventPaymentTerms;
  };
  existingOffersKeepOriginalTerms: true;
}
