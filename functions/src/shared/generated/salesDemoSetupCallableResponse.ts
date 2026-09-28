/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface SalesDemoSetupCallableResponse {
  schemaVersion: 1;
  setupHash: string;
  plan:
    | {
        mode: "manual";
        /**
         * @minItems 1
         * @maxItems 12
         */
        requirements: string[];
      }
    | {
        mode: "template";
        /**
         * @maxItems 12
         */
        requirements: string[];
        templateId: string;
        title: string;
        templateVersion: number;
        templateHash: string;
        materializerVersion: 1;
      };
  organizerId: string | null;
  formId: string | null;
  editorPath: string | null;
  publicationAuthority: false;
  status: "manual_setup" | "claim_required" | "ready" | "prepared";
}
