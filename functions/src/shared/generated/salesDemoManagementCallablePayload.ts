/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Admin Owner demo commands and bounded owner reads. A request ID is stable across retries; reads never return grant digests.
 */
export type SalesDemoManagementCallablePayload =
  | {
      requestId: string;
      blueprintId: string;
      expectedRevision: number;
      organizerId?: string | null;
      candidateId?: string | null;
      opportunityId?: string | null;
      evidenceRevision: string;
      preview: {
        brandName: string;
        headline: string;
        scenario: string;
        /**
         * @minItems 3
         * @maxItems 3
         */
        steps: string[];
        /**
         * @maxItems 8
         */
        retainedTools: string[];
        /**
         * @minItems 1
         * @maxItems 8
         */
        limitations: string[];
        cta: string;
      };
      formCapabilityReview: {
        questionTypes: "exact" | "manual" | "retained" | "unsupported";
        branching: "exact" | "manual" | "retained" | "unsupported";
        requiredFields: "exact" | "manual" | "retained" | "unsupported";
        scoringApproval: "exact" | "manual" | "retained" | "unsupported";
        uploads: "exact" | "manual" | "retained" | "unsupported";
      };
      /**
       * @maxItems 30
       */
      fieldMappings: {
        sourceField: string;
        catchField: string | null;
        disposition: "exact" | "manual" | "retained" | "unsupported";
      }[];
      setupPlan?:
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
          };
    }
  | {
      requestId: string;
      blueprintId: string;
      expectedRevision: number;
    }
  | {
      requestId: string;
      blueprintId: string;
      blueprintRevision: number;
      contactBinding?: null | {
        kind: "email" | "phone";
        value: string;
      };
      expiresAt: string;
      sessionCap: number;
    }
  | {
      requestId: string;
      invitationId: string;
      expectedRevision: number;
    }
  | {
      blueprintId: string;
    }
  | {
      invitationId: string;
    }
  | {}
  | {
      organizerId: string;
      cursor?: string;
      limit?: number;
    }
  | {
      blueprintId: string;
      cursor?: string;
      limit?: number;
    };
