/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {OrganizerEventSetupPreferences} from "./organizerEventSetupPreferences";

export interface OrganizerEventSetupDefaultsDocument {
  organizerId: string;
  revision: number;
  eventSetup: OrganizerEventSetupPreferences;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  updatedByUid: string;
}
