/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Pauses, resumes, or archives one organizer form with an expected-state guard.
 */
export interface SetOrganizerFormLifecycleCallablePayload {
  organizerId: string;
  formId: string;
  expectedStatus: "draft" | "published" | "paused" | "archived";
  action: "pause" | "resume" | "archive";
}
