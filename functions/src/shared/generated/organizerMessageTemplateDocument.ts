/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Sanitized provider template metadata used for preview and send eligibility.
 */
export interface OrganizerMessageTemplateDocument {
  organizerId: string;
  connectionId: string;
  providerTemplateId: string;
  name: string;
  language: string;
  category: "MARKETING" | "UTILITY" | "AUTHENTICATION" | "UNKNOWN";
  status:
    | "APPROVED"
    | "PENDING"
    | "REJECTED"
    | "PAUSED"
    | "DISABLED"
    | "DELETED"
    | "UNKNOWN";
  /**
   * @maxItems 20
   */
  variableNames: string[];
  /**
   * @maxItems 20
   */
  parameterBindings: {
    variableName: string;
    component: "header" | "body" | "button";
    position: number;
    buttonIndex: number | null;
  }[];
  hasMediaHeader: boolean;
  /**
   * @maxItems 10
   */
  buttonKinds: (
    | "URL"
    | "PHONE_NUMBER"
    | "QUICK_REPLY"
    | "COPY_CODE"
    | "UNKNOWN"
  )[];
  /**
   * @maxItems 10
   */
  buttonLabels?: (string | null)[];
  parameterFormat?: "NAMED" | "POSITIONAL" | "UNKNOWN";
  providerUpdatedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  syncedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
