/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Creates one unclaimed, source-backed organizer draft from an exact reviewed Supply Intake work item. The callable cannot publish, index, expose in the app, enable crawling, or assign ownership.
 */
export interface AdminCreateOrganizerDraftFromCandidateCallablePayload {
  workItemId: string;
  candidateId: string;
  /**
   * Human-readable public route slug. The callable allocates a separate opaque Firestore organizer document id.
   */
  publicSlug: string;
  name: string;
  /**
   * Canonical organizer classification. Club is one organizer subtype; missing legacy values normalize to club during migration.
   */
  organizerType:
    | "club"
    | "community"
    | "individual"
    | "eventProducer"
    | "venue"
    | "brand";
  reviewNote: string;
}
