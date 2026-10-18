/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ManageEventApprovalNotificationsCallablePayload {
  eventId: string;
  action: "get" | "save";
  expectedRevision?: number;
  choices?: {
    phoneUpdates: boolean;
    emailUpdates: boolean;
  };
  termsVersion?: "event-approval-v1";
  expectedUid: string;
}
