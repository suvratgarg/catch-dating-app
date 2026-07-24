/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Deprecated compatibility callable payload accepted by adminListClubDetails. The handler reads canonical organizer profile rows from organizers/{organizerId}; new clients use adminListOrganizerDetails.
 */
export interface AdminListClubDetailsCallablePayload {
  query?: string | null;
  citySlug?: string | null;
  citySlugs?: string[] | null;
  publishStatus?:
    | "draft"
    | "qa"
    | "published"
    | "suppressed"
    | "removed"
    | null;
  appVisibility?: "discoverable" | "hidden" | null;
  limit?: number;
}
