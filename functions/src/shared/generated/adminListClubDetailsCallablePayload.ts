/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by adminListClubDetails. This lists canonical organizer profile rows from clubs/{clubId} for the admin publishing workspace.
 */
export interface AdminListClubDetailsCallablePayload {
  query?: string | null;
  citySlug?: (string | null) | null;
  citySlugs?: (string | null)[] | null;
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
