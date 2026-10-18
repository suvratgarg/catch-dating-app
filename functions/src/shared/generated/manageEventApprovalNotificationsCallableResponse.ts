/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ManageEventApprovalNotificationsCallableResponse {
  eventId: string;
  revision: number;
  choices: {
    phoneUpdates: boolean;
    emailUpdates: boolean;
  };
  phoneVerified: boolean;
  emailVerified: boolean;
  available: boolean;
  terms: {
    version: "event-approval-v1";
    phone: string;
    email: string;
  };
}
