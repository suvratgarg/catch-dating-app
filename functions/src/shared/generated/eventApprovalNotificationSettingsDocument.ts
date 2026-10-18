/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventApprovalNotificationSettingsDocument {
  enabled: boolean;
  revision: number;
  whatsapp: {
    connectionId: string;
    templateId: string;
    maxCostMicros: number;
  } | null;
  sms: {
    accountId: string;
    credentialVersion: string;
    senderId: string;
    mask: string;
    principalEntityId: string;
    dltTemplateId: string;
    approvedText: "Your event application is approved. View your next steps: {eventUrl}";
    maxCostMicros: number;
  } | null;
  email: {
    provider: "resend";
    accountId: string;
    credentialVersion: string;
    from: string;
  } | null;
  dailyPhoneLimit: number;
  monthlyPhoneLimit: number;
  dailyCostLimitMicros: number;
  monthlyCostLimitMicros: number;
}
