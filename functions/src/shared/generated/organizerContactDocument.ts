/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import {OrganizerContactTraitDocument} from "./organizerContactTraitDocument";

/**
 * Server-owned organizer-scoped contact projection. It is not a Consumer profile and may contain restricted operational contact data.
 */
export interface OrganizerContactDocument {
  organizerId: string;
  displayName: string;
  /**
   * Organizer-scoped label correction. It never changes the Consumer profile or a provider/roster source row.
   */
  displayNameOverride?: string | null;
  searchName: string;
  linkedUid: string | null;
  phoneE164: string | null;
  email: string | null;
  identityState: "unlinked" | "verified" | "ambiguous" | "merged";
  identityConfidence: "eventOnly" | "proposed" | "verified";
  primarySource:
    | "catchBooking"
    | "hostImport"
    | "hostManual"
    | "webOtp"
    | "providerSync"
    | "hostForm";
  /**
   * @maxItems 20
   */
  ambiguousCandidateContactIds: string[];
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  firstSeenAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  lastSeenAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  sourceCount: number;
  whatsappStatus: "unknown" | "optedIn" | "optedOut";
  smsStatus: "unknown" | "optedIn" | "optedOut";
  /**
   * Organizer-authored manual CRM tag ids. These are distinct from computed segment ids in organizerContactTraits.
   *
   * @maxItems 5
   */
  manualTagIds?: string[];
  revision: number;
  mergedIntoContactId: string | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  deletedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Organizer-requested CRM hiding. Operational attendee and audit facts remain intact.
   */
  hiddenAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  hiddenBy?: string | null;
  /**
   * Bounded organizer-audience contribution snapshot used only to restore a hidden contact without recomputing private event history.
   */
  hiddenTraitSnapshot?: OrganizerContactTraitDocument | null;
}
