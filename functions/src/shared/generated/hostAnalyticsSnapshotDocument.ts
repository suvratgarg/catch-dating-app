/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import {HostAnalyticsCallableResponse} from "./hostAnalyticsCallableResponse";

/**
 * Server-owned 15-minute response cache stored at hostAnalyticsSnapshots/{uid}_{scopeHash}.
 */
export interface HostAnalyticsSnapshotDocument {
  uid: string;
  scopeHash: string;
  response: HostAnalyticsCallableResponse;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
