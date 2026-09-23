/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private, immutable form choice. Never read as dispatch permission; promotion requires response ownership and verified control of the exact endpoint.
 */
export interface FormCommunicationConsentIntentDocument {
  organizerId: string;
  formId: string;
  versionId: string;
  responseId: string;
  endpointE164: string;
  termsVersion: "form-whatsapp-v2";
  /**
   * @minItems 1
   * @maxItems 3
   */
  decisions: {
    principal: "organizer" | "catch";
    purpose: "eventOperations" | "marketing";
    copyHash: string;
    /**
     * Serialized Firestore Timestamp fixture shape.
     */
    decidedAt: {
      _seconds: number;
      _nanoseconds: number;
    };
  }[];
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
