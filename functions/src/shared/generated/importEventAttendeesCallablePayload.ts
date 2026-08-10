/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by importEventAttendees.
 */
export interface ImportEventAttendeesCallablePayload {
  eventId: string;
  importKey: string;
  fileName: string;
  format: "csv" | "xlsx" | "manual";
  /**
   * @minItems 1
   * @maxItems 250
   */
  rows: {
    rowId: string;
    displayName: string;
    phone?: string | null;
    email?: string | null;
    externalReference?: string | null;
    ticketType?: string | null;
    status: "invited" | "registered" | "waitlisted";
  }[];
}
