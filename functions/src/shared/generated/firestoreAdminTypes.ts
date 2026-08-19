/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import {EventOrigin} from "./eventOrigin";
import {EventRuntimeAccess} from "./eventRuntimeAccess";
import {ExternalEventBlockerResolution} from "./externalEventBlockerResolution";
import {HostAnalyticsCallableResponse} from "./hostAnalyticsCallableResponse";

/**
 * Schema-derived Admin SDK Firestore document types.
 *
 * The sibling generated document files model serialized JSON fixture
 * timestamps as {_seconds, _nanoseconds}. These types keep the same
 * schema-owned fields, but project Firestore timestamp values as live
 * FirebaseFirestore.Timestamp instances for Cloud Functions code that reads
 * and writes through the Admin SDK.
 */

// FirebaseFirestore.Timestamp is available globally through firebase-admin's
// @google-cloud/firestore dependency.

export type Gender = "man" | "woman" | "nonBinary" | "other";

/**
 * refundFailed marks a booking that failed AND whose automatic refund could not be issued, so the charge is stuck and needs manual reconciliation.
 */
export type PaymentStatus =
  | "pending"
  | "completed"
  | "failed"
  | "refunded"
  | "refundFailed";

/**
 * One structured written profile prompt answer stored on users and publicProfiles.
 */
export interface ProfilePromptAnswer {
  promptId: string;
  prompt: string;
  answer: string;
}

/**
 * One optional display prompt selected for a profile photo slot. The caption field is legacy-only and should no longer be written by clients.
 */
export interface PhotoPromptAnswer {
  photoIndex: number;
  promptId: string;
  prompt: string;
  /**
   * @deprecated
   * Legacy user-entered caption retained for compatibility with older documents.
   */
  caption?: string;
}

/**
 * Future canonical profile-photo object that groups display URLs, Firebase Storage object paths, prompt metadata, moderation state, order, and lifecycle timestamps.
 */
export interface ProfilePhoto {
  id: string;
  url: string;
  thumbnailUrl: string;
  storagePath: string;
  thumbnailStoragePath: string;
  prompt?: PhotoPromptAnswer | null;
  moderation?: {
    status: "pending" | "approved" | "rejected";
    reason?: string | null;
    reviewedAt?: FirebaseFirestore.Timestamp | null;
  } | null;
  position: number;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Canonical uploaded image object for ordered media galleries, logos, and event photos.
 */
export interface UploadedPhoto {
  id: string;
  url: string;
  storagePath: string;
  thumbnailUrl: string | null;
  thumbnailStoragePath: string | null;
  position: number;
  moderation?: {
    status: "pending" | "approved" | "rejected";
    reason?: string | null;
    reviewedAt?: FirebaseFirestore.Timestamp | null;
  } | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Per-activity user preferences. Running is the first migrated activity-specific preference object; other activity kinds can be added without new root profile fields.
 */
export interface ActivityPreferences {
  running: {
    paceMinSecsPerKm: number;
    paceMaxSecsPerKm: number;
    /**
     * @maxItems 12
     */
    preferredDistances: ("fiveK" | "tenK" | "halfMarathon" | "marathon")[];
    /**
     * @maxItems 12
     */
    runningReasons: (
      | "fitness"
      | "community"
      | "mindfulness"
      | "challenge"
      | "weightLoss"
      | "raceTraining"
      | "social"
    )[];
    /**
     * @maxItems 8
     */
    preferredRunTimes: (
      | "earlyMorning"
      | "morning"
      | "afternoon"
      | "evening"
      | "night"
    )[];
    version: number;
  };
}

/**
 * Canonical organizer-level ceiling for member affordances. Event policy may narrow these capabilities but may never widen them.
 */
export type OrganizerSupplyCapabilities = {
  mode: "unclaimed_read_only" | "claimed_managed";
  bookable: boolean;
  paymentsEnabled: boolean;
  waitlistEnabled: boolean;
  hostContactEnabled: boolean;
  claimable: boolean;
  reviewPolicy: "after_event_end" | "attended_event_only";
} & (
  | {
      mode: "unclaimed_read_only";
      bookable: false;
      paymentsEnabled: false;
      waitlistEnabled: false;
      hostContactEnabled: false;
      reviewPolicy: "after_event_end";
      [k: string]: unknown;
    }
  | {
      mode: "claimed_managed";
      bookable: true;
      paymentsEnabled: true;
      waitlistEnabled: true;
      hostContactEnabled: true;
      claimable: false;
      reviewPolicy: "attended_event_only";
      [k: string]: unknown;
    }
);

/**
 * Canonical meeting location selected from Google Places or a manually pinned map coordinate.
 */
export interface EventMeetingLocation {
  name: string;
  address?: string | null;
  placeId?: string | null;
  latitude: number;
  longitude: number;
  notes?: string | null;
}

export interface EventFormatSnapshot {
  version: number;
  activityKind:
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
  interactionModel:
    | "pacePods"
    | "pairedRotations"
    | "teamRotations"
    | "seatedTable"
    | "freeFormMixer"
    | "hostLedProgram"
    | "openFormat";
  customActivityLabel?: string;
  defaultPlaybookId?: string;
  /**
   * @maxItems 30
   */
  defaultModuleIds?: string[];
  eventSuccessPrimitives?: EventSuccessFormatPrimitives;
  activityDetails?: {
    /**
     * Composable operations for an event that moves through a route. Activity kind remains the broader format authority.
     */
    routePlan?: {
      version: 1;
      movementMode: "run" | "walk" | "ride" | "mixed";
      routeShape: "loop" | "outAndBack" | "pointToPoint";
      groupStrategy: "together" | "paceGroups" | "selfDirected";
      stopCadence: "continuous" | "flexibleStops" | "hostedStops";
      /**
       * @minItems 1
       * @maxItems 7
       */
      stopKinds: (
        | "water"
        | "regroup"
        | "venue"
        | "photoSpot"
        | "viewpoint"
        | "hazard"
        | "turnaround"
      )[];
      /**
       * @minItems 1
       * @maxItems 6
       */
      roleKinds: (
        | "routeLead"
        | "sweep"
        | "pacer"
        | "stopHost"
        | "marshal"
        | "photographer"
      )[];
    };
    [k: string]: unknown;
  };
}

/**
 * Optional event-success behavior primitives for custom or unsupported activity formats. These fields translate a saved event format into the small set of primitives event success can reason about.
 */
export interface EventSuccessFormatPrimitives {
  phoneAvailability?:
    | "continuous"
    | "plannedPauses"
    | "arrivalAndPostEventOnly"
    | "hostOnlyLive"
    | "noneDuringActivity";
  rotationSuitability?: "none" | "plannedBreaks" | "continuousRounds";
  assignmentAlgorithm?:
    | "none"
    | "pacePods"
    | "socialPods"
    | "pairRotations"
    | "teamBalancer"
    | "tableSeating";
  compatibilityPolicy?:
    | "none"
    | "socialCohortBalance"
    | "mutualInterestOnly"
    | "questionnaireClueOnly";
  matchingObjective?:
    | "coverage"
    | "romantic"
    | "affinity"
    | "novelty"
    | "balance"
    | "spread";
  unitOutcome?: "none" | "completion" | "score" | "rank";
  accountability?: "none" | "rollCall" | "sweep";
  durationShape?: "continuous" | "rounds" | "courses" | "segments";
}

export type EventSuccessStructureConfig = {
  [k: string]: unknown;
} & {
  unitKind: "wholeGroup" | "pods" | "pairs" | "teams" | "tables";
  unitSize: number;
  unitCount?: number | null;
  rotationIntervalMinutes?: number | null;
  topology?: "set" | "sequence" | "adjacency";
  resourceCapacity?: {
    concurrentUnits: number | null;
    resourceLabelId: "court" | "table" | "lane" | "board";
    seatsPerUnit: number | null;
  } | null;
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

export interface EventSuccessQuestionnaireConfig {
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
}

export interface EventSuccessDefaults {
  enabled?: boolean;
  layoutId?: string | null;
  playbookId?: string;
  /**
   * @maxItems 24
   */
  selectedModuleIds?: string[];
  moduleSelectionConfigured?: boolean;
  structureConfig?: EventSuccessStructureConfig;
  hostGoal?: string;
  wingmanRequestsEnabled?: boolean;
  contextualOpenersEnabled?: boolean;
  compatibilityAffectsRanking?: boolean;
  questionnaireConfig?: EventSuccessQuestionnaireConfig;
  attendeePrompt?: string | null;
}

export interface EventPolicyDefaults {
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
  crossPathsPairCapacity?: number;
  dynamicPricingStepInPaise?: number | null;
  dynamicPricingMaxInPaise?: number | null;
  cancellationPolicyId?: "flexible" | "standard" | "strict";
}

export interface ClubHostDefaults {
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
  eventPolicy?: EventPolicyDefaults;
  eventSuccess?: EventSuccessDefaults;
  eventSuccessByActivityKind?: Record<string, EventSuccessDefaults>;
}

export interface ClubHostProfile {
  uid: string;
  displayName: string;
  avatarUrl: string | null;
  role: "owner" | "host";
}

export interface EventConstraints {
  minAge: number;
  maxAge: number;
  maxMen?: number | null;
  maxWomen?: number | null;
}

export interface EventPolicyBundleDocument {
  version: number;
  admission: EventPolicyAdmissionDocument;
  pricing: EventPolicyPricingDocument;
  cancellation: {
    policyId: "notApplicable" | "flexible" | "standard" | "strict";
  };
  settlement: {
    hostPayoutTiming: "afterEventCompletion";
  };
}

export interface EventPolicyAdmissionDocument {
  format:
    | "open"
    | "inviteOnly"
    | "manualApproval"
    | "fixedCohortCaps"
    | "balancedRatio"
    | "membersOnly";
  capacityLimit: number;
  waitlistPolicy?: EventPolicyWaitlistDocument;
  inviteRequired?: boolean;
  membershipRequired?: boolean;
  manualApprovalRequired?: boolean;
  privateAccessPolicy?: EventPolicyPrivateAccessDocument;
  cohortCapacityLimits?: {
    [k: string]: number;
  };
  balancedRatioPolicy?: EventPolicyBalancedRatioDocument | null;
  crossPathsPairInventory?: {
    enabled: boolean;
    reservedPairCapacity: number;
    holdDurationMinutes: number;
  };
}

export interface EventPolicyPrivateAccessDocument {
  mode: "none" | "inviteCode";
  inviteCodeHint: string | null;
  privateLinkEnabled: boolean;
}

export interface EventPolicyWaitlistDocument {
  mode:
    | "disabled"
    | "rankedOffer"
    | "broadcastFirstComeFirstServed"
    | "manualReview";
  offerWindowMinutes: number;
}

export type EventPolicyBalancedRatioDocument = {
  leftCohortId: string;
  rightCohortId: string;
  maxSkew: number;
  openingBufferPerCohort: number;
  outOfRatioCohortPolicy:
    | "admitWithinGeneralCapacity"
    | "waitlist"
    | "manualReview"
    | "reject";
} & ({
  leftCohortId: string;
  rightCohortId: string;
  maxSkew: number;
  openingBufferPerCohort: number;
  outOfRatioCohortPolicy:
    | "admitWithinGeneralCapacity"
    | "waitlist"
    | "manualReview"
    | "reject";
} | null);

export interface EventPolicyPricingDocument {
  basePriceInPaise: number;
  cohortAdjustmentsInPaise?: {
    [k: string]: number;
  };
  demandPricingRules?: EventPolicyDemandPricingRuleDocument[];
}

export interface EventPolicyDemandPricingRuleDocument {
  pricedCohortId: string;
  balancingCohortId: string;
  stepAdjustmentInPaise: number;
  maxAdjustmentInPaise: number;
  freeSkew: number;
  demandStep: number;
}

/**
 * Immutable idempotency and audit receipt for a dry-run or applied external-event publication/takedown action.
 */
export interface ExternalEventPublicationReceiptDocument {
  schemaVersion: 1;
  receiptId: string;
  idempotencyKey: string;
  inputHash: string;
  action: "publish" | "takedown";
  executionMode: "dry_run" | "apply";
  outcome: "would_publish" | "published" | "would_remove" | "removed";
  eventId: string;
  targetPath: string;
  sourceActionId: string | null;
  externalLinkCount: number;
  reviewNote: string;
  actorUid: string;
  createdAt: FirebaseFirestore.Timestamp;
}

/**
 * Public launch-market configuration stored at config/cities. The app picks from launched markets; canonical market ids disambiguate same-name cities globally.
 */
export interface ConfigCitiesDocument {
  version: number;
  /**
   * Compatibility whitelist used by Firestore rules. Values are launched canonical market ids, not display city names.
   *
   * @minItems 1
   */
  cityNames: string[];
  /**
   * @minItems 1
   */
  marketIds: string[];
  /**
   * @minItems 1
   */
  launchMarketIds: string[];
  cities: {
    /**
     * App-facing selection id. Kept as name for existing CityData JSON, but stores the canonical market id.
     */
    name: string;
    cityId: string;
    marketId: string;
    slug: string;
    label: string;
    latitude: number;
    longitude: number;
    countryIsoCode: string;
    currencyCode: string;
    dialCode: string;
    timeZone: string;
    launchStatus: "launched" | "planned" | "paused" | "retired";
    profileSelectable: boolean;
    hostCreatable: boolean;
    eventCreatable: boolean;
    exploreVisible: boolean;
  }[];
  /**
   * @minItems 1
   */
  markets: {
    marketId: string;
    cityId: string;
    slug: string;
    label: string;
    cityLabel: string;
    regionCode: string;
    regionName: string;
    countryIsoCode: string;
    countryName: string;
    currencyCode: string;
    dialCode: string;
    timeZone: string;
    latitude: number;
    longitude: number;
    /**
     * @maxItems 40
     */
    aliases: string[];
    launchStatus: "launched" | "planned" | "paused" | "retired";
    profileSelectable: boolean;
    hostCreatable: boolean;
    eventCreatable: boolean;
    exploreVisible: boolean;
  }[];
}

/**
 * Owner-private, intentionally extensible onboarding draft stored at onboarding_drafts/{uid}.
 */
export interface OnboardingDraftDocument {
  step: number;
  draftVersion?: number;
  firstName?: string;
  lastName?: string;
  dateOfBirth?: FirebaseFirestore.Timestamp | null;
  phoneNumber?: string;
  countryCode?: string;
  gender?: ("man" | "woman" | "nonBinary" | "other") | null;
  interestedInGenders?: ("man" | "woman" | "nonBinary" | "other")[];
  instagramHandle?: string | null;
  /**
   * @maxItems 3
   */
  profilePrompts?: ProfilePromptAnswer[];
  [k: string]: unknown;
}

/**
 * Owner-submitted launch access application stored at accessApplications/{uid}; review and cohort fields are admin-owned.
 */
export interface AccessApplicationDocument {
  applicationVersion: number;
  status:
    | "pending"
    | "waitlisted"
    | "invited"
    | "approvedForProfile"
    | "activeMember"
    | "paused"
    | "notSelectedYet";
  city: string;
  role: "member" | "host" | "both";
  /**
   * @minItems 1
   * @maxItems 7
   */
  eventTypes: (
    | "runClub"
    | "walkingSocial"
    | "coffee"
    | "boardGames"
    | "fitnessClass"
    | "food"
    | "culture"
  )[];
  /**
   * @minItems 1
   * @maxItems 6
   */
  availabilityWindows: (
    | "weekdayMornings"
    | "weekdayEvenings"
    | "saturdayMornings"
    | "saturdayEvenings"
    | "sundayMornings"
    | "sundayEvenings"
  )[];
  wantsToHost: boolean;
  inviteCode?: string | null;
  instagramHandle?: string | null;
  referralSource?: string | null;
  whyCatch?: string | null;
  cohortId?: string | null;
  hostUserId?: string | null;
  reviewerUid?: string | null;
  reviewNote?: string | null;
  submissionCount: number;
  createdAt: FirebaseFirestore.Timestamp;
  submittedAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  reviewedAt?: FirebaseFirestore.Timestamp | null;
}

/**
 * Canonical private profile document stored at users/{uid}. The uid is the document id and is not stored in document data.
 */
export interface UserProfileDocument {
  name: string;
  firstName: string;
  lastName: string;
  displayName: string;
  dateOfBirth: FirebaseFirestore.Timestamp;
  gender: "man" | "woman" | "nonBinary" | "other";
  phoneNumber: string;
  countryCode?: string;
  profileComplete: boolean;
  email: "" | string;
  instagramHandle?: string | null;
  /**
   * @maxItems 3
   */
  profilePrompts: ProfilePromptAnswer[];
  /**
   * @maxItems 6
   */
  profilePhotos: ProfilePhoto[];
  city?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  /**
   * @minItems 1
   * @maxItems 8
   */
  interestedInGenders: ("man" | "woman" | "nonBinary" | "other")[];
  minAgePreference: number;
  maxAgePreference: number;
  height?: number | null;
  occupation?: string | null;
  company?: string | null;
  education?:
    | "highSchool"
    | "someCollege"
    | "bachelors"
    | "masters"
    | "phd"
    | "tradeSchool"
    | "other"
    | null;
  religion?:
    | "hindu"
    | "muslim"
    | "christian"
    | "sikh"
    | "jain"
    | "buddhist"
    | "other"
    | "nonReligious"
    | null;
  /**
   * @maxItems 20
   */
  languages: (
    | "english"
    | "hindi"
    | "marathi"
    | "tamil"
    | "telugu"
    | "kannada"
    | "bengali"
    | "gujarati"
    | "punjabi"
    | "malayalam"
    | "odia"
    | "other"
  )[];
  relationshipGoal?:
    | "relationship"
    | "casual"
    | "marriage"
    | "friendship"
    | "unsure"
    | null;
  drinking?: "never" | "socially" | "often" | null;
  smoking?: "never" | "occasionally" | "often" | null;
  workout?: "never" | "sometimes" | "often" | "everyday" | null;
  diet?: "omnivore" | "vegetarian" | "vegan" | "jain" | "other" | null;
  children?:
    | "dontHave"
    | "haveWantMore"
    | "haveNoMore"
    | "wantSomeday"
    | "dontWant"
    | null;
  activityPreferences: ActivityPreferences;
  prefsNewCatches: boolean;
  prefsMessages: boolean;
  prefsEventReminders: boolean;
  prefsRunStatusUpdates: boolean;
  prefsClubUpdates: boolean;
  prefsWeeklyDigest: boolean;
  prefsShowOnMap: boolean;
  /**
   * Private global consent gate for Cross Paths. Missing values resolve to false and this field must never be copied to publicProfiles.
   */
  prefsShowInCrossPaths?: boolean;
  /**
   * Opt-in push preference for Cross Paths invitations. Missing values resolve to false; durable Activity items are still written.
   */
  prefsCrossPathsInvitations?: boolean;
  fcmToken?: string;
  deleted?: boolean;
  deletedAt?: FirebaseFirestore.Timestamp | null;
}

/**
 * Backend-owned public profile projection stored at publicProfiles/{uid}. The uid is the document id and is not stored in document data.
 */
export interface PublicProfileDocument {
  name: string;
  age: number;
  gender: "man" | "woman" | "nonBinary" | "other";
  /**
   * @maxItems 3
   */
  profilePrompts: ProfilePromptAnswer[];
  /**
   * @maxItems 6
   */
  profilePhotos: ProfilePhoto[];
  city?: string | null;
  height?: number | null;
  occupation?: string | null;
  company?: string | null;
  education?:
    | "highSchool"
    | "someCollege"
    | "bachelors"
    | "masters"
    | "phd"
    | "tradeSchool"
    | "other"
    | null;
  religion?:
    | "hindu"
    | "muslim"
    | "christian"
    | "sikh"
    | "jain"
    | "buddhist"
    | "other"
    | "nonReligious"
    | null;
  /**
   * @maxItems 20
   */
  languages?: (
    | "english"
    | "hindi"
    | "marathi"
    | "tamil"
    | "telugu"
    | "kannada"
    | "bengali"
    | "gujarati"
    | "punjabi"
    | "malayalam"
    | "odia"
    | "other"
  )[];
  relationshipGoal?:
    | "relationship"
    | "casual"
    | "marriage"
    | "friendship"
    | "unsure"
    | null;
  drinking?: "never" | "socially" | "often" | null;
  smoking?: "never" | "occasionally" | "often" | null;
  workout?: "never" | "sometimes" | "often" | "everyday" | null;
  diet?: "omnivore" | "vegetarian" | "vegan" | "jain" | "other" | null;
  children?:
    | "dontHave"
    | "haveWantMore"
    | "haveNoMore"
    | "wantSomeday"
    | "dontWant"
    | null;
  activityPreferences: ActivityPreferences;
}

/**
 * Professional host identity stored at hostProfiles/{uid}. This document is separate from users/{uid} dating profile data and publicProfiles/{uid}.
 */
export interface HostProfileDocument {
  /**
   * Professional display name for host, club, event, and support-chat surfaces.
   */
  displayName: string;
  /**
   * Professional host avatar or organization logo URL.
   */
  avatarUrl?: string | null;
  /**
   * Professional title such as Founder, Coach, Organizer, or Community Lead.
   */
  roleTitle?: string | null;
  /**
   * Professional host bio. Must not mirror dating-profile prompts.
   */
  bio?: string | null;
  status: "active" | "pending" | "suspended";
  verified?: boolean;
  /**
   * @maxItems 20
   */
  linkedClubIds?: string[];
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Legacy storage contract for an organizer document stored at clubs/{clubId} during the clubs-to-organizers migration. The organizer id is the document id and is not stored in document data.
 */
export interface ClubDocument {
  name: string;
  /**
   * Member-facing organizer description. May be empty on hidden intake drafts until an operator supplies source-backed copy.
   */
  description: string;
  /**
   * Canonical launch market id. Public URL slugs live under publicPage.citySlug.
   */
  location: string;
  locationCityId: string;
  locationMarketId: string;
  /**
   * Verified locality within the canonical market. May be empty when intake evidence establishes only the city.
   */
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
  hostProfiles: ClubHostProfile[];
  createdAt: FirebaseFirestore.Timestamp;
  imageUrl: string | null;
  profileImageUrl: string | null;
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
  nextEventAt: FirebaseFirestore.Timestamp | null;
  nextEventLabel: string | null;
  instagramHandle: string | null;
  phoneNumber: string | null;
  email: string | null;
  status: "active" | "archived";
  archived: boolean;
  archivedAt: FirebaseFirestore.Timestamp | null;
  archiveReason: string | null;
  hostDefaults?: ClubHostDefaults;
  /**
   * Canonical organizer subtype. Legacy documents without this field normalize to club until backfill is complete.
   */
  organizerType?:
    | "club"
    | "community"
    | "individual"
    | "eventProducer"
    | "venue"
    | "brand";
  /**
   * Server-owned timestamp of the latest organizer type decision.
   */
  organizerTypeUpdatedAt?: FirebaseFirestore.Timestamp | null;
  /**
   * Server-owned user id that made the latest organizer type decision.
   */
  organizerTypeUpdatedByUid?: string | null;
  /**
   * Optional admin-curated public category copy. It never replaces organizerType as the classification authority.
   */
  publicCategoryLabel?: string | null;
  /**
   * Deprecated organizer classification retained only while legacy data and clients are migrated to organizerType.
   */
  entityKind?:
    | "club"
    | "venue"
    | "eventOrganizer"
    | "creatorCommunity"
    | "brand";
  /**
   * Deprecated free-form organizer classification retained only for migration reads.
   *
   * @maxItems 20
   */
  entitySubtypes?: string[];
  /**
   * Deprecated reader-facing category label retained until publicCategoryLabel migration is complete.
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
  supplyCapabilities?: OrganizerSupplyCapabilities;
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
    claimedAt: FirebaseFirestore.Timestamp | null;
    claimedByUid: string | null;
  };
  claim?: {
    state: "unclaimed" | "claimPending" | "claimed" | "verified" | "suppressed";
    claimHref: string | null;
    lastClaimRequestId: string | null;
  };
  publicPage?: {
    slug: string;
    citySlug: string;
    canonicalPath: string;
    publishStatus: "draft" | "qa" | "published" | "suppressed" | "removed";
    indexStatus: "noindex" | "indexReady" | "indexed";
    robots: "noindex, follow" | "index, follow";
    seoTitle: string | null;
    seoDescription: string | null;
    lastRenderedAt: FirebaseFirestore.Timestamp | null;
    indexReview?: {
      reviewedAt: FirebaseFirestore.Timestamp;
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
    lastVerifiedAt: FirebaseFirestore.Timestamp | null;
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
    updatedAt: FirebaseFirestore.Timestamp;
    updatedBySource:
      | "adminUpdateClubDetails"
      | "adminSetClubIndexStatus"
      | "adminOrganizerSearchBackfill"
      | "adminCreateOrganizerDraftFromCandidate";
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
    lastCheckedAt: FirebaseFirestore.Timestamp | null;
  }[];
}

/**
 * Canonical organizer document stored at organizers/{organizerId}. Club is one organizerType, not the parent entity name.
 */
export interface OrganizerDocument {
  name: string;
  /**
   * Member-facing organizer description. May be empty on hidden intake drafts until an operator supplies source-backed copy.
   */
  description: string;
  /**
   * Canonical launch market id. Public URL slugs live under publicPage.citySlug.
   */
  location: string;
  locationCityId: string;
  locationMarketId: string;
  /**
   * Verified locality within the canonical market. May be empty when intake evidence establishes only the city.
   */
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
  createdAt: FirebaseFirestore.Timestamp;
  imageUrl: string | null;
  profileImageUrl: string | null;
  clubPhotos?: UploadedPhoto[];
  /**
   * Canonical organizer gallery. clubPhotos is tolerated only while released clients migrate.
   */
  organizerPhotos: UploadedPhoto[];
  logoPhoto?: UploadedPhoto | null;
  /**
   * @maxItems 20
   */
  tags: string[];
  memberCount?: number;
  /**
   * Canonical active organizer follower count.
   */
  followerCount: number;
  rating: number;
  reviewCount: number;
  /**
   * Published reviews that are verified (attended a Catch event). Only these back the headline rating; unverified public reviews cannot move the score.
   */
  verifiedReviewCount?: number;
  nextEventAt: FirebaseFirestore.Timestamp | null;
  nextEventLabel: string | null;
  instagramHandle: string | null;
  phoneNumber: string | null;
  email: string | null;
  status: "active" | "archived";
  archived: boolean;
  archivedAt: FirebaseFirestore.Timestamp | null;
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
      crossPathsPairCapacity?: number;
      dynamicPricingStepInPaise?: number | null;
      dynamicPricingMaxInPaise?: number | null;
      cancellationPolicyId?: "flexible" | "standard" | "strict";
    };
    eventSuccess?: {
      enabled?: boolean;
      layoutId?: string | null;
      playbookId?: string;
      /**
       * @maxItems 24
       */
      selectedModuleIds?: string[];
      moduleSelectionConfigured?: boolean;
      structureConfig?: {
        [k: string]: unknown;
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
        layoutId?: string | null;
        playbookId?: string;
        /**
         * @maxItems 24
         */
        selectedModuleIds?: string[];
        moduleSelectionConfigured?: boolean;
        structureConfig?: {
          [k: string]: unknown;
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
   * Canonical organizer subtype. Legacy documents without this field normalize to club until backfill is complete.
   */
  organizerType:
    | "club"
    | "community"
    | "individual"
    | "eventProducer"
    | "venue"
    | "brand";
  /**
   * Server-owned timestamp of the latest organizer type decision.
   */
  organizerTypeUpdatedAt?: FirebaseFirestore.Timestamp | null;
  /**
   * Server-owned user id that made the latest organizer type decision.
   */
  organizerTypeUpdatedByUid?: string | null;
  /**
   * Optional admin-curated public category copy. It never replaces organizerType as the classification authority.
   */
  publicCategoryLabel?: string | null;
  /**
   * Deprecated organizer classification retained only while legacy data and clients are migrated to organizerType.
   */
  entityKind?:
    | "club"
    | "venue"
    | "eventOrganizer"
    | "creatorCommunity"
    | "brand";
  /**
   * Deprecated free-form organizer classification retained only for migration reads.
   *
   * @maxItems 20
   */
  entitySubtypes?: string[];
  /**
   * Deprecated reader-facing category label retained until publicCategoryLabel migration is complete.
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
  supplyCapabilities?: OrganizerSupplyCapabilities;
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
    claimedAt: FirebaseFirestore.Timestamp | null;
    claimedByUid: string | null;
  };
  claim?: {
    state: "unclaimed" | "claimPending" | "claimed" | "verified" | "suppressed";
    claimHref: string | null;
    lastClaimRequestId: string | null;
  };
  publicPage?: {
    slug: string;
    citySlug: string;
    canonicalPath: string;
    /**
     * @maxItems 12
     */
    legacyPaths?: string[];
    publishStatus: "draft" | "qa" | "published" | "suppressed" | "removed";
    indexStatus: "noindex" | "indexReady" | "indexed";
    robots: "noindex, follow" | "index, follow";
    seoTitle: string | null;
    seoDescription: string | null;
    lastRenderedAt: FirebaseFirestore.Timestamp | null;
    indexReview?: {
      reviewedAt: FirebaseFirestore.Timestamp;
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
    lastVerifiedAt: FirebaseFirestore.Timestamp | null;
  };
  /**
   * Bounded server-only lineage for fields seeded by Supply Intake. Raw provider payloads are never stored here. This snapshot lets audited admin edits produce immutable field-correction fixtures.
   */
  intakeLearningSource?: {
    sourceProfileId: string;
    sourceWorkItemId: string;
    sourceCandidateId: string;
    /**
     * @maxItems 40
     */
    seededFields: {
      field:
        | "name"
        | "location"
        | "tags"
        | "publicProfile.sourceSummary"
        | "publicProfile.formats"
        | "publicSources[0].href";
      extractedValue: string | null | string[];
      artifactId: string;
      contentHash: string;
      locator: string | null;
      extractedBy: "deterministic" | "model" | "human";
      extractorVersion: string;
      confidence: number | null;
    }[];
    capturedAt: FirebaseFirestore.Timestamp;
  };
  /**
   * Server-owned deterministic search projection used by admin organizer publishing. Rebuildable from canonical organizer fields; not consumed by the app.
   */
  adminSearch?: {
    /**
     * @maxItems 120
     */
    tokens: string[];
    sortKey: string;
    updatedAt: FirebaseFirestore.Timestamp;
    updatedBySource:
      | "adminCreateOrganizerDraftFromCandidate"
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
    lastCheckedAt: FirebaseFirestore.Timestamp | null;
  }[];
}

/**
 * Canonical organizer post stored at organizers/{organizerId}/posts/{postId}.
 */
export interface OrganizerPostDocument {
  authorUid: string;
  text: string;
  photoPath?: string | null;
  eventId?: string | null;
  audience: "followers";
  createdAt: FirebaseFirestore.Timestamp;
  status: "active" | "removed";
}

/**
 * Server-owned retry state and aggregate delivery receipt for one organizer follower update.
 */
export interface OrganizerPostDeliveryOperationDocument {
  organizerId: string;
  postId: string;
  authorUid: string;
  requestId: string;
  payloadHash: string;
  status: "pending" | "processing" | "completed" | "partial";
  remainingWeeklyQuota: number;
  cursorFollowId: string | null;
  recipientCount: number;
  excludedCount: number;
  activityAvailableCount: number;
  pushAttemptedCount: number;
  pushAcceptedCount: number;
  pushFailedCount: number;
  pushUnknownCount: number;
  /**
   * @maxItems 20
   */
  errorCodes: string[];
  attemptCount: number;
  leaseOwner: string | null;
  leaseExpiresAt: FirebaseFirestore.Timestamp | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  completedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Server-only post-scoped, de-identified per-recipient retry evidence for an organizer follower update.
 */
export interface OrganizerPostDeliveryRecipientDocument {
  organizerId: string;
  postId: string;
  activityStatus: "created" | "existing" | "failed";
  pushStatus: "ineligible" | "accepted" | "failed" | "unknown";
  activityNotificationId: string;
  excluded: boolean;
  errorCode: string | null;
  expiresAt: FirebaseFirestore.Timestamp;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Canonical owner or manager edge stored at organizerTeamMemberships/{organizerId_uid}.
 */
export interface OrganizerTeamMembershipDocument {
  organizerId: string;
  uid: string;
  role: "owner" | "manager";
  status: "active" | "removed";
  createdAt: FirebaseFirestore.Timestamp;
  removedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Canonical consumer follow edge stored at organizerFollows/{organizerId_uid}.
 */
export interface OrganizerFollowDocument {
  organizerId: string;
  uid: string;
  status: "active" | "inactive";
  pushNotificationsEnabled: boolean;
  followedAt: FirebaseFirestore.Timestamp;
  unfollowedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Server-owned, organizer-scoped channel consent stored at organizerCommunicationPreferences/{organizerId_uid}.
 */
export interface OrganizerCommunicationPreferenceDocument {
  organizerId: string;
  uid: string;
  whatsapp: {
    status: "unknown" | "optedIn" | "optedOut";
    termsVersion: string | null;
    source:
      | null
      | "publicEventRegistration"
      | "unsubscribeLink"
      | "hostApp"
      | "inboundStop"
      | "providerWebhook";
    sourceEventId: string | null;
    updatedAt: FirebaseFirestore.Timestamp | null;
  };
  sms: {
    status: "unknown" | "optedIn" | "optedOut";
    termsVersion: string | null;
    source:
      | null
      | "publicEventRegistration"
      | "unsubscribeLink"
      | "hostApp"
      | "inboundStop"
      | "providerWebhook";
    sourceEventId: string | null;
    updatedAt: FirebaseFirestore.Timestamp | null;
  };
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

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
    | "providerSync";
  /**
   * @maxItems 20
   */
  ambiguousCandidateContactIds: string[];
  firstSeenAt: FirebaseFirestore.Timestamp;
  lastSeenAt: FirebaseFirestore.Timestamp;
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
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  deletedAt: FirebaseFirestore.Timestamp | null;
  /**
   * Organizer-requested CRM hiding. Operational attendee and audit facts remain intact.
   */
  hiddenAt?: FirebaseFirestore.Timestamp | null;
  hiddenBy?: string | null;
  /**
   * Bounded organizer-audience contribution snapshot used only to restore a hidden contact without recomputing private event history.
   */
  hiddenTraitSnapshot?: OrganizerContactTraitDocument | null;
}

/**
 * Organizer-scoped, author-stamped CRM note. Notes are exposed only through manager-authorized callables and are excluded from contact exports.
 */
export interface OrganizerContactNoteDocument {
  organizerId: string;
  contactId: string;
  authorUid: string;
  body: string;
  revision: number;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  updatedByUid: string;
}

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
    createdAt: FirebaseFirestore.Timestamp;
  }[];
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-only identity evidence edge used for keyed candidate lookup. Hashes are restricted identifiers, not anonymous data.
 */
export interface OrganizerContactIdentityLinkDocument {
  organizerId: string;
  contactId: string;
  originContactId: string;
  attendeeId: string;
  kind: "uid" | "phone" | "email" | "provider";
  identityHash: string;
  hashVersion: "hmac-sha256-v1";
  confidence: "proposed" | "verified";
  source:
    | "catchBooking"
    | "hostImport"
    | "hostManual"
    | "webOtp"
    | "providerSync";
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Singleton organizer-scoped ownership claim for a person-verified UID or phone identity.
 */
export interface OrganizerContactIdentityClaimDocument {
  organizerId: string;
  kind: "uid" | "phone";
  identityHash: string;
  hashVersion: "hmac-sha256-v1";
  verifiedContactId: string;
  originVerifiedContactId: string;
  state: "verified" | "conflicted";
  /**
   * @maxItems 20
   */
  conflictingContactIds: string[];
  revision: number;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Rebuildable organizer-person-event fact edge projected from the canonical operational attendee.
 */
export interface OrganizerContactEventEdgeDocument {
  organizerId: string;
  contactId: string;
  originContactId: string;
  eventId: string;
  attendeeId: string;
  displayName: string;
  linkedUid: string | null;
  phoneE164: string | null;
  email: string | null;
  source:
    | "catchBooking"
    | "hostImport"
    | "hostManual"
    | "webOtp"
    | "providerSync";
  status: "invited" | "registered" | "waitlisted" | "checkedIn" | "cancelled";
  expected: boolean;
  registered: boolean;
  cancelled: boolean;
  checkedIn: boolean;
  eventStartAt: FirebaseFirestore.Timestamp | null;
  eventEndAt: FirebaseFirestore.Timestamp | null;
  registeredAt: FirebaseFirestore.Timestamp | null;
  cancelledAt: FirebaseFirestore.Timestamp | null;
  checkedInAt: FirebaseFirestore.Timestamp | null;
  inviteLinkId?: string | null;
  inviteCapturedAt?: FirebaseFirestore.Timestamp | null;
  sourceCreatedAt: FirebaseFirestore.Timestamp;
  sourceUpdatedAt: FirebaseFirestore.Timestamp;
  revision: number;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Rebuildable, explainable organizer-contact CRM traits. Sensitive Event Success answers are excluded by contract.
 */
export interface OrganizerContactTraitDocument {
  organizerId: string;
  contactId: string;
  expectedEventCount: number;
  attendedEventCount: number;
  cancelledEventCount: number;
  noShowCount: number;
  importedEventCount: number;
  referredRegistrationCount: number;
  referredCheckedInCount: number;
  referredCheckedIn365DayCount: number;
  linkedAccount: boolean;
  firstSeenAt: FirebaseFirestore.Timestamp;
  lastSeenAt: FirebaseFirestore.Timestamp;
  firstAttendedAt: FirebaseFirestore.Timestamp | null;
  lastAttendedAt: FirebaseFirestore.Timestamp | null;
  attendanceRate: number | null;
  /**
   * @maxItems 16
   */
  segmentIds: (
    | "new_to_organizer"
    | "first_time_attendee"
    | "repeat_attendee"
    | "regular"
    | "lapsed_regular"
    | "reliable_attendee"
    | "needs_confirmation"
    | "advocate"
    | "high_impact_advocate"
    | "whatsapp_reachable"
    | "sms_reachable"
  )[];
  definitionVersion: number;
  whatsappStatus: "unknown" | "optedIn" | "optedOut";
  smsStatus: "unknown" | "optedIn" | "optedOut";
  sourceCoverage: "exact" | "partial" | "insufficientData";
  projectionVersion: number;
  computedAt: FirebaseFirestore.Timestamp;
}

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
  advocateCount: number;
  highImpactAdvocateCount: number;
  whatsappOptInCount: number;
  smsOptInCount: number;
  sourceCoverage: "exact" | "partial";
  projectionVersion: number;
  computedAt: FirebaseFirestore.Timestamp;
}

/**
 * Short-lived exactly-once receipt for a contact-trait delta applied to an organizer audience summary.
 */
export interface OrganizerAudienceProjectionReceiptDocument {
  organizerId: string;
  eventId: string;
  createdAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Immutable evidence for a manager-confirmed organizer contact merge or its reversal.
 */
export interface OrganizerContactMergeReceiptDocument {
  organizerId: string;
  operation: "merge" | "unmerge";
  survivorContactId: string;
  sourceContactId: string;
  /**
   * @maxItems 20
   */
  evidence: (
    | "sameVerifiedUid"
    | "sameVerifiedPhone"
    | "sameImportedPhone"
    | "sameEmail"
    | "managerConfirmed"
  )[];
  /**
   * @maxItems 20
   */
  conflicts: string[];
  actorUid: string;
  survivorRevision: number;
  sourceRevision: number;
  /**
   * @maxItems 400
   */
  movedEdgeIds: string[];
  /**
   * @maxItems 400
   */
  movedIdentityEvidenceIds: string[];
  /**
   * @maxItems 400
   */
  movedClaimIds: string[];
  movedEdgeCount: number;
  movedIdentityEvidenceCount: number;
  movedClaimCount: number;
  idempotencyKey: string;
  reversalOfReceiptId: string | null;
  createdAt: FirebaseFirestore.Timestamp;
}

/**
 * Latest manager decision for one deterministic organizer-contact candidate pair. A different-people decision suppresses the pair until the same manager reopens it.
 */
export interface OrganizerContactMergeReviewDecisionDocument {
  schemaVersion: 1;
  decisionId: string;
  organizerId: string;
  /**
   * @minItems 2
   * @maxItems 2
   */
  contactIds: string[];
  state: "differentPeople" | "reopened";
  reviewedByUid: string;
  reviewedAt: FirebaseFirestore.Timestamp;
  reopenedByUid: string | null;
  reopenedAt: FirebaseFirestore.Timestamp | null;
  revision: number;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Safe organizer-owned messaging sender metadata. Provider access tokens live in Secret Manager, never Firestore.
 */
export interface OrganizerSenderConnectionDocument {
  organizerId: string;
  channel: "whatsapp";
  provider: "metaCloudApi";
  status:
    | "pending"
    | "testing"
    | "active"
    | "degraded"
    | "blocked"
    | "tokenRevoked"
    | "disconnected";
  wabaId: string | null;
  phoneNumberId: string | null;
  businessId: string | null;
  displayPhoneNumber: string | null;
  verifiedName: string | null;
  secretVersionResource: string | null;
  qualityRating: null | "GREEN" | "YELLOW" | "RED" | "UNKNOWN";
  messagingLimitTier: string | null;
  templateSyncStatus: "notStarted" | "current" | "stale" | "failed";
  webhookStatus: "notSubscribed" | "subscribed" | "degraded";
  testStatus: "notSent" | "pending" | "delivered" | "failed";
  testProviderMessageId: string | null;
  testRecipientHash: string | null;
  connectedByUid: string;
  revision: number;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  lastHealthSyncAt?: FirebaseFirestore.Timestamp | null;
  disconnectedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Safe organizer-owned booking-provider connection metadata. Provider credentials live in Secret Manager, never Firestore.
 */
export interface OrganizerProviderConnectionDocument {
  organizerId: string;
  provider: "luma";
  adapterClass: "A";
  status: "active" | "degraded" | "credentialRevoked" | "disconnected";
  externalAccountId: string;
  externalAccountName: string;
  secretVersionResource: string | null;
  syncMode: "manualPoll";
  capabilities: {
    eventList: boolean;
    rosterIdentity: boolean;
    registrationStatus: boolean;
    providerCheckIn: boolean;
    orderAmount: boolean;
    refundStatus: boolean;
    referralCode: boolean;
    webhooks: boolean;
    writeBookings: boolean;
  };
  connectedByUid: string;
  revision: number;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  lastHealthSyncAt: FirebaseFirestore.Timestamp | null;
  lastSuccessfulSyncAt: FirebaseFirestore.Timestamp | null;
  lastErrorCode: string | null;
  disconnectedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Provider-neutral organizer-owned application form metadata. Published questions live in immutable version documents.
 */
export interface OrganizerApplicationFormDocument {
  organizerId: string;
  createdByUid: string;
  title: string;
  description: string | null;
  status: "draft" | "published" | "archived";
  defaultTargetKind: "organizer" | "event" | "campaign";
  activeVersionId: string | null;
  revision: number;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  archivedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Immutable published or imported snapshot of one organizer application form.
 */
export interface OrganizerApplicationFormVersionDocument {
  organizerId: string;
  formId: string;
  version: number;
  state: "draftSnapshot" | "published" | "retired";
  title: string;
  description: string | null;
  /**
   * @minItems 1
   * @maxItems 100
   */
  questions: {
    questionId: string;
    key: string;
    label: string;
    helpText: string | null;
    kind:
      | "shortText"
      | "longText"
      | "singleChoice"
      | "multiChoice"
      | "date"
      | "phone"
      | "email"
      | "url"
      | "number"
      | "boolean"
      | "file";
    required: boolean;
    /**
     * @maxItems 100
     */
    options: {
      optionId: string;
      label: string;
      value: string;
    }[];
    canonicalFieldId:
      | (
          | "givenName"
          | "familyName"
          | "displayName"
          | "dateOfBirth"
          | "age"
          | "gender"
          | "phoneNumber"
          | "email"
          | "instagramHandle"
          | "linkedinUrl"
          | "profilePhoto"
          | "city"
          | "heightCm"
          | "occupation"
          | "company"
          | "education"
          | "languages"
          | "relationshipGoal"
          | "interestedInGenders"
          | "drinking"
          | "smoking"
          | "religion"
          | "workout"
          | "diet"
          | "children"
        )
      | null;
    privacyClass: "contact" | "profile" | "sensitive" | "organizerCustom";
    prefillPolicy: "never" | "participantReviewRequired";
    hostPresentation: "detailOnly" | "filterable" | "sortable";
  }[];
  consentCopy: string;
  consentVersion: string;
  retentionCopy: string;
  createdByUid: string;
  createdAt: FirebaseFirestore.Timestamp;
  publishedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Organizer-owned generic form metadata and lifecycle. Editable content lives in a draft and published content in immutable versions.
 */
export interface OrganizerFormDocument {
  organizerId: string;
  createdByUid: string;
  title: string;
  description: string | null;
  purpose:
    | "application"
    | "registration"
    | "intake"
    | "waiver"
    | "feedback"
    | "survey";
  status: "draft" | "published" | "paused" | "archived";
  templateId: string | null;
  publicFormId: string;
  defaultTargetKind: "organizer" | "event" | "campaign";
  defaultTargetId: string | null;
  activeVersionId: string | null;
  draftRevision: number;
  publishedVersion: number;
  submittedResponseCount: number;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  publishedAt: FirebaseFirestore.Timestamp | null;
  pausedAt: FirebaseFirestore.Timestamp | null;
  archivedAt: FirebaseFirestore.Timestamp | null;
  lastResponseAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Mutable optimistic-revision builder state for one organizer form.
 */
export interface OrganizerFormDraftDocument {
  organizerId: string;
  formId: string;
  revision: number;
  definition: {
    title: string;
    description: string | null;
    purpose:
      | "application"
      | "registration"
      | "intake"
      | "waiver"
      | "feedback"
      | "survey";
    defaultTargetKind: "organizer" | "event" | "campaign";
    defaultTargetId: string | null;
    identityPolicy:
      | "anonymous"
      | "emailVerified"
      | "phoneVerified"
      | "emailOrPhoneVerified"
      | "catchAccount";
    /**
     * @minItems 1
     * @maxItems 40
     */
    sections: {
      sectionId: string;
      title: string;
      description: string | null;
      pageBreak: boolean;
      /**
       * @maxItems 100
       */
      questions: {
        questionId: string;
        key: string;
        label: string;
        helpText: string | null;
        kind:
          | "shortText"
          | "longText"
          | "singleChoice"
          | "multiChoice"
          | "date"
          | "phone"
          | "email"
          | "url"
          | "number"
          | "boolean"
          | "file"
          | "acknowledgement"
          | "signature";
        required: boolean;
        /**
         * @maxItems 100
         */
        options: {
          optionId: string;
          label: string;
          value: string;
        }[];
        canonicalFieldId:
          | (
              | "givenName"
              | "familyName"
              | "displayName"
              | "dateOfBirth"
              | "age"
              | "gender"
              | "phoneNumber"
              | "email"
              | "instagramHandle"
              | "linkedinUrl"
              | "profilePhoto"
              | "city"
              | "heightCm"
              | "occupation"
              | "company"
              | "education"
              | "languages"
              | "relationshipGoal"
              | "interestedInGenders"
              | "drinking"
              | "smoking"
              | "religion"
              | "workout"
              | "diet"
              | "children"
            )
          | null;
        privacyClass: "contact" | "profile" | "sensitive" | "organizerCustom";
        prefillPolicy: "never" | "participantReviewRequired";
        hostPresentation: "detailOnly" | "filterable" | "sortable";
        validation: {
          minLength: number | null;
          maxLength: number | null;
          minNumber: number | null;
          maxNumber: number | null;
          earliestDate: string | null;
          latestDate: string | null;
          minSelections: number | null;
          maxSelections: number | null;
          maxFileCount: number | null;
          maxFileSizeBytes: number | null;
          /**
           * @maxItems 20
           */
          allowedMimeTypes: string[];
          patternPreset:
            | null
            | "lettersAndSpaces"
            | "alphanumeric"
            | "postalCode"
            | "handle";
          customError: string | null;
        };
      }[];
    }[];
    /**
     * @maxItems 100
     */
    logicRules: {
      ruleId: string;
      conditionMode: "all" | "any";
      /**
       * @minItems 1
       * @maxItems 20
       */
      conditions: {
        questionId: string;
        operator:
          | "equals"
          | "notEquals"
          | "contains"
          | "notContains"
          | "greaterThan"
          | "lessThan"
          | "answered"
          | "notAnswered";
        /**
         * @maxItems 20
         */
        expectedValues: (string | number | boolean)[];
      }[];
      action:
        | "showQuestion"
        | "hideQuestion"
        | "showSection"
        | "hideSection"
        | "routeToSection"
        | "finish";
      targetQuestionId: string | null;
      targetSectionId: string | null;
    }[];
    appearance: {
      preset: "editorial" | "minimal" | "activity";
      logoAssetId: string | null;
      coverAssetId: string | null;
      activityKind: string | null;
    };
    availability: {
      opensAt: FirebaseFirestore.Timestamp | null;
      closesAt: FirebaseFirestore.Timestamp | null;
      responseLimit: number | null;
      closedMessage: string | null;
    };
    consent: {
      consentCopy: string;
      consentVersion: string;
      retentionCopy: string;
    };
    completion: {
      title: string;
      message: string | null;
      actionKind: "none" | "externalUrl" | "event" | "eventRuntime";
      actionLabel: string | null;
      actionUrl: string | null;
    };
  };
  updatedByUid: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Immutable published definition of one generic organizer form version.
 */
export interface OrganizerFormVersionDocument {
  organizerId: string;
  formId: string;
  version: number;
  sourceDraftRevision: number;
  definition: {
    title: string;
    description: string | null;
    purpose:
      | "application"
      | "registration"
      | "intake"
      | "waiver"
      | "feedback"
      | "survey";
    defaultTargetKind: "organizer" | "event" | "campaign";
    defaultTargetId: string | null;
    identityPolicy:
      | "anonymous"
      | "emailVerified"
      | "phoneVerified"
      | "emailOrPhoneVerified"
      | "catchAccount";
    /**
     * @minItems 1
     * @maxItems 40
     */
    sections: {
      sectionId: string;
      title: string;
      description: string | null;
      pageBreak: boolean;
      /**
       * @maxItems 100
       */
      questions: {
        questionId: string;
        key: string;
        label: string;
        helpText: string | null;
        kind:
          | "shortText"
          | "longText"
          | "singleChoice"
          | "multiChoice"
          | "date"
          | "phone"
          | "email"
          | "url"
          | "number"
          | "boolean"
          | "file"
          | "acknowledgement"
          | "signature";
        required: boolean;
        /**
         * @maxItems 100
         */
        options: {
          optionId: string;
          label: string;
          value: string;
        }[];
        canonicalFieldId:
          | (
              | "givenName"
              | "familyName"
              | "displayName"
              | "dateOfBirth"
              | "age"
              | "gender"
              | "phoneNumber"
              | "email"
              | "instagramHandle"
              | "linkedinUrl"
              | "profilePhoto"
              | "city"
              | "heightCm"
              | "occupation"
              | "company"
              | "education"
              | "languages"
              | "relationshipGoal"
              | "interestedInGenders"
              | "drinking"
              | "smoking"
              | "religion"
              | "workout"
              | "diet"
              | "children"
            )
          | null;
        privacyClass: "contact" | "profile" | "sensitive" | "organizerCustom";
        prefillPolicy: "never" | "participantReviewRequired";
        hostPresentation: "detailOnly" | "filterable" | "sortable";
        validation: {
          minLength: number | null;
          maxLength: number | null;
          minNumber: number | null;
          maxNumber: number | null;
          earliestDate: string | null;
          latestDate: string | null;
          minSelections: number | null;
          maxSelections: number | null;
          maxFileCount: number | null;
          maxFileSizeBytes: number | null;
          /**
           * @maxItems 20
           */
          allowedMimeTypes: string[];
          patternPreset:
            | null
            | "lettersAndSpaces"
            | "alphanumeric"
            | "postalCode"
            | "handle";
          customError: string | null;
        };
      }[];
    }[];
    /**
     * @maxItems 100
     */
    logicRules: {
      ruleId: string;
      conditionMode: "all" | "any";
      /**
       * @minItems 1
       * @maxItems 20
       */
      conditions: {
        questionId: string;
        operator:
          | "equals"
          | "notEquals"
          | "contains"
          | "notContains"
          | "greaterThan"
          | "lessThan"
          | "answered"
          | "notAnswered";
        /**
         * @maxItems 20
         */
        expectedValues: (string | number | boolean)[];
      }[];
      action:
        | "showQuestion"
        | "hideQuestion"
        | "showSection"
        | "hideSection"
        | "routeToSection"
        | "finish";
      targetQuestionId: string | null;
      targetSectionId: string | null;
    }[];
    appearance: {
      preset: "editorial" | "minimal" | "activity";
      logoAssetId: string | null;
      coverAssetId: string | null;
      activityKind: string | null;
    };
    availability: {
      opensAt: FirebaseFirestore.Timestamp | null;
      closesAt: FirebaseFirestore.Timestamp | null;
      responseLimit: number | null;
      closedMessage: string | null;
    };
    consent: {
      consentCopy: string;
      consentVersion: string;
      retentionCopy: string;
    };
    completion: {
      title: string;
      message: string | null;
      actionKind: "none" | "externalUrl" | "event" | "eventRuntime";
      actionLabel: string | null;
      actionUrl: string | null;
    };
  };
  createdByUid: string;
  createdAt: FirebaseFirestore.Timestamp;
  publishedAt: FirebaseFirestore.Timestamp;
}

/**
 * Expiring version-bound respondent autosave state.
 */
export interface OrganizerFormResponseDraftDocument {
  organizerId: string;
  formId: string;
  versionId: string;
  publicFormId: string;
  status: "active" | "submitted" | "expired" | "withdrawn";
  revision: number;
  identityKind:
    | "anonymous"
    | "emailVerified"
    | "phoneVerified"
    | "catchAccount";
  respondentUid: string | null;
  draftTokenHash: string | null;
  answers: {
    [k: string]: string | number | boolean | null | string[];
  };
  consentAccepted: boolean;
  consentVersion: string;
  sourceLinkId: string | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
  submittedResponseId: string | null;
}

/**
 * Immutable submitted response envelope with withdrawal state.
 */
export interface OrganizerFormResponseDocument {
  organizerId: string;
  formId: string;
  versionId: string;
  publicFormId: string;
  draftId: string;
  status: "submitted" | "withdrawn";
  identityKind:
    | "anonymous"
    | "emailVerified"
    | "phoneVerified"
    | "catchAccount";
  respondentUid: string | null;
  identity: {
    displayName: string | null;
    email: string | null;
    phoneE164: string | null;
    searchName: string | null;
    origin: "anonymous" | "respondentGranted" | "organizerAcquired";
  };
  withdrawalTokenHash: string | null;
  answers: {
    [k: string]: string | number | boolean | null | string[];
  };
  /**
   * @maxItems 4000
   */
  answerSnapshots: {
    questionId: string;
    key: string;
    label: string;
    kind:
      | "shortText"
      | "longText"
      | "singleChoice"
      | "multiChoice"
      | "date"
      | "phone"
      | "email"
      | "url"
      | "number"
      | "boolean"
      | "file"
      | "acknowledgement"
      | "signature";
    answer: string | number | boolean | null | string[];
  }[];
  consentVersion: string;
  sourceLinkId: string | null;
  completionMillis: number;
  submittedAt: FirebaseFirestore.Timestamp;
  withdrawnAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Version- and draft-scoped metadata for private respondent uploads; bytes remain in protected Storage.
 */
export interface OrganizerFormAssetDocument {
  organizerId: string;
  formId: string;
  versionId: string;
  draftId: string;
  questionId: string;
  respondentUid: string | null;
  uploadTokenHash: string;
  storagePath: string;
  originalFileName: string;
  contentType: "image/jpeg" | "image/png" | "image/webp" | "application/pdf";
  declaredSizeBytes: number;
  declaredSha256: string;
  sizeBytes: number | null;
  status: "uploading" | "ready" | "rejected" | "deleted";
  createdAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
  finalizedAt: FirebaseFirestore.Timestamp | null;
  deletedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Precomputed form/version funnel or privacy-aware question aggregate.
 */
export interface OrganizerFormAggregateDocument {
  organizerId: string;
  formId: string;
  versionId: string;
  scope: "version" | "question";
  questionId: string | null;
  questionLabel: string | null;
  questionKind:
    | (
        | "shortText"
        | "longText"
        | "singleChoice"
        | "multiChoice"
        | "date"
        | "phone"
        | "email"
        | "url"
        | "number"
        | "boolean"
        | "file"
        | "acknowledgement"
        | "signature"
      )
    | null;
  privacyClass: null | "contact" | "profile" | "sensitive" | "organizerCustom";
  opens: number;
  starts: number;
  submissions: number;
  withdrawals: number;
  completionMillisTotal: number;
  /**
   * @maxItems 12
   */
  completionBuckets: {
    upperBoundMillis: number;
    count: number;
  }[];
  /**
   * @maxItems 100
   */
  choiceCounts: {
    value: string | boolean;
    label: string;
    count: number;
  }[];
  numericCount: number;
  numericSum: number;
  numericMin: number | null;
  numericMax: number | null;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Idempotency marker for one aggregate projection event.
 */
export interface OrganizerFormAggregateEventDocument {
  organizerId: string;
  formId: string;
  versionId: string;
  responseId: string;
  eventKind: "submitted" | "withdrawn";
  projectedAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Asynchronous, expiring, manager-requested form response export receipt.
 */
export interface OrganizerFormExportDocument {
  organizerId: string;
  formId: string;
  requestedByUid: string;
  requestId: string;
  format: "csv" | "xlsx";
  /**
   * @minItems 1
   * @maxItems 2
   */
  statuses: ("submitted" | "withdrawn")[];
  versionId: string | null;
  fromMillis: number | null;
  toMillis: number | null;
  status: "pending" | "running" | "completed" | "failed" | "expired";
  rowCount: number;
  storagePath: string | null;
  errorCode: string | null;
  errorMessage: string | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  completedAt: FirebaseFirestore.Timestamp | null;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Manager-authored, revisioned, explicit form automation.
 */
export interface OrganizerFormAutomationRuleDocument {
  organizerId: string;
  formId: string;
  name: string;
  enabled: boolean;
  revision: number;
  trigger: "responseSubmitted" | "responseWithdrawn" | "answerMatches";
  condition: {
    questionId: string;
    operator:
      | "equals"
      | "notEquals"
      | "contains"
      | "notContains"
      | "greaterThan"
      | "lessThan"
      | "answered"
      | "notAnswered";
    /**
     * @maxItems 20
     */
    expectedValues: (string | number | boolean)[];
  } | null;
  /**
   * @minItems 1
   * @maxItems 10
   */
  actions: {
    actionId: string;
    kind:
      | "notifyTeam"
      | "addOrganizerTag"
      | "createCrmContact"
      | "addApplicationQueue"
      | "proposeEventAttendee"
      | "signedWebhook"
      | "campaignHandoff";
    tagId: string | null;
    eventId: string | null;
    webhookUrl: string | null;
    webhookSecret: string | null;
    channel: null | "whatsapp" | "email";
  }[];
  createdByUid: string;
  updatedByUid: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Idempotent, observable execution of one rule revision for one response event.
 */
export interface OrganizerFormAutomationRunDocument {
  organizerId: string;
  formId: string;
  ruleId: string;
  ruleRevision: number;
  responseId: string;
  eventKind: "submitted" | "withdrawn";
  status:
    | "pending"
    | "running"
    | "succeeded"
    | "partiallyFailed"
    | "failed"
    | "skipped";
  attemptCount: number;
  /**
   * @maxItems 10
   */
  actionResults: {
    actionId: string;
    kind:
      | "notifyTeam"
      | "addOrganizerTag"
      | "createCrmContact"
      | "addApplicationQueue"
      | "proposeEventAttendee"
      | "signedWebhook"
      | "campaignHandoff";
    status: "succeeded" | "failed" | "skipped";
    resultId: string | null;
    errorCode: string | null;
  }[];
  errorCode: string | null;
  errorMessage: string | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  completedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Idempotent reviewed downstream conversion and safe-undo boundary.
 */
export interface OrganizerFormConversionReceiptDocument {
  organizerId: string;
  formId: string;
  responseId: string;
  kind: "crmContact" | "application" | "eventAttendeeProposal" | "followUp";
  requestId: string;
  actorUid: string;
  status: "pending" | "completed" | "failed";
  /**
   * @maxItems 100
   */
  fields: {
    destinationField: string;
    label: string;
    value: string | number | boolean | null;
    origin: "verifiedIdentity" | "formAnswer" | "hostOverride";
    conflict: string | null;
  }[];
  resultId: string | null;
  undoStatus: "notAvailable" | "available" | "used" | "expired";
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  completedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Organizer-owned source-attributed stable public form link.
 */
export interface OrganizerFormShareLinkDocument {
  organizerId: string;
  formId: string;
  publicFormId: string;
  label: string;
  source: string | null;
  tokenHash: string;
  createdByUid: string;
  createdAt: FirebaseFirestore.Timestamp;
  openCount: number;
  startCount: number;
  submissionCount: number;
}

/**
 * Organizer-scoped application review summary with no provider-specific answer shape.
 */
export interface OrganizerApplicationDocument {
  organizerId: string;
  formId: string;
  formVersionId: string;
  targetKind: "organizer" | "event" | "campaign";
  targetId: string | null;
  linkedUid: string | null;
  contactId: string | null;
  applicantDisplayName: string;
  applicantDisplayNameNormalized: string;
  reviewStatus:
    | "submitted"
    | "inReview"
    | "approved"
    | "waitlisted"
    | "declined"
    | "withdrawn";
  latestResponseId: string;
  source: {
    kind: "native" | "tabularImport" | "connector";
    providerId: string | null;
    externalFormId: string | null;
    externalResponseId: string | null;
    importReceiptId: string | null;
  };
  assignedReviewerUid: string | null;
  reviewNote: string | null;
  revision: number;
  submittedAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  reviewedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Immutable answer snapshot for one native, imported, or connector-originated organizer application response.
 */
export interface OrganizerApplicationResponseDocument {
  organizerId: string;
  applicationId: string;
  formId: string;
  formVersionId: string;
  linkedUid: string | null;
  /**
   * @minItems 1
   * @maxItems 100
   */
  answers: {
    questionId: string;
    questionKey: string;
    questionLabel: string;
    questionKind:
      | "shortText"
      | "longText"
      | "singleChoice"
      | "multiChoice"
      | "date"
      | "phone"
      | "email"
      | "url"
      | "number"
      | "boolean"
      | "file";
    canonicalFieldId:
      | (
          | "givenName"
          | "familyName"
          | "displayName"
          | "dateOfBirth"
          | "age"
          | "gender"
          | "phoneNumber"
          | "email"
          | "instagramHandle"
          | "linkedinUrl"
          | "profilePhoto"
          | "city"
          | "heightCm"
          | "occupation"
          | "company"
          | "education"
          | "languages"
          | "relationshipGoal"
          | "interestedInGenders"
          | "drinking"
          | "smoking"
          | "religion"
          | "workout"
          | "diet"
          | "children"
        )
      | null;
    privacyClass: "contact" | "profile" | "sensitive" | "organizerCustom";
    hostPresentation: "detailOnly" | "filterable" | "sortable";
    value: {
      valueKind:
        | "empty"
        | "text"
        | "number"
        | "boolean"
        | "date"
        | "options"
        | "assets";
      textValue: string | null;
      numberValue: number | null;
      booleanValue: boolean | null;
      dateValue: string | null;
      /**
       * @maxItems 100
       */
      optionValues: string[];
      /**
       * @maxItems 10
       */
      assetIds: string[];
    };
  }[];
  source: {
    kind: "native" | "tabularImport" | "connector";
    providerId: string | null;
    externalFormId: string | null;
    externalResponseId: string | null;
    importReceiptId: string | null;
  };
  consentVersion: string | null;
  grantId: string | null;
  submittedAt: FirebaseFirestore.Timestamp;
}

/**
 * Metadata for a private file uploaded with an organizer application; bytes remain in protected Storage.
 */
export interface OrganizerApplicationAssetDocument {
  organizerId: string;
  applicationId: string;
  responseId: string;
  questionId: string;
  uploadedByUid: string | null;
  storagePath: string;
  originalFileName: string;
  contentType: "image/jpeg" | "image/png" | "image/webp" | "application/pdf";
  sizeBytes: number;
  sha256: string;
  status: "pendingScan" | "ready" | "rejected" | "deleted";
  createdAt: FirebaseFirestore.Timestamp;
  deletedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Reusable provider-neutral mapping from external tabular columns to one Catch form version.
 */
export interface OrganizerApplicationSourceMappingDocument {
  organizerId: string;
  formId: string;
  formVersionId: string;
  name: string;
  sourceKind: "csv" | "xlsx" | "connector";
  providerId: string | null;
  externalFormId: string | null;
  headerFingerprint: string;
  /**
   * @minItems 1
   * @maxItems 250
   */
  columns: {
    sourceHeader: string;
    sourceHeaderNormalized: string;
    action: "map" | "ignore";
    questionId: string | null;
    transform:
      | "identity"
      | "trim"
      | "e164"
      | "isoDate"
      | "number"
      | "boolean"
      | "splitOptions"
      | "assetUrl";
  }[];
  createdByUid: string;
  revision: number;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Idempotency and result receipt for one bounded application import commit.
 */
export interface OrganizerApplicationImportReceiptDocument {
  organizerId: string;
  formId: string;
  formVersionId: string;
  mappingId: string | null;
  uploadedByUid: string;
  importKey: string;
  fileName: string;
  format: "csv" | "xlsx" | "connector";
  payloadHash: string;
  status: "completed" | "partial" | "failed";
  rowCount: number;
  createdCount: number;
  skippedCount: number;
  /**
   * @maxItems 100
   */
  errors: {
    rowId: string;
    code: string;
    message: string;
  }[];
  createdAt: FirebaseFirestore.Timestamp;
  completedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Participant-private reusable application values. This is neither a Catch dating profile nor organizer-visible CRM data.
 */
export interface ParticipantIntakeProfileDocument {
  /**
   * @maxItems 40
   */
  fields: {
    canonicalFieldId:
      | "givenName"
      | "familyName"
      | "displayName"
      | "dateOfBirth"
      | "age"
      | "gender"
      | "phoneNumber"
      | "email"
      | "instagramHandle"
      | "linkedinUrl"
      | "profilePhoto"
      | "city"
      | "heightCm"
      | "occupation"
      | "company"
      | "education"
      | "languages"
      | "relationshipGoal"
      | "interestedInGenders"
      | "drinking"
      | "smoking"
      | "religion"
      | "workout"
      | "diet"
      | "children";
    value: {
      valueKind:
        | "empty"
        | "text"
        | "number"
        | "boolean"
        | "date"
        | "options"
        | "assets";
      textValue: string | null;
      numberValue: number | null;
      booleanValue: boolean | null;
      dateValue: string | null;
      /**
       * @maxItems 100
       */
      optionValues: string[];
      /**
       * @maxItems 10
       */
      assetIds: string[];
    };
    sourceApplicationId: string | null;
    reviewedByParticipantAt: FirebaseFirestore.Timestamp;
    updatedAt: FirebaseFirestore.Timestamp;
  }[];
  revision: number;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Append-stable consent receipt granting one organizer access to exact submitted fields for one application. Only revokedAt may transition after creation.
 */
export interface ParticipantOrganizerDataGrantDocument {
  participantUid: string;
  organizerId: string;
  applicationId: string;
  responseId: string;
  formVersionId: string;
  purpose: "organizerApplicationReview";
  /**
   * @minItems 1
   * @maxItems 100
   */
  grantedQuestionIds: string[];
  /**
   * @maxItems 40
   */
  grantedCanonicalFieldIds: (
    | "givenName"
    | "familyName"
    | "displayName"
    | "dateOfBirth"
    | "age"
    | "gender"
    | "phoneNumber"
    | "email"
    | "instagramHandle"
    | "linkedinUrl"
    | "profilePhoto"
    | "city"
    | "heightCm"
    | "occupation"
    | "company"
    | "education"
    | "languages"
    | "relationshipGoal"
    | "interestedInGenders"
    | "drinking"
    | "smoking"
    | "religion"
    | "workout"
    | "diet"
    | "children"
  )[];
  consentVersion: string;
  consentCopyHash: string;
  grantedAt: FirebaseFirestore.Timestamp;
  revokedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Stable mapping and field-level authority between one Catch event and one organizer-authorized booking-provider event.
 */
export interface ExternalEventMappingDocument {
  organizerId: string;
  eventId: string;
  connectionId: string;
  provider: "luma";
  externalEventId: string;
  status: "active" | "paused" | "disconnected";
  fieldAuthority: {
    rosterIdentity: "provider";
    registrationStatus: "provider";
    checkIn: "providerWhenPresent";
    orderAmount: "unavailable";
    refundStatus: "unavailable";
    referralCode: "unavailable";
  };
  revision: number;
  createdByUid: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  lastSyncAt: FirebaseFirestore.Timestamp | null;
  lastSuccessfulSyncAt: FirebaseFirestore.Timestamp | null;
  lastSyncStatus: "never" | "running" | "completed" | "partial" | "failed";
  lastSyncRunId: string | null;
  disconnectedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Idempotent audit and replay receipt for one external-provider event reconciliation.
 */
export interface ProviderSyncRunDocument {
  organizerId: string;
  eventId: string;
  connectionId: string;
  mappingId: string;
  provider: "luma";
  clientOperationId: string;
  inputHash: string;
  status: "running" | "completed" | "partial" | "failed";
  pageCount: number;
  receivedCount: number;
  createdCount: number;
  updatedCount: number;
  skippedCount: number;
  truncated: boolean;
  errorCode: string | null;
  startedByUid: string;
  startedAt: FirebaseFirestore.Timestamp;
  completedAt: FirebaseFirestore.Timestamp | null;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Sanitized provider template metadata used for preview and send eligibility.
 */
export interface OrganizerMessageTemplateDocument {
  organizerId: string;
  connectionId: string;
  providerTemplateId: string;
  name: string;
  language: string;
  category: "MARKETING" | "UTILITY" | "AUTHENTICATION" | "UNKNOWN";
  status:
    | "APPROVED"
    | "PENDING"
    | "REJECTED"
    | "PAUSED"
    | "DISABLED"
    | "DELETED"
    | "UNKNOWN";
  /**
   * @maxItems 20
   */
  variableNames: string[];
  /**
   * @maxItems 20
   */
  parameterBindings: {
    variableName: string;
    component: "header" | "body" | "button";
    position: number;
    buttonIndex: number | null;
  }[];
  hasMediaHeader: boolean;
  /**
   * @maxItems 10
   */
  buttonKinds: (
    | "URL"
    | "PHONE_NUMBER"
    | "QUICK_REPLY"
    | "COPY_CODE"
    | "UNKNOWN"
  )[];
  providerUpdatedAt: FirebaseFirestore.Timestamp | null;
  syncedAt: FirebaseFirestore.Timestamp;
}

/**
 * Organizer-contact channel frequency and suppression state rechecked immediately before delivery.
 */
export interface OrganizerContactChannelStateDocument {
  organizerId: string;
  contactId: string;
  channel: "whatsapp";
  endpointHash: string;
  suppressionStatus:
    | "none"
    | "optedOut"
    | "providerBlocked"
    | "invalidEndpoint"
    | "adminSuppressed";
  suppressionSource: null | "preference" | "inboundStop" | "provider" | "admin";
  /**
   * Independent organizer pause. It never replaces a person opt-out or provider suppression.
   */
  adminSuppressed?: boolean;
  campaignAcceptedCount: number;
  lastCampaignAcceptedAt: FirebaseFirestore.Timestamp | null;
  lastInboundAt: FirebaseFirestore.Timestamp | null;
  lastReplyAt: FirebaseFirestore.Timestamp | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * One organizer-owned cross-event campaign with frozen approval and aggregate delivery state.
 */
export interface OrganizerCampaignDocument {
  organizerId: string;
  createdByUid: string;
  messageClass: "eventFollowUp" | "organizerUpdate" | "organizerPromotion";
  channel: "whatsapp";
  status:
    | "draft"
    | "previewed"
    | "approved"
    | "scheduled"
    | "resolving"
    | "sending"
    | "completed"
    | "partiallyFailed"
    | "cancelled"
    | "blocked";
  name: string;
  /**
   * @minItems 1
   * @maxItems 5
   */
  segmentIds: (
    | "first_time_attendee"
    | "repeat_attendee"
    | "regular"
    | "lapsed_regular"
    | "reliable_attendee"
    | "advocate"
    | "high_impact_advocate"
    | "whatsapp_reachable"
  )[];
  connectionId: string;
  templateId: string;
  templateVariables: {
    [k: string]: string;
  };
  eventId: string | null;
  inviteDestinationKind:
    | null
    | "catchEvent"
    | "eventRuntime"
    | "externalBooking"
    | "marketingLanding";
  scheduledAt: FirebaseFirestore.Timestamp | null;
  recipientSnapshotHash: string | null;
  contentHash: string;
  audienceCounts: {
    total: number;
    reachable: number;
    optedOut: number;
    invalid: number;
    duplicate: number;
    unsupported: number;
    frequencyCapped: number;
    providerBlocked: number;
    unknown: number;
  };
  deliveryCounts: {
    pending: number;
    suppressed: number;
    accepted: number;
    sent: number;
    delivered: number;
    read: number;
    failed: number;
    replied: number;
    optedOut: number;
  };
  revision: number;
  leaseOwner: string | null;
  leaseExpiresAt: FirebaseFirestore.Timestamp | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  approvedAt: FirebaseFirestore.Timestamp | null;
  dispatchedAt: FirebaseFirestore.Timestamp | null;
  completedAt: FirebaseFirestore.Timestamp | null;
  cancelledAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Server-owned organizer-scoped index of one completed event announcement, including bounded contact delivery state for CRM history.
 */
export interface OrganizerBroadcastSummaryDocument {
  organizerId: string;
  broadcastId: string;
  eventId: string;
  eventName: string;
  audience: "booked" | "prospective" | "everyone";
  recipientCount: number;
  sentAt: FirebaseFirestore.Timestamp;
  partialFailure: boolean;
  /**
   * @maxItems 500
   */
  recipientContactIds: string[];
  recipientDeliveryStates: {
    [k: string]: "available" | "failed";
  };
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Frozen recipient eligibility and monotonic delivery receipt for one organizer campaign contact.
 */
export interface OrganizerCampaignRecipientDocument {
  organizerId: string;
  campaignId: string;
  contactId: string;
  channel: "whatsapp";
  eligibility: "eligible" | "excluded";
  exclusionReason:
    | null
    | "optedOut"
    | "noVerifiedEndpoint"
    | "duplicateEndpoint"
    | "frequencyCapped"
    | "providerBlocked"
    | "invalidEndpoint"
    | "unknownPermission"
    | "identityUnresolved"
    | "deleted";
  endpointE164: string | null;
  endpointHash: string | null;
  permissionTermsVersion: string | null;
  permissionUpdatedAt: FirebaseFirestore.Timestamp | null;
  renderedVariablesHash: string;
  inviteLinkId: string | null;
  status:
    | "pending"
    | "sending"
    | "suppressed"
    | "accepted"
    | "sent"
    | "delivered"
    | "read"
    | "failed"
    | "replied"
    | "optedOut";
  providerMessageId: string | null;
  providerErrorCategory:
    | null
    | "authentication"
    | "template"
    | "quality"
    | "rateLimit"
    | "invalidRecipient"
    | "policy"
    | "provider"
    | "unknown";
  retryEligible: boolean;
  attemptCount: number;
  leaseOwner: string | null;
  leaseExpiresAt: FirebaseFirestore.Timestamp | null;
  acceptedAt: FirebaseFirestore.Timestamp | null;
  sentAt: FirebaseFirestore.Timestamp | null;
  deliveredAt: FirebaseFirestore.Timestamp | null;
  readAt: FirebaseFirestore.Timestamp | null;
  failedAt: FirebaseFirestore.Timestamp | null;
  repliedAt: FirebaseFirestore.Timestamp | null;
  optedOutAt: FirebaseFirestore.Timestamp | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * TTL idempotency receipt for one authenticated provider webhook event.
 */
export interface OrganizerCampaignWebhookReceiptDocument {
  provider: "metaCloudApi";
  providerEventId: string;
  organizerId: string | null;
  connectionId: string | null;
  eventKind:
    | "status"
    | "inbound"
    | "template"
    | "quality"
    | "account"
    | "unmatched";
  payloadHash: string;
  createdAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Sanitized durable provider event queued after signature verification. Inbound text is retained here for at most 30 days and copied into the organizer thread store for at most 12 months.
 */
export interface OrganizerMessagingWebhookEventDocument {
  provider: "metaCloudApi";
  providerEventId: string;
  organizerId: string | null;
  connectionId: string | null;
  eventKind:
    | "status"
    | "inbound"
    | "template"
    | "quality"
    | "account"
    | "unmatched";
  providerMessageId: string | null;
  contextProviderMessageId: string | null;
  deliveryStatus: null | "sent" | "delivered" | "read" | "failed";
  endpointHash: string | null;
  isStop: boolean;
  hasReply: boolean;
  inboundBody: string | null;
  providerErrorCode: number | null;
  providerOccurredAt: FirebaseFirestore.Timestamp | null;
  processingStatus: "pending" | "processed" | "unmatched" | "failed";
  attemptCount: number;
  createdAt: FirebaseFirestore.Timestamp;
  processedAt: FirebaseFirestore.Timestamp | null;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-only organizer/contact WhatsApp thread summary with a 12-month rolling retention boundary.
 */
export interface OrganizerWhatsappThreadDocument {
  schemaVersion: 1;
  threadId: string;
  organizerId: string;
  contactId: string;
  connectionId: string;
  endpointHash: string;
  /**
   * @maxItems 50
   */
  eventIds: string[];
  lastMessageBody: string;
  lastMessageDirection: "inbound" | "outbound";
  lastMessageAt: FirebaseFirestore.Timestamp;
  lastInboundAt: FirebaseFirestore.Timestamp;
  serviceWindowExpiresAt: FirebaseFirestore.Timestamp;
  messageCount: number;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-only inbound or outbound WhatsApp body retained for 12 months.
 */
export interface OrganizerWhatsappMessageDocument {
  schemaVersion: 1;
  messageId: string;
  threadId: string;
  organizerId: string;
  contactId: string;
  connectionId: string;
  direction: "inbound" | "outbound";
  body: string;
  providerMessageId: string;
  actorUid: string | null;
  occurredAt: FirebaseFirestore.Timestamp;
  createdAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-only at-most-once reservation for one organizer WhatsApp reply attempt.
 */
export interface OrganizerWhatsappReplyOperationDocument {
  schemaVersion: 1;
  operationId: string;
  organizerId: string;
  threadId: string;
  contactId: string;
  messageId: string;
  bodyHash: string;
  expectedLastInboundAtMillis: number;
  actorUid: string;
  state: "pending" | "completed" | "unknown";
  providerMessageId: string | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-owned organizer listing claim request stored at organizerClaimRequests/{requestId}.
 */
export interface OrganizerClaimRequestDocument {
  requestId: string;
  organizerId: string;
  requesterUid: string;
  requesterName: string;
  requesterRole:
    | "owner"
    | "founder"
    | "manager"
    | "marketer"
    | "venueManager"
    | "other";
  businessEmail: string | null;
  businessPhone: string | null;
  /**
   * @maxItems 8
   */
  proofUrls: string[];
  message: string | null;
  status: "pending" | "approved" | "rejected" | "withdrawn" | "superseded";
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  decidedAt: FirebaseFirestore.Timestamp | null;
  decidedByUid: string | null;
  decisionReason: string | null;
  previousRequestId: string | null;
}

/**
 * Server-owned time-slot claim stored at organizerScheduleLocks/{organizerId_slot}.
 */
export interface OrganizerScheduleLockDocument {
  ownerType: "organizer";
  ownerId: string;
  slot: number;
  eventId: string;
  organizerId: string;
  startTimeMillis: number;
  endTimeMillis: number;
}

/**
 * Legacy organizer-post projection stored at clubs/{clubId}/posts/{postId} during the clubs-to-organizers migration.
 */
export interface ClubPostDocument {
  authorUid: string;
  text: string;
  photoPath?: string | null;
  eventId?: string | null;
  audience: "followers";
  createdAt: FirebaseFirestore.Timestamp;
  status: "active" | "removed";
}

/**
 * Canonical club membership edge stored at clubMemberships/{membershipId}.
 */
export interface ClubMembershipDocument {
  clubId: string;
  uid: string;
  role: "owner" | "host" | "member";
  status: "active" | "left" | "deleted";
  pushNotificationsEnabled: boolean;
  joinedAt: FirebaseFirestore.Timestamp;
  leftAt: FirebaseFirestore.Timestamp | null;
  deletedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Server-owned singleton claim stored at clubHostClaims/{uid} to enforce one hosted club per user.
 */
export interface ClubHostClaimDocument {
  uid: string;
  clubId: string;
  createdAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-owned organizer listing claim request stored at clubClaimRequests/{requestId}.
 */
export interface ClubClaimRequestDocument {
  requestId: string;
  clubId: string;
  requesterUid: string;
  requesterName: string;
  requesterRole:
    | "owner"
    | "founder"
    | "manager"
    | "marketer"
    | "venueManager"
    | "other";
  businessEmail: string | null;
  businessPhone: string | null;
  /**
   * @maxItems 8
   */
  proofUrls: string[];
  message: string | null;
  status: "pending" | "approved" | "rejected" | "withdrawn" | "superseded";
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  decidedAt: FirebaseFirestore.Timestamp | null;
  decidedByUid: string | null;
  decisionReason: string | null;
  previousRequestId: string | null;
}

/**
 * Canonical event document stored at events/{eventId}. The event id is the document id and is not stored in document data.
 */
export interface EventDocument {
  clubId: string;
  organizerId?: string;
  eventOrigin?: EventOrigin;
  runtimeAccess?: EventRuntimeAccess;
  startTime: FirebaseFirestore.Timestamp;
  endTime: FirebaseFirestore.Timestamp;
  meetingPoint: string;
  meetingLocation: EventMeetingLocation;
  startingPointLat: number;
  startingPointLng: number;
  locationDetails?: string | null;
  photoUrl?: string | null;
  eventPhotos?: UploadedPhoto[];
  distanceKm: number;
  eventFormat: EventFormatSnapshot;
  pace: "easy" | "moderate" | "fast" | "competitive";
  capacityLimit: number;
  description: string;
  priceInPaise: number;
  currency?: string;
  bookedCount?: number;
  checkedInCount?: number;
  waitlistedCount?: number;
  status: "active" | "cancelled";
  cancelledAt?: FirebaseFirestore.Timestamp | null;
  cancellationReason?: string | null;
  /**
   * When true, the published marketing event route may register a phone-OTP identity into eventAttendees without creating a Consumer profile.
   */
  publicRegistrationEnabled?: boolean;
  constraints: EventConstraints;
  eventPolicy?: EventPolicyBundleDocument | null;
  genderCounts: {
    [k: string]: number;
  };
  cohortCounts: {
    [k: string]: number;
  };
  waitlistedCohortCounts: {
    [k: string]: number;
  };
  crossPathsPairHeldCount?: number;
  crossPathsPairConfirmedCount?: number;
  crossPathsPairHeldCohortCounts?: {
    [k: string]: number;
  };
  crossPathsDiscoveryEnabled?: boolean;
  discoveryMarketId: string;
  discoveryCityName: string;
  discoveryActivityKind:
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
  discoveryGeoCell: string;
  discoveryHasOpenSpots: boolean;
  discoveryAvailability: "open" | "waitlist" | "gated" | "full" | "cancelled";
  /**
   * @maxItems 4
   */
  discoveryOpenCohorts: (
    | "menInterestedInWomen"
    | "womenInterestedInMen"
    | "queerOrOpen"
    | "nonBinaryOrOther"
  )[];
  /**
   * @maxItems 4
   */
  discoveryWaitlistCohorts: (
    | "menInterestedInWomen"
    | "womenInterestedInMen"
    | "queerOrOpen"
    | "nonBinaryOrOther"
  )[];
  discoveryInviteRequired: boolean;
  discoveryMembershipRequired: boolean;
  discoveryManualApprovalRequired: boolean;
  discoveryMinAge: number;
  discoveryMaxAge: number;
  /**
   * Server-owned deterministic search projection used by admin event publishing. Rebuildable from canonical event and organizer fields; not consumed by the app.
   */
  adminSearch?: {
    /**
     * @maxItems 120
     */
    tokens: string[];
    sortKey: string;
    updatedAt: FirebaseFirestore.Timestamp;
    updatedBySource: "adminUpdateEventDetails" | "adminEventSearchBackfill";
  };
}

/**
 * Read-only external event document stored at externalEvents/{eventId}. These records are sourced from reviewed organizer intake candidates and may link to external booking platforms, but they never enable Catch booking, payments, reservations, waitlists, attendance, or schedule locks.
 */
export interface ExternalEventDocument {
  schemaVersion: 1;
  eventId: string;
  canonicalHostId: string;
  compatibilityClubId: string;
  title: string;
  description: string;
  startTime: FirebaseFirestore.Timestamp;
  endTime: FirebaseFirestore.Timestamp | null;
  timezone: string | null;
  meetingPoint: string;
  meetingLocation: {
    name: string;
    address: string | null;
    placeId: string | null;
    latitude: number | null;
    longitude: number | null;
    notes: string | null;
  };
  locationDetails: string | null;
  photoUrl: string | null;
  activity: {
    version: 1;
    activityKind:
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
    interactionModel:
      | "pacePods"
      | "pairedRotations"
      | "teamRotations"
      | "seatedTable"
      | "freeFormMixer"
      | "hostLedProgram"
      | "openFormat";
    source: "heuristic" | "admin" | "source";
  };
  price: {
    displayText: string | null;
    parsedPriceInPaise: number | null;
    currency: string;
  };
  status: "active" | "cancelled";
  publicationStatus: "draft" | "public" | "archived" | "removed";
  organizerCapabilities: OrganizerSupplyCapabilities;
  booking: {
    mode: "external_outbound_only";
    catchBookingEnabled: false;
    catchPaymentsEnabled: false;
    catchReservationsEnabled: false;
    catchWaitlistEnabled: false;
    /**
     * @minItems 1
     * @maxItems 12
     */
    externalLinks: {
      platform: "bookMyShow" | "district" | "luma" | "partiful" | "sortMyScene";
      url: string;
      linkType: "booking_or_event_page" | "source_surface";
      sourceEventKey: string;
      candidateId: string;
      primary: boolean;
    }[];
  };
  discovery: {
    citySlug: (string | null) | null;
    countryCode: string | null;
    availability: "read_only_external";
    manualApprovalRequired: true;
  };
  dedupe: {
    normalizedEventKey: string;
    primaryCandidateId: string;
    /**
     * @maxItems 24
     */
    duplicateCandidateIds: string[];
    conflictPolicy: "single_read_only_event_with_multiple_outbound_links";
  };
  externalSource: {
    candidateId: string;
    sourceEventKey: string;
    sourceEventId: string;
    platform: "bookMyShow" | "district" | "luma" | "partiful" | "sortMyScene";
    eventUrl: string | null;
    sourceUrl: string | null;
  };
  review: {
    eventReviewBatchId: string | null;
    reviewer: string | null;
    decidedAt: string | null;
    note: string | null;
    importPolicyAcknowledged: boolean;
    ownerSafeCopyReviewed: boolean;
    /**
     * @maxItems 6
     */
    blockerResolutions: ExternalEventBlockerResolution[];
  };
  takedown?: {
    removedAt: FirebaseFirestore.Timestamp;
    removedByUid: string;
    reason: string;
    receiptId: string;
  } | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Host-private access material for invite-only events stored at eventPrivateAccess/{eventId}.
 */
export interface EventPrivateAccessDocument {
  eventId: string;
  clubId: string;
  organizerId?: string;
  inviteCode: string;
  createdAt: FirebaseFirestore.Timestamp;
}

/**
 * Opaque event invitation metadata stored at eventInviteLinks/{inviteLinkId}. The public bearer token is stored separately in a server-only secret document.
 */
export interface EventInviteLinkDocument {
  eventId: string;
  clubId: string;
  organizerId?: string;
  hostUid: string;
  label: string;
  source: string | null;
  tokenHash: string;
  contractVersion?: number;
  linkKind?:
    | "hostChannel"
    | "directRecipient"
    | "attendeeReferrer"
    | "promoter"
    | "partner";
  ownerContactId?: string | null;
  ownerUid?: string | null;
  intendedRecipientContactId?: string | null;
  campaignId?: string | null;
  issuanceChannel?:
    | "hostApp"
    | "consumerApp"
    | "runtimeWeb"
    | "campaign"
    | "api";
  destinationKind?:
    | "catchEvent"
    | "eventRuntime"
    | "externalBooking"
    | "marketingLanding";
  tokenVersion?: number;
  attributionWindowEndsAt?: FirebaseFirestore.Timestamp | null;
  openCount: number;
  likelyHumanOpenCount?: number;
  shareIntentCount?: number;
  verifiedRegistrationCount?: number;
  referredRegistrationCount?: number;
  referredCheckedInCount?: number;
  requestCount: number;
  confirmedCount: number;
  paidCount: number;
  checkedInCount: number;
  catcherCount: number;
  matchCount: number;
  chatStartedCount: number;
  disabledAt: FirebaseFirestore.Timestamp | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-only bearer token material for one event invitation link.
 */
export interface EventInviteLinkSecretDocument {
  eventId: string;
  organizerId: string;
  token: string;
  tokenHash: string;
  tokenVersion: number;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Short-lived privacy-minimized evidence that an invitation URL was resolved.
 */
export interface EventInviteTouchDocument {
  eventId: string;
  organizerId: string;
  inviteLinkId: string;
  touchKind: "open" | "redirect";
  surface:
    | "consumerApp"
    | "hostApp"
    | "runtimeWeb"
    | "marketingWeb"
    | "unknown";
  actorUid: string | null;
  sessionHash: string | null;
  likelyHuman: boolean;
  botReason: "previewCrawler" | "knownBot" | "missingClientSignal" | null;
  attributionEligible: boolean;
  createdAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Evidence that a signed-in actor opened a Catch-owned share surface; it is not proof that a message was sent.
 */
export interface EventShareIntentDocument {
  eventId: string;
  organizerId: string;
  inviteLinkId: string;
  actorUid: string;
  actorKind: "host" | "attendee" | "member";
  surface: "hostApp" | "consumerApp" | "runtimeWeb";
  creativeId: string | null;
  channelHint: "systemShare" | "copyLink" | "whatsapp" | "sms" | "email" | null;
  createdAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Immutable evidence assigning or reversing one downstream event fact to one invitation link.
 */
export interface EventInviteAttributionDocument {
  eventId: string;
  organizerId: string;
  inviteLinkId: string;
  linkKind:
    | "hostChannel"
    | "directRecipient"
    | "attendeeReferrer"
    | "promoter"
    | "partner";
  ownerContactId: string | null;
  intendedRecipientContactId: string | null;
  subjectContactId: string | null;
  subjectUid: string | null;
  factKind: "registration" | "booking" | "checkIn" | "revenue" | "refund";
  operation: "credit" | "reversal";
  sourceKind:
    | "catchParticipation"
    | "eventAttendee"
    | "provider"
    | "selfReport";
  sourceFactId: string;
  primaryCredit: boolean;
  confidence: "exact" | "reconciled" | "selfReported";
  referralCredit: boolean;
  amountMinor?: number | null;
  currency?: string | null;
  reversalOfAttributionId: string | null;
  occurredAt: FirebaseFirestore.Timestamp;
  createdAt: FirebaseFirestore.Timestamp;
}

/**
 * Canonical event roster edge stored at eventParticipations/{participationId}.
 */
export interface EventParticipationDocument {
  eventId: string;
  clubId: string;
  organizerId?: string;
  uid: string;
  status: "signedUp" | "waitlisted" | "attended" | "cancelled" | "deleted";
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  signedUpAt: FirebaseFirestore.Timestamp | null;
  waitlistedAt: FirebaseFirestore.Timestamp | null;
  attendedAt: FirebaseFirestore.Timestamp | null;
  cancelledAt: FirebaseFirestore.Timestamp | null;
  deletedAt: FirebaseFirestore.Timestamp | null;
  genderAtSignup: ("man" | "woman" | "nonBinary" | "other") | null;
  cohortAtSignup?: string | null;
  paymentId: string | null;
  /**
   * Manual-approval request state for request-to-join events. Null for regular waitlist edges.
   */
  hostApprovalStatus?: "pending" | "approved" | "declined" | null;
  hostApprovalDecidedAt?: FirebaseFirestore.Timestamp | null;
  hostApprovalDecidedBy?: string | null;
  /**
   * Mirror of the current waitlist offer state for cheap roster and attendee CTA reads.
   */
  waitlistOfferStatus?:
    | ("active" | "accepted" | "declined" | "expired" | "cancelled")
    | null;
  waitlistOfferedAt?: FirebaseFirestore.Timestamp | null;
  waitlistOfferExpiresAt?: FirebaseFirestore.Timestamp | null;
  waitlistOfferAcceptedAt?: FirebaseFirestore.Timestamp | null;
  waitlistOfferId?: string | null;
  /**
   * Named host invite link that first attributed this participation, when present.
   */
  inviteLinkId?: string | null;
  /**
   * Host-facing source label copied from the invite link for durable reporting.
   */
  inviteSource?: string | null;
  /**
   * Server time when invite attribution was first attached to the roster edge.
   */
  inviteCapturedAt?: FirebaseFirestore.Timestamp | null;
}

/**
 * Private event-scoped operational attendee stored at eventAttendees/{attendeeId}.
 */
export interface EventAttendeeDocument {
  eventId: string;
  clubId: string;
  organizerId: string;
  displayName: string;
  searchName: string;
  source:
    | "catchBooking"
    | "hostImport"
    | "hostManual"
    | "webOtp"
    | "providerSync";
  status: "invited" | "registered" | "waitlisted" | "checkedIn" | "cancelled";
  linkedUid: string | null;
  phoneE164: string | null;
  email: string | null;
  externalReference: string | null;
  /**
   * Provider or import-supplied booking/arrival group shared by guests who are expected to arrive together.
   */
  arrivalGroup: string | null;
  ticketType: string | null;
  importId: string | null;
  sourceRowId: string | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  registeredAt: FirebaseFirestore.Timestamp | null;
  waitlistedAt: FirebaseFirestore.Timestamp | null;
  checkedInAt: FirebaseFirestore.Timestamp | null;
  cancelledAt: FirebaseFirestore.Timestamp | null;
  checkedInBy: string | null;
  linkedAt: FirebaseFirestore.Timestamp | null;
  /**
   * First eligible opaque invitation link preserved on this operational attendee.
   */
  inviteLinkId?: string | null;
  inviteCapturedAt?: FirebaseFirestore.Timestamp | null;
  /**
   * Monotonic revision for absolute Host attendance operations. Missing legacy values read as zero.
   */
  attendanceRevision?: number;
  /**
   * Operational status restored by an absolute undo. Null outside checked-in state.
   */
  preCheckInStatus?: "invited" | "registered" | "waitlisted" | null;
  /**
   * Host-recorded sweep result. It is current only when accountabilityResolvedForCheckInAt equals checkedInAt.
   */
  accountabilityResolution?: "returned" | "departed" | null;
  accountabilityResolvedForCheckInAt?: FirebaseFirestore.Timestamp | null;
  accountabilityResolvedAt?: FirebaseFirestore.Timestamp | null;
  accountabilityResolvedBy?: string | null;
  /**
   * External source that most recently supplied provider-authoritative fields, independent of row creation source.
   */
  provider?:
    | "luma"
    | "eventbrite"
    | "partiful"
    | "posh"
    | "bookmyshow"
    | "district"
    | "sortmyscene"
    | "airbnb"
    | null;
  providerConnectionId?: string | null;
  providerGuestId?: string | null;
  providerSyncedAt?: FirebaseFirestore.Timestamp | null;
  providerDataRevision?: number;
}

/**
 * Server-owned, expiring least-privilege access to one event's operational roster. It never grants organizer, CRM, provider, campaign, analytics, or event-edit authority.
 */
export interface EventStaffGrantDocument {
  organizerId: string;
  eventId: string;
  uid: string;
  displayName: string;
  phoneLastFour: string;
  role: "checkInOperator";
  /**
   * @minItems 3
   * @maxItems 3
   */
  permissions: ("viewRoster" | "setAttendance" | "reviewRuntimeClaims")[];
  status: "active" | "revoked";
  createdBy: string;
  createdAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
  revokedBy: string | null;
  revokedAt: FirebaseFirestore.Timestamp | null;
  updatedAt: FirebaseFirestore.Timestamp;
  revision: number;
}

/**
 * Short-lived server-only idempotency receipt for one absolute Host attendance operation.
 */
export interface EventAttendeeAttendanceReceiptDocument {
  eventId: string;
  organizerId: string;
  attendeeId: string;
  actorUid: string;
  clientOperationId: string;
  desiredCheckedIn: boolean;
  priorRevision: number;
  acceptedRevision: number;
  changed: boolean;
  createdAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Idempotency and audit receipt for one Host operational-roster import.
 */
export interface EventAttendeeImportDocument {
  eventId: string;
  clubId: string;
  organizerId: string;
  uploadedBy: string;
  importKey: string;
  fileName: string;
  format: "csv" | "xlsx" | "manual";
  payloadHash: string;
  status: "completed" | "partial" | "failed";
  rowCount: number;
  createdCount: number;
  updatedCount: number;
  skippedCount: number;
  /**
   * @maxItems 100
   */
  errors: {
    rowId: string;
    code: string;
    message: string;
  }[];
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  completedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Server-only, expiring capability that routes a verified forwarded roster to one event and Host identity.
 */
export interface EventRosterHandoffDocument {
  eventId: string;
  clubId: string;
  organizerId: string;
  hostUid: string;
  tokenHash: string;
  provider:
    | "generic"
    | "luma"
    | "eventbrite"
    | "partiful"
    | "posh"
    | "bookmyshow"
    | "district"
    | "sortmyscene"
    | "airbnb";
  status: "active" | "expired" | "revoked";
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Participant-private runtime identity stored at eventRuntimeParticipants/{eventId_uid}.
 */
export interface EventRuntimeParticipantDocument {
  eventId: string;
  clubId: string;
  organizerId: string;
  uid: string;
  eventAttendeeId: string | null;
  identityVersion: 1;
  claimMethod:
    | "verifiedPhone"
    | "signedAttendeeToken"
    | "verifiedEmail"
    | "hostApproval"
    | "catchParticipation";
  accessStatus:
    | "pendingApproval"
    | "needsInput"
    | "ready"
    | "optedOut"
    | "revoked";
  /**
   * @maxItems 10
   */
  requiredFieldIds: (
    | "displayName"
    | "gender"
    | "interestedInGenders"
    | "relationshipGoal"
    | "dateOfBirth"
    | "paceBand"
    | "skillBand"
    | "dietaryAndSeatingNotes"
    | "questionnaireAnswerIds"
    | "teamName"
  )[];
  /**
   * @maxItems 10
   */
  completedFieldIds: (
    | "displayName"
    | "gender"
    | "interestedInGenders"
    | "relationshipGoal"
    | "dateOfBirth"
    | "paceBand"
    | "skillBand"
    | "dietaryAndSeatingNotes"
    | "questionnaireAnswerIds"
    | "teamName"
  )[];
  runtimeProfile: {
    displayName: string;
    gender: ("man" | "woman" | "nonBinary" | "other") | null;
    /**
     * @maxItems 4
     */
    interestedInGenders: ("man" | "woman" | "nonBinary" | "other")[];
    relationshipGoal:
      | "relationship"
      | "casual"
      | "marriage"
      | "friendship"
      | "unsure"
      | null;
    dateOfBirth: FirebaseFirestore.Timestamp | null;
    paceBand: "competitive" | "fast" | "moderate" | "easy" | null;
    skillBand: "beginner" | "intermediate" | "advanced" | null;
    dietaryAndSeatingNotes: string | null;
    /**
     * @maxItems 8
     */
    questionnaireAnswerIds: string[];
    teamName: string | null;
  };
  consents: {
    runtimeTermsVersion: string;
    sensitiveDataTermsVersion: string | null;
    saveAsCatchPrefill: boolean;
  };
  claimedAt: FirebaseFirestore.Timestamp;
  readyAt: FirebaseFirestore.Timestamp | null;
  revokedAt: FirebaseFirestore.Timestamp | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Short-lived server-owned venue-presence authority shown only in the Host live QR.
 */
export interface EventVenueSessionDocument {
  eventId: string;
  organizerId: string;
  createdBy: string;
  issuedAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-only single-use receipt binding one attendee to one live venue session.
 */
export interface EventVenueSessionRedemptionDocument {
  eventId: string;
  sessionId: string;
  uid: string;
  purpose: "attendance" | "firstHello";
  redeemedAt: FirebaseFirestore.Timestamp;
  consumedAt: FirebaseFirestore.Timestamp | null;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-owned liveness heartbeat stored at eventSuccessPresence/{eventId_uid}; presence state is derived from heartbeatAt and deployment policy rather than persisted.
 */
export interface EventSuccessPresenceDocument {
  eventId: string;
  clubId: string;
  organizerId: string;
  uid: string;
  surface: "flutter" | "web";
  heartbeatAt: FirebaseFirestore.Timestamp;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-owned Host resolution for a checked-in late attendee stored at eventSuccessLateArrivals/{eventId_uid}.
 */
export interface EventSuccessLateArrivalDocument {
  eventId: string;
  clubId: string;
  organizerId: string;
  uid: string;
  resolvedByUid: string;
  status: "insertedIntoOpenPair" | "extendedUnit" | "heldForNextRound";
  targetRoundIndex: number;
  assignmentDraftRevision: number;
  reason: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-owned isolated Host rehearsal session stored at eventRehearsals/{sessionId}.
 */
export interface EventRehearsalDocument {
  organizerId: string;
  clubId: string;
  ownerUid: string;
  sourceEventId: string | null;
  sourceEventRevision: string | null;
  publicRehearsalId: string;
  viewerTokenHash: string;
  scenarioId:
    | "smoothRun"
    | "lateAndNoShow"
    | "earlyExitAndReturn"
    | "rosterAndCapacity"
    | "walkInAndAmbiguousClaim"
    | "privacyAndKeepApart"
    | "lowConnectivity"
    | "concurrentHosts"
    | "revealInterrupted"
    | "externalProfiles"
    | "accountabilitySweep";
  seed: number;
  actorCount: number;
  actionCount: number;
  status: "draft" | "ready" | "running" | "paused" | "complete" | "expired";
  setup: {
    title: string;
    locationName: string;
    durationMinutes: number;
    hostGoal: string;
    attendeePrompt: string;
    /**
     * @minItems 1
     * @maxItems 8
     */
    moduleIds: (
      | "arrival"
      | "firstHello"
      | "pods"
      | "rotations"
      | "conversationCues"
      | "reveal"
      | "afterglow"
      | "accountability"
    )[];
  };
  setupRevision: number;
  runtimeRevision: number;
  activeStepIndex: number;
  virtualStartedAt: FirebaseFirestore.Timestamp;
  virtualNow: FirebaseFirestore.Timestamp;
  faultId:
    | "none"
    | "latency"
    | "oneShotFailure"
    | "listenerDisconnect"
    | "staleRevision"
    | "duplicateDelivery"
    | "legacyFixture"
    | "reducedMotion"
    | "lowBandwidth";
  faultConsumed: boolean;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
  completedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Synthetic participant state stored only for an isolated rehearsal.
 */
export interface EventRehearsalActorDocument {
  sessionId: string;
  actorId: string;
  displayName: string;
  persona:
    | "firstTimer"
    | "regular"
    | "quiet"
    | "connector"
    | "external"
    | "sparseProfile"
    | "accessibilityNeeds"
    | "walkIn";
  status:
    | "expected"
    | "present"
    | "late"
    | "noShow"
    | "departed"
    | "returned"
    | "disconnected"
    | "walkIn"
    | "ambiguousClaim";
  guestMoment:
    | "welcome"
    | "checkIn"
    | "firstHello"
    | "assignment"
    | "rotation"
    | "pause"
    | "reveal"
    | "afterglow"
    | "complete";
  optedOut: boolean;
  /**
   * @maxItems 10
   */
  keepApartActorIds: string[];
  helpRequested: boolean;
  promptCompleted: boolean;
  lastActionAt: FirebaseFirestore.Timestamp | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Bounded idempotency and reproduction record for rehearsal actions.
 */
export interface EventRehearsalActionDocument {
  sessionId: string;
  clientActionId: string;
  actorUid: string | null;
  actorId: string | null;
  kind: "control" | "behavior" | "guest" | "setup" | "system";
  name: string;
  runtimeRevision: number;
  virtualNow: FirebaseFirestore.Timestamp;
  createdAt: FirebaseFirestore.Timestamp;
}

/**
 * Ephemeral anonymous guest slot for a rehearsal web link.
 */
export interface EventRehearsalGuestViewDocument {
  sessionId: string;
  slotId: string;
  actorId: string;
  tokenHash: string;
  createdAt: FirebaseFirestore.Timestamp;
  lastSeenAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Host-reviewable pending runtime identity claim stored at eventRuntimeClaimRequests/{eventId_uid}.
 */
export interface EventRuntimeClaimRequestDocument {
  eventId: string;
  clubId: string;
  organizerId: string;
  uid: string;
  displayName: string;
  phoneLastFour: string;
  /**
   * @maxItems 20
   */
  candidateAttendeeIds: string[];
  status: "pending" | "approved" | "rejected" | "cancelled";
  reviewedBy: string | null;
  reviewReason: string | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  reviewedAt: FirebaseFirestore.Timestamp | null;
}

/**
 * Private per-user Cross Paths consent edge stored at eventCrossPathsConsents/{eventId_uid} and written only by setCrossPathsEventConsent.
 */
export interface EventCrossPathsConsentDocument {
  eventId: string;
  uid: string;
  enabled: boolean;
  termsVersion: number;
  consentedAt: FirebaseFirestore.Timestamp | null;
  updatedAt: FirebaseFirestore.Timestamp;
  revokedAt: FirebaseFirestore.Timestamp | null;
  source: "booking_success" | "event_detail" | "settings";
}

/**
 * Server-only reviewed eligibility record for showing one member in Cross Paths. It stores coarse readiness reasons and a profile fingerprint, never an attractiveness score.
 */
export interface CrossPathsShowcaseEligibilityDocument {
  status: "eligible" | "needsReview" | "paused";
  /**
   * @maxItems 12
   */
  reasonCodes: (
    | "insufficient_photos"
    | "incomplete_prompts"
    | "missing_relationship_goal"
    | "broken_media"
    | "photo_moderation_pending"
    | "photo_moderation_rejected"
    | "public_profile_missing"
    | "profile_changed"
    | "reviewer_hold"
    | "manual_pause"
  )[];
  ruleVersion: number;
  reviewVersion: number;
  profileFingerprint: string;
  reviewChecklist: {
    primaryPortraitClear: boolean;
    profileRepresentsCurrentMember: boolean;
    showcasePolicyReviewed: boolean;
  };
  reviewNote: string;
  reviewedByUid: string;
  reviewedAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-only, session-idempotent Cross Paths exposure receipt used for ranking fatigue. It contains no private preference values or roster projection.
 */
export interface CrossPathsSuggestionExposureDocument {
  viewerUid: string;
  candidateUid: string;
  eventId: string;
  sessionIdHash: string;
  rankingVersion: number;
  shownAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Callable-owned event-scoped invitation stored at crossPathsInvitations/{deterministicEventSenderHash}.
 */
export interface CrossPathsInvitationDocument {
  eventId: string;
  senderUid: string;
  recipientUid: string;
  /**
   * @minItems 2
   * @maxItems 2
   */
  participantIds: string[];
  status:
    | "pending"
    | "accepted"
    | "declined"
    | "cancelled"
    | "expired"
    | "invalidated";
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
  respondedAt: FirebaseFirestore.Timestamp | null;
  cancelledAt: FirebaseFirestore.Timestamp | null;
  invalidatedAt: FirebaseFirestore.Timestamp | null;
  invalidationReason:
    | null
    | "event_unavailable"
    | "participation_cancelled"
    | "consent_revoked"
    | "safety_state_changed"
    | "competing_plan_accepted"
    | "plan_cancelled"
    | "hold_expired";
  conversationId: string | null;
  pairHoldId: string | null;
}

/**
 * Server-owned, short-lived companion-seat reservation for an accepted Cross Paths invitation.
 */
export interface CrossPathsPairHoldDocument {
  eventId: string;
  invitationId: string;
  organizerId: string;
  requesterUid: string;
  attendeeUid: string;
  /**
   * @minItems 2
   * @maxItems 2
   */
  participantIds: string[];
  status: "active" | "confirmed" | "expired" | "cancelled" | "invalidated";
  requesterBookingStatus: "held" | "confirmed" | "cancelled";
  attendeeBookingStatus: "confirmed" | "cancelled";
  requesterCohortId: string;
  attendeeCohortId: string;
  requesterPriceInPaise: number;
  attendeePriceInPaise: number;
  currency: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
  confirmedAt: FirebaseFirestore.Timestamp | null;
  releasedAt: FirebaseFirestore.Timestamp | null;
  releaseReason:
    | null
    | "expired"
    | "cancelled"
    | "event_unavailable"
    | "participation_cancelled"
    | "safety_state_changed"
    | "payment_failed";
  paymentId: string | null;
  conversationId: string | null;
}

/**
 * Server-owned delivery receipt for an organizer event broadcast stored at eventBroadcasts/{broadcastId}.
 */
export interface EventBroadcastDocument {
  eventId: string;
  clubId: string;
  organizerId?: string;
  actorUid: string;
  audience: "booked" | "prospective" | "everyone";
  title: string;
  body: string;
  /**
   * @maxItems 500
   */
  targetUids: string[];
  status: "processing" | "completed" | "partial" | "failed";
  recipientCount: number;
  excludedCount: number;
  activityAvailableCount: number;
  pushAttemptedCount: number;
  pushAcceptedCount: number;
  pushFailedCount: number;
  pushUnknownCount: number;
  /**
   * @maxItems 20
   */
  pushErrorCodes: string[];
  deliveries: {
    [k: string]: {
      activityStatus: "created" | "existing" | "failed";
      pushStatus: "ineligible" | "accepted" | "failed" | "unknown";
      activityNotificationId: string;
      excluded?: boolean;
      errorCode?: string;
    };
  };
  leaseOwner: string;
  leaseExpiresAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  completedAt?: FirebaseFirestore.Timestamp | null;
}

/**
 * Server-owned waitlist offer stored at eventWaitlistOffers/{eventId_uid}. Offers reserve a waitlist slot until accepted, declined, expired, or cancelled.
 */
export interface EventWaitlistOfferDocument {
  eventId: string;
  clubId: string;
  organizerId?: string;
  uid: string;
  cohortAtOffer: string;
  status: "active" | "accepted" | "declined" | "expired" | "cancelled";
  source: "host" | "autoPromotion" | "ratioBalancing" | "cancellation";
  offeredBy: string | null;
  offeredAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
  decidedAt: FirebaseFirestore.Timestamp | null;
  expiringNotifiedAt?: FirebaseFirestore.Timestamp | null;
  inviteLinkId?: string | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Host-owned live event-success setup stored at eventSuccessPlans/{eventId}. The event id is the document id and is also stored for cheap validation and reads.
 */
export interface EventSuccessPlanDocument {
  eventId: string;
  clubId: string;
  organizerId?: string;
  layoutId?: string | null;
  /**
   * @maxItems 300
   */
  affinityConstraints?: {
    aUid: string;
    bUid: string;
    value: "mustPair" | "mustSplit" | "avoidRepeat" | "neutral";
    scope: "thisRound" | "pinned";
  }[];
  /**
   * @maxItems 300
   */
  spatialOverrides?: {
    uid: string;
    targetPeerUid: string;
    layoutUnitId: string;
    scope: "thisRound" | "pinned";
  }[];
  playbookId: string;
  /**
   * @maxItems 24
   */
  selectedModuleIds: string[];
  targetAttendeeCount: number;
  structureConfig?: {
    [k: string]: unknown;
  };
  hostGoal: string;
  wingmanRequestsEnabled: boolean;
  contextualOpenersEnabled: boolean;
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
  /**
   * Whether assigned attendees begin unselected or preselected in the end-of-event conversation graph. Missing legacy values resolve to optIn.
   */
  conversationGraphConsentMode?: "optIn" | "optOut";
  activeStepIndex: number;
  liveControlRevision?: number;
  assignmentDraftRevision?: number;
  publishedRotationRoundIndex?: number;
  publishedRevealRoundIndex?: number;
  status: "setup" | "live" | "complete";
  revealStatus?: "idle" | "countingDown" | "revealed";
  activeRevealRoundIndex?: number;
  revealStartedAt?: FirebaseFirestore.Timestamp | null;
  attendeePrompt?: string | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  frozenAt?: FirebaseFirestore.Timestamp | null;
  completedAt?: FirebaseFirestore.Timestamp | null;
}

/**
 * Attendee-private end-of-event conversation edges stored at eventSuccessConversationGraphs/{eventId_uid}. Hosts consume aggregate scorecard counts only.
 */
export interface EventSuccessConversationGraphDocument {
  eventId: string;
  clubId: string;
  organizerId: string;
  uid: string;
  status: "submitted" | "skipped";
  /**
   * @maxItems 1000
   */
  selectedUids: string[];
  assignedSelectedCount: number;
  assignedCandidateCount: number;
  /**
   * Snapshot of the event plan mode shown for this response.
   */
  consentMode: "optIn" | "optOut";
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Reusable organizer-owned parametric room layout stored at organizerEventSuccessLayouts/{organizerId_layoutId}. Derived coordinates and proximity edges are never persisted.
 */
export interface OrganizerEventSuccessLayoutDocument {
  organizerId: string;
  layoutId: string;
  label: string;
  /**
   * @minItems 1
   * @maxItems 200
   */
  units: {
    id: string;
    label: string;
    shape: "round" | "rect" | "row" | "court" | "zone";
    capacity: number;
    gridX: number;
    gridY: number;
    order: number;
  }[];
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-owned host-only precomputed assignment stored at eventSuccessAssignmentDrafts/{eventId_moduleId_uid} until its round is published.
 */
export interface EventSuccessAssignmentDraftDocument {
  eventId: string;
  clubId: string;
  organizerId: string;
  uid: string;
  moduleId: "guided_rotations";
  roundIndex: number;
  baseAssignmentRevision: number;
  assignment: EventSuccessAssignmentDocument;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Attendee-owned decomposed post-event feedback stored at eventSuccessFeedback/{eventId_uid}. Raw notes and safety concerns are private to the attendee and backend safety/coaching pipelines.
 */
export interface EventSuccessFeedbackDocument {
  eventId: string;
  clubId: string;
  organizerId?: string;
  uid: string;
  welcomeRating: number;
  structureRating: number;
  metNewPeopleCount: number;
  safetyConcern: boolean;
  privateNote?: string | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Attendee-owned opt-out preferences for live event guidance stored at eventSuccessPreferences/{eventId_uid}.
 */
export interface EventSuccessPreferenceDocument {
  eventId: string;
  clubId: string;
  organizerId?: string;
  uid: string;
  microPodsOptedOut: boolean;
  guidedRotationsOptedOut: boolean;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Attendee-owned compatibility questionnaire answers stored at eventSuccessCompatibilityResponses/{eventId_uid}. Hosts cannot read individual answers.
 */
export interface EventSuccessCompatibilityResponseDocument {
  eventId: string;
  clubId: string;
  organizerId?: string;
  uid: string;
  /**
   * @minItems 1
   * @maxItems 8
   */
  answerIds: string[];
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Explicit attendee request for host-visible introduction help stored at eventSuccessWingmanRequests/{eventId_uid}.
 */
export interface EventSuccessWingmanRequestDocument {
  eventId: string;
  clubId: string;
  organizerId?: string;
  requesterUid: string;
  targetUid: string;
  status: "active" | "withdrawn";
  hostVisibleConsent: true;
  note?: string | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-owned First Hello arrival mission stored at eventSuccessArrivalMissions/{eventId_uid}.
 */
export interface EventSuccessArrivalMissionDocument {
  eventId: string;
  clubId: string;
  organizerId?: string;
  observerUid: string;
  targetUid: string;
  targetDisplayName: string;
  targetContext: string;
  question: string;
  /**
   * @minItems 2
   * @maxItems 4
   */
  answerOptions: {
    id: string;
    label: string;
  }[];
  venueSessionId: string;
  venueSessionRedemptionId: string;
  status: "active" | "completed" | "skipped";
  selectedAnswerId?: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  completedAt?: FirebaseFirestore.Timestamp;
}

/**
 * Server-owned live guidance assignment stored at eventSuccessAssignments/{eventId_moduleId_uid}.
 */
export interface EventSuccessAssignmentDocument {
  eventId: string;
  clubId: string;
  organizerId?: string;
  uid: string;
  moduleId: "micro_pods" | "guided_rotations";
  label: string;
  displayTitle: string;
  displaySubtitle?: string | null;
  /**
   * @maxItems 20
   */
  peerUids: string[];
  unitKind?: "wholeGroup" | "pods" | "pairs" | "teams" | "tables";
  unitIndex?: number;
  unitLabel?: string;
  layoutUnitId?: string;
  confirmedLayoutUnitId?: string | null;
  whySummary?: string;
  /**
   * @maxItems 12
   */
  whyCodes?: (
    | "host_override"
    | "mutual_interest"
    | "one_way_interest"
    | "questionnaire_match"
    | "social_fallback"
    | "balanced_group"
    | "fresh_peer"
    | "repeat_peer"
    | "sit_out"
    | "pair_slot"
    | "pod_slot"
    | "table_slot"
    | "team_slot"
    | "whole_group_slot"
  )[];
  rotationFairness?: {
    assignedRoundCount: number;
    sitOutRoundCount: number;
    uniquePeerCount: number;
    repeatPeerCount: number;
  };
  /**
   * @maxItems 24
   */
  sitOutSlots?: {
    roundIndex: number;
    label: string;
    startsAt: FirebaseFirestore.Timestamp;
    endsAt: FirebaseFirestore.Timestamp;
    whySummary: string;
    /**
     * @maxItems 12
     */
    whyCodes: "sit_out"[];
  }[];
  /**
   * @maxItems 24
   */
  rotationSlots?: {
    slotId?: string;
    roundIndex: number;
    label: string;
    startsAt: FirebaseFirestore.Timestamp;
    endsAt: FirebaseFirestore.Timestamp;
    peerUid: string;
    unitKind?: "pairs";
    unitIndex?: number;
    resourceUnitId?: string;
    peerCount?: number;
    compatibility:
      | "mutual_interest"
      | "one_way_interest"
      | "questionnaire_match"
      | "social"
      | "host_override";
    whySummary?: string;
    /**
     * @maxItems 12
     */
    whyCodes?: (
      | "host_override"
      | "mutual_interest"
      | "one_way_interest"
      | "questionnaire_match"
      | "social_fallback"
      | "fresh_peer"
      | "repeat_peer"
      | "pair_slot"
    )[];
  }[];
  /**
   * @maxItems 24
   */
  groupRotationSlots?: {
    slotId?: string;
    roundIndex: number;
    label: string;
    unitLabel: string;
    unitKind?: "wholeGroup" | "pods" | "pairs" | "teams" | "tables";
    unitIndex?: number;
    startsAt: FirebaseFirestore.Timestamp;
    endsAt: FirebaseFirestore.Timestamp;
    /**
     * @maxItems 20
     */
    peerUids: string[];
    peerCount?: number;
    compatibility:
      | "mutual_interest"
      | "one_way_interest"
      | "questionnaire_match"
      | "social"
      | "mixed"
      | "host_override";
    whySummary?: string;
    /**
     * @maxItems 12
     */
    whyCodes?: (
      | "host_override"
      | "mutual_interest"
      | "questionnaire_match"
      | "social_fallback"
      | "balanced_group"
      | "fresh_peer"
      | "repeat_peer"
      | "pair_slot"
      | "pod_slot"
      | "table_slot"
      | "team_slot"
      | "whole_group_slot"
    )[];
  }[];
  source: "server_v1" | "host_override_v1" | "server";
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-owned outcome rounds stored at eventSuccessUnitOutcomes/{eventId}. Hosts may read the source; attendees consume the standings projection.
 */
export interface EventSuccessUnitOutcomesDocument {
  eventId: string;
  clubId: string;
  organizerId?: string;
  unitOutcome: "completion" | "score" | "rank";
  revision: number;
  /**
   * @maxItems 101
   */
  rounds: {
    roundIndex: number;
    /**
     * @minItems 1
     * @maxItems 200
     */
    entries: (
      | {
          unitId: string;
          unitLabel: string;
          completed: boolean;
        }
      | {
          unitId: string;
          unitLabel: string;
          score: number;
        }
      | {
          unitId: string;
          unitLabel: string;
          rank: number;
        }
    )[];
  }[];
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-owned attendee-readable standings snapshots stored at eventSuccessStandings/{eventId}.
 */
export interface EventSuccessStandingsDocument {
  eventId: string;
  clubId: string;
  organizerId?: string;
  unitOutcome: "score" | "rank";
  revision: number;
  latestRoundIndex: number;
  /**
   * @minItems 1
   * @maxItems 101
   */
  rounds: {
    roundIndex: number;
    /**
     * @minItems 1
     * @maxItems 200
     */
    entries: {
      unitId: string;
      unitLabel: string;
      position: number;
      value: number;
      roundsRecorded: number;
    }[];
  }[];
  /**
   * @minItems 1
   * @maxItems 200
   */
  entries: {
    unitId: string;
    unitLabel: string;
    position: number;
    value: number;
    roundsRecorded: number;
  }[];
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-owned aggregate event coaching metrics stored at eventSuccessScorecards/{eventId}. Raw attendee feedback remains private.
 */
export interface EventSuccessScorecardDocument {
  eventId: string;
  clubId: string;
  organizerId?: string;
  bookedCount: number;
  checkedInCount: number;
  feedbackCount: number;
  attendeesWhoMetTwoPlusPeople: number;
  catchSentCount: number;
  attendeesWhoCaughtSomeone: number;
  catchRecipientCount: number;
  catchRate: number;
  mutualMatchCount: number;
  chatStartedCount: number;
  averageWelcomeRating: number;
  averageStructureRating: number;
  safetyIncidentCount: number;
  /**
   * Host-visible aggregate conversation outcomes. Person-to-person edges remain in attendee-private documents.
   */
  conversationGraph?: {
    responseCount: number;
    skippedCount: number;
    conversationCount: number;
    attendeesWithTwoPlusConversations: number;
    excludedAttendeeCount: number;
    assignedConversationCount: number;
    assignedOpportunityCount: number;
  };
  /**
   * Host-visible operating funnel from acquisition through connection. Counts are aggregate-only and rebuilt from canonical documents.
   */
  funnel: {
    inviteLinkCount: number;
    inviteOpenCount: number;
    totalDemandCount: number;
    requestCount: number;
    pendingRequestCount: number;
    approvedRequestCount: number;
    declinedRequestCount: number;
    directSignupCount: number;
    waitlistJoinCount: number;
    waitlistOfferCount: number;
    waitlistOfferActiveCount: number;
    waitlistOfferAcceptedCount: number;
    waitlistOfferDeclinedCount: number;
    waitlistOfferExpiredCount: number;
    checkoutStartedCount: number;
    paymentPendingCount: number;
    paymentCompletedCount: number;
    paymentFailedCount: number;
    paymentRefundedCount: number;
    bookedCount: number;
    checkedInCount: number;
    noShowCount: number;
    catchSentCount: number;
    attendeesWhoCaughtSomeone: number;
    mutualMatchCount: number;
    chatStartedCount: number;
    repeatAttendeeCount: number;
  };
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Catch-private safety review item materialized from event feedback concerns.
 */
export interface EventSafetyReportDocument {
  eventId: string;
  clubId: string;
  organizerId?: string;
  reporterUserId: string;
  feedbackId: string;
  source: "event_success_feedback";
  status: "open" | "reviewed" | "dismissed";
  note?: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-owned time-slot claim stored at clubScheduleLocks/{clubId_slot}.
 */
export interface ClubScheduleLockDocument {
  ownerType: "club";
  ownerId: string;
  slot: number;
  eventId: string;
  clubId: string;
  startTimeMillis: number;
  endTimeMillis: number;
}

/**
 * Server-owned time-slot claim stored at userEventScheduleLocks/{uid_slot}.
 */
export interface UserEventScheduleLockDocument {
  ownerType: "user";
  ownerId: string;
  slot: number;
  eventId: string;
  clubId: string;
  organizerId?: string;
  uid: string;
  startTimeMillis: number;
  endTimeMillis: number;
}

/**
 * Canonical saved-event edge stored at savedEvents/{savedEventId}.
 */
export interface SavedEventDocument {
  uid: string;
  eventId: string;
  savedAt: FirebaseFirestore.Timestamp;
}

/**
 * Canonical payment record stored at payments/{paymentId}.
 */
export interface PaymentDocument {
  userId: string;
  orderId: string;
  paymentId: string;
  eventId: string;
  amount: number;
  amountMinor?: number;
  currency: string;
  provider?: "razorpay" | "stripe";
  /**
   * refundFailed marks a booking that failed AND whose automatic refund could not be issued, so the charge is stuck and needs manual reconciliation.
   */
  status: "pending" | "completed" | "failed" | "refunded" | "refundFailed";
  providerPaymentId?: string | null;
  checkoutSessionId?: string | null;
  hostUserId?: string;
  stripeAccountId?: string | null;
  applicationFeeAmount?: number;
  /**
   * Named host invite link attributed to this payment, when present.
   */
  inviteLinkId?: string | null;
  /**
   * Host-facing invite source copied from eventInviteLinks.
   */
  inviteSource?: string | null;
  /**
   * Pair hold consumed by this booking, when present.
   */
  crossPathsPairHoldId?: string | null;
  signUpFailed: boolean;
  createdAt: FirebaseFirestore.Timestamp;
  completedAt?: FirebaseFirestore.Timestamp;
}

/**
 * Server-owned payment provider account state for a host. Stored at hostPaymentAccounts/{uid}.
 */
export interface HostPaymentAccountDocument {
  userId: string;
  provider: "stripe";
  country: string;
  defaultCurrency: string;
  stripeAccountId: string;
  chargesEnabled: boolean;
  payoutsEnabled: boolean;
  detailsSubmitted: boolean;
  onboardingStatus: "notStarted" | "pending" | "complete" | "restricted";
  disabledReason?: string | null;
  /**
   * @maxItems 80
   */
  requirementsCurrentlyDue: string[];
  /**
   * @maxItems 80
   */
  requirementsPastDue: string[];
  /**
   * @maxItems 80
   */
  requirementsPendingVerification: string[];
  lastStripeEventId?: string | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-owned tracking record for a created-but-not-yet-fulfilled Razorpay order, stored at razorpayPendingOrders/{orderId}. Lets the webhook and reconciliation sweep recover bookings when the client verification callback never lands. Deleted once the matching payments/{paymentId} completed record exists.
 */
export interface RazorpayPendingOrderDocument {
  provider: "razorpay";
  orderId: string;
  userId: string;
  eventId: string;
  amountInPaise: number;
  currency: string;
  /**
   * pending until fulfilled (then the doc is deleted); failed when Razorpay reported payment.failed; expired when the reconciliation sweep found no captured payment after the grace window.
   */
  status: "pending" | "failed" | "expired";
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt?: FirebaseFirestore.Timestamp;
}

/**
 * Storage contract for contextual profile decisions stored at profileDecisions/{userId}/outgoing/{targetId}.
 */
export interface SwipeDocument {
  swiperId: string;
  targetId: string;
  eventId: string;
  direction: "like" | "pass";
  reactionTargetId?: string | null;
  reactionTargetType?:
    | "heroPhoto"
    | "photo"
    | "profilePrompt"
    | "compatibility"
    | "running"
    | "details"
    | "lifestyle"
    | null;
  reactionTargetLabel?: string | null;
  reactionTargetPreview?: string | null;
  comment?: string | null;
  createdAt: FirebaseFirestore.Timestamp;
}

/**
 * Canonical match document stored at matches/{matchId}.
 */
export interface MatchDocument {
  user1Id: string;
  user2Id: string;
  /**
   * @minItems 0
   */
  eventIds: string[];
  createdAt: FirebaseFirestore.Timestamp;
  lastMessageAt?: FirebaseFirestore.Timestamp | null;
  lastMessagePreview?: string | null;
  lastMessageSenderId?: string | null;
  unreadCounts: {
    [k: string]: number;
  };
  status: "active" | "blocked" | "closed";
  blockedBy?: string | null;
  blockedAt?: FirebaseFirestore.Timestamp | null;
  /**
   * @minItems 2
   * @maxItems 2
   */
  participantIds: string[];
  conversationType?: "match" | "clubHostInquiry" | "crossPathsEventPlan";
  clubId?: string;
  organizerId?: string;
  crossPathsInvitationId?: string;
  eventPlanExpiresAt?: FirebaseFirestore.Timestamp;
  closedAt?: FirebaseFirestore.Timestamp | null;
}

/**
 * Canonical chat message document stored at matches/{matchId}/messages/{messageId}.
 */
export interface ChatMessageDocument {
  senderId: string;
  text: string;
  imageUrl?: string | null;
  sentAt?: FirebaseFirestore.Timestamp | null;
}

/**
 * Canonical durable activity notification stored at notifications/{uid}/items/{notificationId}.
 */
export interface ActivityNotificationDocument {
  uid: string;
  type:
    | "message"
    | "match"
    | "eventReminder"
    | "eventSignup"
    | "waitlistPromotion"
    | "waitlistOffer"
    | "waitlistOfferExpiring"
    | "waitlistOfferExpired"
    | "eventCancelled"
    | "eventUpdated"
    | "clubUpdate"
    | "organizerUpdate"
    | "formResponse"
    | "crossPathsInvitation"
    | "crossPathsInvitationAccepted"
    | "crossPathsInvitationDeclined"
    | "crossPathsPlanCancelled";
  title: string;
  body: string;
  createdAt: FirebaseFirestore.Timestamp;
  readAt?: FirebaseFirestore.Timestamp | null;
  matchId?: string | null;
  eventId?: string | null;
  clubId?: string | null;
  organizerId?: string | null;
  postId?: string | null;
  invitationId?: string | null;
  actorUid?: string | null;
  actorName?: string | null;
}

/**
 * Canonical organizer review stored at reviews/{reviewId}. Verified reviews come from attended Catch events; unverified reviews can come from public listing pages.
 */
export interface ReviewDocument {
  /**
   * Deprecated organizer id alias retained while released clients migrate.
   */
  clubId: string;
  organizerId: string;
  eventId?: string | null;
  /**
   * Catch user id for signed-in reviewers. Null for anonymous public listing reviews.
   */
  reviewerUserId: string | null;
  reviewerName: string;
  rating: number;
  comment: string;
  /**
   * Verified reviews are created only after attended Catch events; public listing reviews are unverified.
   */
  verificationStatus?: "verified" | "unverified";
  /**
   * Submission surface that created the review.
   */
  source?: "catchEvent" | "publicListing";
  /**
   * Public rendering status for organizer listing pages.
   */
  moderationStatus?: "published" | "pending" | "rejected";
  /**
   * True when the public display name should be the anonymous fallback rather than a user-supplied or profile name.
   */
  isAnonymous?: boolean;
  /**
   * Website path that submitted an unverified public listing review.
   */
  submittedFromPath?: string | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt?: FirebaseFirestore.Timestamp | null;
  ownerResponse?: {
    hostUserId: string;
    hostName: string;
    hostAvatarUrl: string | null;
    message: string;
    createdAt: FirebaseFirestore.Timestamp;
    updatedAt: FirebaseFirestore.Timestamp;
  };
}

/**
 * Canonical safety block edge stored at blocks/{blockId}.
 */
export interface BlockDocument {
  blockerUserId: string;
  blockedUserId: string;
  createdAt: FirebaseFirestore.Timestamp;
  source: "profile" | "chat" | "match" | "support";
  reasonCode?: string;
}

/**
 * Canonical safety report stored at reports/{reportId}.
 */
export interface ReportDocument {
  reporterUserId: string;
  targetUserId: string;
  createdAt: FirebaseFirestore.Timestamp;
  source: "profile" | "chat" | "match" | "support";
  status: "open" | "reviewed" | "dismissed";
  reasonCode?: string;
  contextId?: string;
  notes?: string;
}

/**
 * Canonical moderation ticket stored at moderationFlags/{flagId}.
 */
export interface ModerationFlagDocument {
  targetUserId: string;
  flagType: "explicit_photo" | "banned_text" | "underage_content";
  source:
    | "profile_photo"
    | "club_image"
    | "chat_message"
    | "user_bio"
    | "club_description"
    | "review_comment";
  status: "pending" | "reviewed" | "dismissed";
  createdAt: FirebaseFirestore.Timestamp;
  reviewedAt?: FirebaseFirestore.Timestamp;
  contextId?: string;
  context?: string;
  safeSearchResults?: {
    [k: string]: string;
  };
}

/**
 * Server-owned account-deletion tombstone stored at deletedUsers/{uid}.
 */
export interface DeletedUserTombstoneDocument {
  uid: string;
  deletedAt: FirebaseFirestore.Timestamp;
  status: "processing" | "completed";
  updatedAt: FirebaseFirestore.Timestamp;
  completedAt?: FirebaseFirestore.Timestamp | null;
  retainedFor?: string[];
}

/**
 * Server-owned callable rate-limit counter stored at rateLimits/{docId}.
 */
export interface RateLimitDocument {
  uid: string;
  action: string;
  windowKey: number;
  count: number;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-owned 15-minute response cache stored at hostAnalyticsSnapshots/{uid}_{scopeHash}.
 */
export interface HostAnalyticsSnapshotDocument {
  uid: string;
  scopeHash: string;
  response: HostAnalyticsCallableResponse;
  createdAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-owned idempotency receipt stored at functionEventReceipts/{receiptId}.
 */
export interface FunctionEventReceiptDocument {
  handler: "onMessageCreated" | "onMatchCreated" | "moderatePhotoOnUpload";
  eventId?: string;
  matchId?: string;
  messageId?: string;
  createdAt: FirebaseFirestore.Timestamp;
}

/**
 * Server-owned reservation for a public website route. Stored at publicRouteReservations/{routeKey}; routeKey is derived from the normalized route path so route allocation is deterministic and transactionally claimable.
 */
export interface PublicRouteReservationDocument {
  /**
   * Deterministic document id derived from routePath by removing leading/trailing slash and replacing route separators with double underscores.
   */
  routeKey: string;
  routePath: string;
  routeKind: "organizerCanonical";
  /**
   * @minItems 2
   * @maxItems 3
   */
  routeSegments: string[];
  status: "active" | "released";
  ownerType: "club" | "organizer";
  ownerCollection: "clubs" | "organizers";
  ownerId: string;
  targetPath: string;
  slug: string;
  citySlug: string | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  lastVerifiedAt: FirebaseFirestore.Timestamp;
  lastVerifiedByUid: string;
  lastVerifiedSource:
    | "adminUpdateClubDetails"
    | "adminSetClubIndexStatus"
    | "adminUpdateOrganizerDetails"
    | "adminSetOrganizerIndexStatus"
    | "adminCreateOrganizerDraftFromCandidate"
    | "createOrganizer"
    | "clubsToOrganizersMigration";
  releasedAt?: FirebaseFirestore.Timestamp | null;
  releasedByUid?: string | null;
  replacementRoutePath?: string | null;
}

/**
 * Tool-owned synthetic-data manifest stored at seedEvents/{manifestId}.
 */
export interface SeedEventManifestDocument {
  seedId: string;
  manifestId: string;
  generatedAt: FirebaseFirestore.Timestamp;
  anchorUserIds: string[];
  counts: {
    [k: string]: number;
  };
  paths: string[];
  appendMode?: boolean;
  appendedAnchorUserIds?: string[];
}

/**
 * Latest admin review decision stored at organizerIntakeReviewDecisions/{entityId}. Candidate evidence remains in operationRuns and operationWorkItems.
 */
export interface OrganizerIntakeReviewDecisionDocument {
  schemaVersion: 1;
  entityId: string;
  decision: "approve_public" | "hold" | "suppress";
  decisionStatus: "approved_public" | "held" | "suppressed";
  publishStatus: "draft" | "published" | "suppressed";
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
     * True when the reviewer explicitly inspected manual reports that have no stored source artifact. Projection replay decides when this acknowledgement is required.
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
  reviewedByUid: string;
  reviewedAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  projectionState: "pending_static_generation" | "not_projectable";
}

/**
 * Latest admin review decision stored at eventIntakeReviewDecisions/{decisionId}. Source artifacts, marketing content, imported events, and canonical events are not stored here.
 */
export interface EventIntakeReviewDecisionDocument {
  schemaVersion: 1;
  decisionId: string;
  targetType:
    | "source_profile"
    | "query_template"
    | "run_plan"
    | "source_result"
    | "event_candidate";
  targetId: string;
  decision: "approve" | "needs_changes" | "hold" | "reject";
  decisionStatus: "approved" | "needs_changes" | "held" | "rejected";
  runId: string | null;
  note: string;
  checklist: {
    sourceReviewed: boolean;
    dateReviewed: boolean;
    venueReviewed: boolean;
    copyReviewed: boolean;
    rightsReviewed: boolean;
    noCatchHostingImplied: boolean;
  };
  /**
   * Changed fields only. Each entry freezes its reviewed before and after value.
   */
  edits: {
    [k: string]: {
      before: unknown;
      after: unknown;
    };
  };
  reviewedByUid: string;
  reviewedAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  effect: "decision_only_no_publish";
}

/**
 * One manual organizer-intake curation operation stored at organizerIntakeCurationDecisions/{operationId}. Candidate evidence remains in operationRuns and operationWorkItems.
 */
export interface OrganizerIntakeCurationDecisionDocument {
  schemaVersion: 1;
  operationId: string;
  operationType:
    | "attach_surface"
    | "create_entity_draft"
    | "merge_entity"
    | "split_surface"
    | "suppress_entity"
    | "surface_decision";
  operationStatus: "active" | "superseded";
  entityId?: string;
  sourceEntityId?: string;
  targetEntityId?: string;
  surfaceId?: string;
  newEntityId?: string;
  sourceCandidateId?: string;
  sourceWorkItemId?: string;
  sourceNormalizedKey?: string;
  /**
   * Public route slug reserved when a candidate becomes an organizer draft. It is intentionally separate from entityId.
   */
  publicSlug?: string;
  /**
   * Source artifact lineage for each field projected into the organizer draft.
   *
   * @maxItems 200
   */
  fieldProvenance?: {
    field: string;
    artifactId: string;
    contentHash: string;
    locator: string | null;
    extractedBy: "deterministic" | "model" | "human";
    extractorVersion: string;
    confidence: number | null;
  }[];
  decision?:
    | "accept_primary"
    | "accept_secondary"
    | "reject_wrong_entity"
    | "mark_ambiguous"
    | "mark_historical";
  surface?: {
    surfaceId: string;
    platform:
      | "bookMyShow"
      | "district"
      | "instagram"
      | "linkedin"
      | "luma"
      | "news"
      | "officialWebsite"
      | "partiful"
      | "sortMyScene"
      | "userReport"
      | "other";
    surfaceKind:
      | "eventListing"
      | "eventCalendar"
      | "organizerProfile"
      | "personProfile"
      | "press"
      | "socialProfile"
      | "website"
      | "wrongEntity";
    url: string | null;
    normalizedKey: string | null;
    role:
      | "primary"
      | "secondary"
      | "backup"
      | "historical"
      | "ambiguous"
      | "rejected";
    status: "active" | "candidate" | "ambiguous" | "historical" | "rejected";
    confidence: {
      entityMatch: "low" | "medium" | "high";
      ownership: "low" | "medium" | "high";
      city: "low" | "medium" | "high";
    };
    crawl: {
      eventDiscoveryStatus: "disabled" | "candidate" | "approved" | "paused";
      policy: "manualOnly" | "blocked" | "apiPreferred";
      supportsEventExtraction: boolean;
    };
    evidenceRefs: {
      type:
        | "hostDiscoveryRun"
        | "seedClub"
        | "userReportedSearchResult"
        | "manualNote";
      ref: string | null;
      description: string;
    }[];
    notes: string;
  };
  reason: string;
  reviewedByUid: string;
  reviewedAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

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
  correctedAt: FirebaseFirestore.Timestamp;
}

/**
 * Latest admin event-candidate review decision stored at organizerEventCandidateReviewDecisions/{decisionId}. Raw provider event evidence and imported events are not stored here.
 */
export interface OrganizerEventCandidateReviewDecisionDocument {
  schemaVersion: 1;
  decisionId: string;
  candidateId: string;
  decision: "approve_for_import" | "hold" | "reject";
  decisionStatus: "approved_for_import" | "held" | "rejected";
  checklist: {
    identityReviewed: boolean;
    sourceEventReviewed: boolean;
    timeReviewed: boolean;
    locationReviewed: boolean;
    dedupeReviewed: boolean;
    ownerSafeCopyReviewed: boolean;
    importPolicyAcknowledged: boolean;
  };
  /**
   * @maxItems 6
   */
  blockerResolutions?: ExternalEventBlockerResolution[];
  note: string;
  reviewedByUid: string;
  reviewedAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  importState: "blocked_by_policy" | "not_importable" | "pending_import";
}

/**
 * Latest admin-reviewed event location resolution stored at organizerEventLocationResolutionDecisions/{resolutionId}. Raw provider lookup responses and imported events are not stored here.
 */
export interface OrganizerEventLocationResolutionDecisionDocument {
  schemaVersion: 1;
  resolutionId: string;
  candidateId: string;
  location: {
    name: string;
    address?: string | null;
    placeId?: string | null;
    latitude: number | null;
    longitude: number | null;
    notes?: string | null;
  };
  checklist: {
    sourceLocationReviewed: boolean;
    coordinatesReviewed: boolean;
    placeIdentityReviewed: boolean;
    importSafetyReviewed: boolean;
  };
  note: string;
  reviewedByUid: string;
  reviewedAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  resolutionStatus: "resolved";
}

/**
 * Latest admin/product policy-gap review decision stored at organizerPolicyGapReviewDecisions/{decisionId}. These decisions are review state only and do not enable organizer crawls, provider lookups, event imports, defaults, or naming migrations.
 */
export interface OrganizerPolicyGapReviewDecisionDocument {
  schemaVersion: 1;
  decisionId: string;
  gapId: string;
  decision: "accept" | "hold" | "reject";
  decisionStatus: "accepted" | "held" | "rejected";
  /**
   * @maxItems 20
   */
  requiredInputsReviewed: string[];
  checklist: {
    requiredInputsReviewed: boolean;
    costAndSafetyReviewed: boolean;
    implementationOwnerReviewed: boolean;
    behaviorStillDisabledAcknowledged: boolean;
  };
  note: string;
  reviewedByUid: string;
  reviewedAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  operationalState: "blocked_until_policy_encoded" | "not_approved";
}
