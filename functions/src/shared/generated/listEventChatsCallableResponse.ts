/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {GetEventChatAccessCallableResponse} from "./getEventChatAccessCallableResponse";

export interface ListEventChatsCallableResponse {
  /**
   * @maxItems 10
   */
  items: GetEventChatAccessCallableResponse[];
  nextCursor: {
    source: "memberships" | "participations" | "attendees";
    after: string | null;
    accountUid: string;
  } | null;
}
