/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventApprovalPreferenceDocument {
  eventId: string;
  organizerId: string;
  uid: string;
  revision: number;
  choices: {
    phoneUpdates: boolean;
    emailUpdates: boolean;
  };
  phoneE164: string | null;
  email: string | null;
  termsVersion: "event-approval-v1";
  receiptId: string;
  updatedAtMillis: number;
}
