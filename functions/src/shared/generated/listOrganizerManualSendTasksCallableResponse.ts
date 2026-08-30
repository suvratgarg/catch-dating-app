/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import {OrganizerManualSendTaskCallableResponse} from "./organizerManualSendTaskCallableResponse";

/**
 * Bounded manual-send queue or history page.
 */
export interface ListOrganizerManualSendTasksCallableResponse {
  organizerId: string;
  /**
   * @maxItems 50
   */
  tasks: OrganizerManualSendTaskCallableResponse[];
  nextCursor: string | null;
}
