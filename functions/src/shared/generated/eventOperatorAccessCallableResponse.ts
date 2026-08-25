/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Sanitized event facts and exact operator permissions. No organizer-wide data is exposed.
 */
export interface EventOperatorAccessCallableResponse {
  eventId: string;
  organizerId: string;
  title: string;
  startAtMillis: number;
  endAtMillis: number;
  eventStatus: "active" | "cancelled";
  actorRole: "manager" | "operator";
  /**
   * @minItems 1
   * @maxItems 4
   */
  permissions: (
    | "viewRoster"
    | "setAttendance"
    | "reviewRuntimeClaims"
    | "publishLiveLocation"
  )[];
  grantExpiresAtMillis: number | null;
}
