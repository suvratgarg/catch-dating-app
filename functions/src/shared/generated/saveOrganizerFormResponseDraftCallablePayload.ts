/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Optimistically saves respondent answers without file bytes.
 */
export interface SaveOrganizerFormResponseDraftCallablePayload {
  messagingChoices?: {
    termsVersion: "form-whatsapp-v1";
    organizerWhatsapp: boolean;
    catchWhatsapp: boolean;
  };
  draftId: string;
  draftToken: string | null;
  expectedRevision: number;
  answers: {
    [k: string]: string | number | boolean | null | string[];
  };
  consentAccepted: boolean;
}
