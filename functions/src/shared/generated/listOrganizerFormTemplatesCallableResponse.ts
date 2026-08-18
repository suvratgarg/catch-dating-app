/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Versioned template summaries for the Host form gallery.
 */
export interface ListOrganizerFormTemplatesCallableResponse {
  /**
   * @minItems 1
   * @maxItems 100
   */
  templates: {
    templateId: string;
    version: number;
    title: string;
    description: string | null;
    purpose:
      | "application"
      | "registration"
      | "intake"
      | "waiver"
      | "feedback"
      | "survey";
    identityPolicy:
      | "anonymous"
      | "emailVerified"
      | "phoneVerified"
      | "emailOrPhoneVerified"
      | "catchAccount";
    sectionCount: number;
    questionCount: number;
  }[];
}
