/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {ResolvedEventPreferences} from "./resolvedEventPreferences";
import type {EventPaymentTerms} from "./eventPaymentTerms";

export interface EventSetupPreferencesDocument {
  organizerId: string;
  eventId: string;
  revision: number;
  preferences: ResolvedEventPreferences;
  paymentTerms: EventPaymentTerms;
  updatedByUid: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
