/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventApprovalNotificationWork {
  kind: "approvalNotification";
  messageId: string;
  intentHash: string;
  dueAt: number | null;
  evaluations: number;
  failures: number;
  lastMessageRevision: number;
  reason?: string;
}
