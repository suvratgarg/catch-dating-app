/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {OrganizerSavedAudienceCallableResponse} from "./organizerSavedAudienceCallableResponse";

/**
 * One bounded page of reusable organizer CRM audiences.
 */
export interface ListOrganizerSavedAudiencesCallableResponse {
  organizerId: string;
  /**
   * @maxItems 50
   */
  audiences: OrganizerSavedAudienceCallableResponse[];
  nextCursor: string | null;
  filterOptions?: {
    /**
     * @maxItems 400
     */
    forms: {
      formId: string;
      title: string;
    }[];
    /**
     * @maxItems 100
     */
    questions: {
      formId: string;
      versionId: string;
      version: number;
      formTitle: string;
      questionId: string;
      label: string;
      kind: "singleChoice" | "multiChoice" | "boolean";
      /**
       * @maxItems 100
       */
      options: {
        label: string;
        value: string | boolean;
      }[];
      activeVersion?: boolean;
    }[];
    /**
     * @maxItems 200
     */
    events: {
      eventId: string;
      title: string;
    }[];
    /**
     * @maxItems 20
     */
    tags: {
      tagId: string;
      label: string;
    }[];
  };
}
