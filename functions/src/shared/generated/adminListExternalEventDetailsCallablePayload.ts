/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by adminListExternalEventDetails. This lists read-only externalEvents/{eventId} rows for the admin event supply workspace.
 */
export interface AdminListExternalEventDetailsCallablePayload {
  query?: string | null;
  citySlug?: (string | null) | null;
  citySlugs?: (string | null)[] | null;
  publicationStatus?: "draft" | "public" | "archived" | "removed" | null;
  status?: "active" | "cancelled" | null;
  /**
   * Optional server-side startTime window used by admin external event lists. Upcoming and past are evaluated against callable server time.
   */
  timeWindow?: "upcoming" | "past" | "all" | null;
  limit?: number;
}
