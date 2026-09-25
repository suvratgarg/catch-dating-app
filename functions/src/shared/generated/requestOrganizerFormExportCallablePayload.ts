/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {QueryOrganizerFormResponsesCallablePayload} from "./queryOrganizerFormResponsesCallablePayload";

/**
 * Idempotent response export request or status refresh.
 */
export interface RequestOrganizerFormExportCallablePayload {
  organizerId: string;
  formId: string;
  requestId: string;
  format: "csv" | "xlsx";
  /**
   * @minItems 1
   * @maxItems 2
   */
  statuses: ("submitted" | "withdrawn")[];
  versionId: string | null;
  fromMillis: number | null;
  toMillis: number | null;
  /**
   * Optional exact typed filter and sort. Export covers all matches, not one page.
   */
  responseQuery?: QueryOrganizerFormResponsesCallablePayload | null;
  /**
   * Required with responseQuery; changed results fail rather than silently exporting a different set.
   */
  expectedResultHash?: string | null;
  /**
   * Required with responseQuery; binds the published definition and filter semantics.
   */
  expectedQueryHash?: string | null;
}
