/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by adminListOrganizerDetails. This lists canonical organizer profile rows from organizers/{organizerId} for the admin publishing workspace.
 */
export interface AdminListOrganizerDetailsCallablePayload {
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
