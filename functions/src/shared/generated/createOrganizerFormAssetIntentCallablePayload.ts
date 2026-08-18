/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface CreateOrganizerFormAssetIntentCallablePayload {
  draftId: string;
  draftToken: string | null;
  questionId: string;
  requestId: string;
  originalFileName: string;
  contentType: "image/jpeg" | "image/png" | "image/webp" | "application/pdf";
  sizeBytes: number;
  sha256: string;
}
