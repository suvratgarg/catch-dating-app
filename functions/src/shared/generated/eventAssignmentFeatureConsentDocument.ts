/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private participant-owned decision for one event and immutable form answer. Not implied by form submission, profile sharing, messaging consent, or host configuration.
 */
export interface EventAssignmentFeatureConsentDocument {
  eventId: string;
  organizerId: string;
  uid: string;
  responseId: string;
  featureId: string;
  formId: string;
  versionId: string;
  questionId: string;
  transformVersion: number;
  purpose: "eventAssignmentMatching";
  status: "granted" | "withdrawn";
  receiptId: string;
  revision: number;
  lastRequestId: string;
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
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
