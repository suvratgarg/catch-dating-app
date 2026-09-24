/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {ResolvedEventPreferences} from "./resolvedEventPreferences";
import type {EventPaymentTerms} from "./eventPaymentTerms";
import type {EventSetupDefaults} from "./eventSetupDefaults";

export interface PrivateEventSetupCallableResponse {
  eventId: string;
  organizerId: string;
  setupRevision: number;
  name: string;
  city: {
    cityId: string;
    marketId: string;
  };
  localDate: string;
  localStartTime: string;
  timezone: string;
  startTimeMillis: number;
  publicationState: "private";
  status: "active" | "cancelled";
  setupDefaults: EventSetupDefaults;
  detailsConfigured: boolean;
  eventPreferences: {
    revision: number;
    preferences: ResolvedEventPreferences;
    paymentTerms: EventPaymentTerms;
  } | null;
}
