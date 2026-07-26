/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by adminDecideOrganizerIntake. This records a manual admin review decision for a private organizer-intake candidate.
 */
export interface AdminDecideOrganizerIntakeCallablePayload {
  entityId: string;
  decision: "approve_public" | "hold" | "suppress";
  /**
   * Explicit public-web publication switch. Approval does not imply publication.
   */
  publishStatus: "draft" | "published" | "suppressed";
  /**
   * Explicit search-indexing switch. Indexed requires a published web page.
   */
  indexStatus: "noindex" | "indexed";
  appVisibility: "hidden" | "discoverable";
  checklist: {
    identityReviewed: boolean;
    surfaceInventoryReviewed: boolean;
    ownerSafeCopyReviewed: boolean;
    marketScopeReviewed: boolean;
    mediaRightsReviewed: boolean;
    crawlDisabledReviewed: boolean;
    /**
     * True when the reviewer explicitly inspected manual reports that have no local raw artifact. Raw evidence remains outside Firestore; replay validation decides when this acknowledgement is required.
     */
    manualReportsReviewed?: boolean;
    claimTargetReviewed?: boolean;
    takedownPathReviewed?: boolean;
    impersonationReviewed?: boolean;
    operatingStatusReviewed?: boolean;
    eventAccuracyReviewed?: boolean;
    unclaimedAffordancesReviewed?: boolean;
  };
  note: string;
}
