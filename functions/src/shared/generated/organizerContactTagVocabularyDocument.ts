/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Organizer-authored manual CRM tag vocabulary. Tag ids are structurally distinct from computed audience segment ids.
 */
export interface OrganizerContactTagVocabularyDocument {
  organizerId: string;
  /**
   * @maxItems 20
   */
  tags: {
    tagId: string;
    label: string;
    normalizedLabel: string;
    createdByUid: string;
    /**
     * Serialized Firestore Timestamp fixture shape.
     */
    createdAt: {
      _seconds: number;
      _nanoseconds: number;
    };
  }[];
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
