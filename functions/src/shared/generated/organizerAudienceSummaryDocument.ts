/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-maintained scalable organizer audience summary projected from contact traits.
 */
export interface OrganizerAudienceSummaryDocument {
  organizerId: string;
  contactCount: number;
  pastAttendeeCount: number;
  repeatAttendeeCount: number;
  linkedAccountCount: number;
  importedContactCount: number;
  whatsappOptInCount: number;
  smsOptInCount: number;
  sourceCoverage: "exact" | "partial";
  projectionVersion: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  computedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
