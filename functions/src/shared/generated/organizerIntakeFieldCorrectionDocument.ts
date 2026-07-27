/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable, server-owned field correction captured when an admin first changes a source-seeded organizer value. Each correction owns a deterministic replay fixture id.
 */
export interface OrganizerIntakeFieldCorrectionDocument {
  schemaVersion: 1;
  correctionId: string;
  fixtureId: string;
  organizerId: string;
  sourceProfileId: string;
  sourceWorkItemId: string;
  sourceCandidateId: string;
  field:
    | "name"
    | "location"
    | "tags"
    | "publicProfile.sourceSummary"
    | "publicProfile.formats";
  extractedValue: string | null | string[];
  correctedValue: string | null | string[];
  artifactId: string;
  contentHash: string;
  locator: string | null;
  extractedBy: "deterministic" | "model" | "human";
  extractorVersion: string;
  confidence: number | null;
  reviewNote: string;
  correctedByUid: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  correctedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
