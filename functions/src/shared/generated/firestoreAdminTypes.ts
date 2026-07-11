/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

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
}

export interface EventSuccessStructureConfig {
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
}

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
  playbookId?: string;
  /**
   * @maxItems 24
   */
  selectedModuleIds?: string[];
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
    policyId: "flexible" | "standard" | "strict";
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
 * Canonical club document stored at clubs/{clubId}. The club id is the document id and is not stored in document data.
 */
export interface ClubDocument {
  name: string;
  description: string;
  /**
   * Canonical launch market id. Public URL slugs live under publicPage.citySlug.
   */
  location: string;
  locationCityId: string;
  locationMarketId: string;
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
 * Canonical organizer post stored at clubs/{clubId}/posts/{postId}.
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
  startTime: FirebaseFirestore.Timestamp;
  endTime: FirebaseFirestore.Timestamp;
  meetingPoint: string;
  meetingLocation: EventMeetingLocation | null;
  startingPointLat?: number;
  startingPointLng?: number;
  locationDetails?: string | null;
  photoUrl?: string | null;
  /**
   * @maxItems 12
   */
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
  discoveryGeoCell: string | null;
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
    latitude: (number | null) | null;
    longitude: (number | null) | null;
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
  };
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

/**
 * Host-private access material for invite-only events stored at eventPrivateAccess/{eventId}.
 */
export interface EventPrivateAccessDocument {
  eventId: string;
  clubId: string;
  inviteCode: string;
  createdAt: FirebaseFirestore.Timestamp;
}

/**
 * Host-created named invite link stored at eventInviteLinks/{inviteLinkId}. The document tracks live attribution counters while preserving disabled links for historical reporting.
 */
export interface EventInviteLinkDocument {
  eventId: string;
  clubId: string;
  hostUid: string;
  label: string;
  source: string | null;
  tokenHash: string;
  openCount: number;
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
 * Canonical event roster edge stored at eventParticipations/{participationId}.
 */
export interface EventParticipationDocument {
  eventId: string;
  clubId: string;
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
 * Server-owned delivery receipt for an organizer event broadcast stored at eventBroadcasts/{broadcastId}.
 */
export interface EventBroadcastDocument {
  eventId: string;
  clubId: string;
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
  playbookId: string;
  /**
   * @maxItems 24
   */
  selectedModuleIds: string[];
  targetAttendeeCount: number;
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
  activeStepIndex: number;
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
 * Attendee-owned decomposed post-event feedback stored at eventSuccessFeedback/{eventId_uid}. Raw notes and safety concerns are private to the attendee and backend safety/coaching pipelines.
 */
export interface EventSuccessFeedbackDocument {
  eventId: string;
  clubId: string;
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
 * Server-owned aggregate event coaching metrics stored at eventSuccessScorecards/{eventId}. Raw attendee feedback remains private.
 */
export interface EventSuccessScorecardDocument {
  eventId: string;
  clubId: string;
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
  signUpFailed: boolean;
  createdAt: FirebaseFirestore.Timestamp;
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
  status: "active" | "blocked";
  blockedBy?: string | null;
  blockedAt?: FirebaseFirestore.Timestamp | null;
  /**
   * @minItems 2
   * @maxItems 2
   */
  participantIds: string[];
  conversationType?: "match" | "clubHostInquiry";
  clubId?: string;
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
    | "clubUpdate";
  title: string;
  body: string;
  createdAt: FirebaseFirestore.Timestamp;
  readAt?: FirebaseFirestore.Timestamp | null;
  matchId?: string | null;
  eventId?: string | null;
  clubId?: string | null;
  postId?: string | null;
  actorUid?: string | null;
  actorName?: string | null;
}

/**
 * Canonical organizer review stored at reviews/{reviewId}. Verified reviews come from attended Catch events; unverified reviews can come from public listing pages.
 */
export interface ReviewDocument {
  clubId: string;
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
  ownerType: "club";
  ownerCollection: "clubs";
  ownerId: string;
  targetPath: string;
  slug: string;
  citySlug: string | null;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  lastVerifiedAt: FirebaseFirestore.Timestamp;
  lastVerifiedByUid: string;
  lastVerifiedSource: "adminUpdateClubDetails" | "adminSetClubIndexStatus";
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
 * Latest admin review decision stored at organizerIntakeReviewDecisions/{entityId}. Raw scrape/search evidence is not stored here.
 */
export interface OrganizerIntakeReviewDecisionDocument {
  schemaVersion: 1;
  entityId: string;
  decision: "approve_public" | "hold" | "suppress";
  decisionStatus: "approved_public" | "held" | "suppressed";
  appVisibility: "hidden" | "discoverable";
  checklist: {
    identityReviewed: boolean;
    surfaceInventoryReviewed: boolean;
    ownerSafeCopyReviewed: boolean;
    marketScopeReviewed: boolean;
    mediaRightsReviewed: boolean;
    crawlDisabledReviewed: boolean;
    /**
     * True when the reviewer explicitly inspected manual reports that have no local raw artifact. Raw evidence remains outside Firestore; projection replay decides when this acknowledgement is required.
     */
    manualReportsReviewed?: boolean;
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
  edits: {
    [k: string]: unknown;
  };
  reviewedByUid: string;
  reviewedAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  effect: "decision_only_no_publish";
}

/**
 * One manual organizer-intake curation operation stored at organizerIntakeCurationDecisions/{operationId}. Raw scrape/search evidence is not stored here.
 */
export interface OrganizerIntakeCurationDecisionDocument {
  schemaVersion: 1;
  operationId: string;
  operationType:
    | "attach_surface"
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
