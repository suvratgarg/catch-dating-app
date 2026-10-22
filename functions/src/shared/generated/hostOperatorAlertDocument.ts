/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private operator notice receipt keyed by the original accepted Host lead. No applicant details or contact data.
 */
export type HostOperatorAlertDocument = {
  [k: string]: unknown;
} & {
  schemaVersion: 1;
  classification: "sales_private";
  eventId: string;
  intentId: string;
  acceptedAt: number;
  status: "pending" | "sending" | "accepted" | "failed" | "unknown" | "stopped";
  attempts: number;
  attemptId: string | null;
  providerMessageId: string | null;
  nextAttemptAt?: number;
};
