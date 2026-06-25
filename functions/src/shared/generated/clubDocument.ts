/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import {UploadedPhoto} from "./uploadedPhoto";

/**
 * Canonical club document stored at clubs/{clubId}. The club id is the document id and is not stored in document data.
 */
export interface ClubDocument {
  name: string;
  description: string;
  location: string | null;
  area: string;
  /**
   * Legacy primary host user id. Null for programmatically generated, unclaimed organizer profiles.
   */
  hostUserId: string | null;
  /**
   * Legacy host display projection. Null when the organizer has not been claimed by a Catch user.
   */
  hostName: string | null;
  hostAvatarUrl: string | null;
  /**
   * Canonical owner user id after claim or user-created setup. Null for unclaimed programmatic profiles.
   */
  ownerUserId: string | null;
  /**
   * @maxItems 20
   */
  hostUserIds: string[];
  /**
   * @maxItems 20
   */
  hostProfiles: {
    uid: string;
    displayName: string;
    avatarUrl: string | null;
    role: "owner" | "host";
  }[];
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  imageUrl: string | null;
  profileImageUrl: string | null;
  /**
   * @maxItems 12
   */
  clubPhotos?: UploadedPhoto[];
  logoPhoto?: UploadedPhoto | null;
  /**
   * @maxItems 20
   */
  tags: string[];
  memberCount: number;
  rating: number;
  reviewCount: number;
  /**
   * Published reviews that are verified (attended a Catch event). Only these back the headline rating; unverified public reviews cannot move the score.
   */
  verifiedReviewCount?: number;
  nextEventAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  nextEventLabel: string | null;
  instagramHandle: string | null;
  phoneNumber: string | null;
  email: string | null;
  status: "active" | "archived";
  archived: boolean;
  archivedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  archiveReason: string | null;
  hostDefaults?: {
    primaryActivityKind?:
      | "socialRun"
      | "running"
      | "walking"
      | "pickleball"
      | "padel"
      | "tennis"
      | "badminton"
      | "cycling"
      | "spinClass"
      | "yoga"
      | "strengthTraining"
      | "pubQuiz"
      | "barCrawl"
      | "dinner"
      | "singlesMixer"
      | "openActivity";
    /**
     * @maxItems 16
     */
    supportedActivityKinds?: (
      | "socialRun"
      | "running"
      | "walking"
      | "pickleball"
      | "padel"
      | "tennis"
      | "badminton"
      | "cycling"
      | "spinClass"
      | "yoga"
      | "strengthTraining"
      | "pubQuiz"
      | "barCrawl"
      | "dinner"
      | "singlesMixer"
      | "openActivity"
    )[];
    eventPolicy?: {
      admissionPreset?:
        | "openCapacity"
        | "inviteOnly"
        | "balancedSingles"
        | "fixedCohortCaps";
      minAge?: number;
      maxAge?: number;
      maxMen?: number | null;
      maxWomen?: number | null;
      dynamicPricingEnabled?: boolean;
      dynamicPricingStepInPaise?: number | null;
      dynamicPricingMaxInPaise?: number | null;
      cancellationPolicyId?: "flexible" | "standard" | "strict";
    };
    eventSuccess?: {
      enabled?: boolean;
      playbookId?: string;
      /**
       * @maxItems 24
       */
      selectedModuleIds?: string[];
      structureConfig?: {
        unitKind: "wholeGroup" | "pods" | "pairs" | "teams" | "tables";
        unitSize: number;
        unitCount?: number | null;
        rotationIntervalMinutes?: number | null;
        revealCountdownSeconds: number;
        rotationRepeatStrategy?: "avoid" | "allowWhenExhausted";
        maxPairMeetings?: number;
        /**
         * @maxItems 8
         */
        balanceActivityAttributes?: ("paceBand" | "skillBand" | "roleBand")[];
        /**
         * @maxItems 8
         */
        clusterActivityAttributes?: ("paceBand" | "skillBand" | "roleBand")[];
      };
      hostGoal?: string;
      wingmanRequestsEnabled?: boolean;
      contextualOpenersEnabled?: boolean;
      compatibilityAffectsRanking?: boolean;
      questionnaireConfig?: {
        templateId: string;
        customTitle?: string | null;
        /**
         * @maxItems 8
         */
        customQuestions?: {
          id: string;
          prompt: string;
          /**
           * @minItems 2
           * @maxItems 5
           */
          options: {
            id: string;
            label: string;
          }[];
        }[];
      };
      attendeePrompt?: string | null;
    };
    eventSuccessByActivityKind?: {
      [k: string]: {
        enabled?: boolean;
        playbookId?: string;
        /**
         * @maxItems 24
         */
        selectedModuleIds?: string[];
        structureConfig?: {
          unitKind: "wholeGroup" | "pods" | "pairs" | "teams" | "tables";
          unitSize: number;
          unitCount?: number | null;
          rotationIntervalMinutes?: number | null;
          revealCountdownSeconds: number;
          rotationRepeatStrategy?: "avoid" | "allowWhenExhausted";
          maxPairMeetings?: number;
          /**
           * @maxItems 8
           */
          balanceActivityAttributes?: ("paceBand" | "skillBand" | "roleBand")[];
          /**
           * @maxItems 8
           */
          clusterActivityAttributes?: ("paceBand" | "skillBand" | "roleBand")[];
        };
        hostGoal?: string;
        wingmanRequestsEnabled?: boolean;
        contextualOpenersEnabled?: boolean;
        compatibilityAffectsRanking?: boolean;
        questionnaireConfig?: {
          templateId: string;
          customTitle?: string | null;
          /**
           * @maxItems 8
           */
          customQuestions?: {
            id: string;
            prompt: string;
            /**
             * @minItems 2
             * @maxItems 5
             */
            options: {
              id: string;
              label: string;
            }[];
          }[];
        };
        attendeePrompt?: string | null;
      };
    };
  };
  /**
   * Broad organizer identity. Keeps clubs as one subtype rather than forcing every host into club nomenclature.
   */
  entityKind?:
    | "club"
    | "venue"
    | "eventOrganizer"
    | "creatorCommunity"
    | "brand";
  /**
   * @maxItems 20
   */
  entitySubtypes?: string[];
  /**
   * Reader-facing category label for web and discovery surfaces.
   */
  displayCategory?: string | null;
  cityName?: string | null;
  regionName?: string | null;
  countryCode?: string | null;
  countryName?: string | null;
  /**
   * Whether the native app should show this organizer in browse surfaces. Scraped unclaimed profiles start hidden.
   */
  appVisibility?: "discoverable" | "hidden";
  /**
   * Claim-aware organizer ownership state. This is the forward-looking owner model; legacy host fields are maintained for app compatibility.
   */
  ownership?: {
    state: "programmatic" | "userCreated" | "claimed" | "transferred";
    ownerUserId: string | null;
    primaryHostUserId: string | null;
    /**
     * @maxItems 20
     */
    hostUserIds: string[];
    claimedAt: {
      _seconds: number;
      _nanoseconds: number;
    } | null;
    claimedByUid: string | null;
  };
  claim?: {
    state: "unclaimed" | "claimPending" | "claimed" | "verified" | "suppressed";
    claimHref: string | null;
    lastClaimRequestId: string | null;
  };
  publicPage?: {
    slug: string;
    citySlug: string | null;
    canonicalPath: string;
    publishStatus: "draft" | "qa" | "published" | "suppressed" | "removed";
    indexStatus: "noindex" | "indexReady" | "indexed";
    robots: "noindex, follow" | "index, follow";
    seoTitle: string | null;
    seoDescription: string | null;
    lastRenderedAt: {
      _seconds: number;
      _nanoseconds: number;
    } | null;
    indexReview?: {
      /**
       * Serialized Firestore Timestamp fixture shape.
       */
      reviewedAt: {
        _seconds: number;
        _nanoseconds: number;
      };
      reviewedByUid: string;
      indexStatus: "noindex" | "indexReady" | "indexed";
      checklist: {
        sourceEvidenceVerified: boolean;
        mediaRightsVerified: boolean;
        cadenceVerified: boolean;
        ownerContactVerified: boolean;
      };
      reviewNote: string | null;
    } | null;
  };
  provenance?: {
    origin: "userCreated" | "scraper" | "adminSeed" | "import";
    sourceConfidence: "seedOnly" | "low" | "medium" | "high" | "ownerVerified";
    verificationStatus: "unverified" | "sourceBacked" | "ownerVerified";
    lastVerifiedAt: {
      _seconds: number;
      _nanoseconds: number;
    } | null;
  };
  /**
   * Server-owned deterministic search projection used by admin organizer publishing. Rebuildable from canonical club fields; not consumed by the app.
   */
  adminSearch?: {
    /**
     * @maxItems 120
     */
    tokens: string[];
    sortKey: string;
    /**
     * Serialized Firestore Timestamp fixture shape.
     */
    updatedAt: {
      _seconds: number;
      _nanoseconds: number;
    };
    updatedBySource:
      | "adminUpdateClubDetails"
      | "adminSetClubIndexStatus"
      | "adminOrganizerSearchBackfill";
  };
  /**
   * Public, owner-safe organizer listing content derived from sources or owner edits. Raw scrape snapshots belong in private evidence collections.
   */
  publicProfile?: {
    headline?: string | null;
    summary?: string | null;
    sourceSummary?: string | null;
    /**
     * @maxItems 12
     */
    formats?: string[];
    /**
     * @maxItems 20
     */
    facts?: {
      label: string;
      value: string;
    }[];
    /**
     * @maxItems 8
     */
    fitNotes?: string[];
    /**
     * @maxItems 12
     */
    missingEvidence?: string[];
    /**
     * @maxItems 12
     */
    eventEvidence?: {
      title: string;
      date: string;
      location: string;
      summary: string;
      /**
       * @maxItems 12
       */
      facts: string[];
      sourceLabel: string;
      sourceHref: string;
    }[];
  };
  /**
   * @maxItems 20
   */
  publicSources?: {
    type: string;
    label: string;
    detail: string;
    href: string | null;
    confidence: "low" | "medium" | "high";
    lastCheckedAt: {
      _seconds: number;
      _nanoseconds: number;
    } | null;
  }[];
  /**
   * Internal demo seed marker used for cleanup and diagnostics.
   */
  synthetic?: boolean;
  /**
   * Internal demo seed prefix used for cleanup and diagnostics.
   */
  seedPrefix?: string;
  /**
   * Internal demo seed scenario name used for cleanup and diagnostics.
   */
  scenario?: string;
  /**
   * Internal demo-operations marker used for cleanup and diagnostics.
   */
  demoOps?: boolean;
  /**
   * Internal demo-operations id used for cleanup and diagnostics.
   */
  demoOpsId?: string;
  /**
   * Internal demo-operations command name used for cleanup and diagnostics.
   */
  demoOpsCommand?: string;
}
