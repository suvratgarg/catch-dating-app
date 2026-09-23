/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface PromoteFormCommunicationIntentCallableResponse {
  responseId: string;
  promotedPurposes: (
    | "organizer:eventOperations"
    | "organizer:marketing"
    | "catch:marketing"
  )[];
  replayed: boolean;
}
