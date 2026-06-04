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

export type PaymentStatus = "pending" | "completed" | "failed" | "refunded";

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
  latitude: number | null;
  longitude: number | null;
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
 * Public city configuration stored at config/cities.
 */
export interface ConfigCitiesDocument {
  /**
   * @minItems 1
   */
  cityNames: (string | null)[];
  cities?: {
    name: string | null;
    label: string;
    latitude: number | null;
    longitude: number | null;
    countryIsoCode: string;
    currencyCode: string;
    dialCode: string;
    timeZone: string;
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
 * Canonical club document stored at clubs/{clubId}. The club id is the document id and is not stored in document data.
 */
export interface ClubDocument {
  name: string;
  description: string;
  location: string | null;
  area: string;
  hostUserId: string;
  hostName: string;
  hostAvatarUrl: string | null;
  ownerUserId: string;
  /**
   * @minItems 1
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
 * Canonical event document stored at events/{eventId}. The event id is the document id and is not stored in document data.
 */
export interface EventDocument {
  clubId: string;
  startTime: FirebaseFirestore.Timestamp;
  endTime: FirebaseFirestore.Timestamp;
  meetingPoint: string;
  meetingLocation?: EventMeetingLocation | null;
  startingPointLat?: number | null;
  startingPointLng?: number | null;
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
  discoveryCityName?: string | null;
  discoveryActivityKind?:
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
  discoveryGeoCell?: string | null;
  discoveryHasOpenSpots?: boolean;
  discoveryAvailability?: "open" | "waitlist" | "gated" | "full" | "cancelled";
  /**
   * @maxItems 4
   */
  discoveryOpenCohorts?: (
    | "menInterestedInWomen"
    | "womenInterestedInMen"
    | "queerOrOpen"
    | "nonBinaryOrOther"
  )[];
  /**
   * @maxItems 4
   */
  discoveryWaitlistCohorts?: (
    | "menInterestedInWomen"
    | "womenInterestedInMen"
    | "queerOrOpen"
    | "nonBinaryOrOther"
  )[];
  discoveryInviteRequired?: boolean;
  discoveryMembershipRequired?: boolean;
  discoveryManualApprovalRequired?: boolean;
  discoveryMinAge?: number;
  discoveryMaxAge?: number;
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
  status: "pending" | "completed" | "failed" | "refunded";
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
  actorUid?: string | null;
  actorName?: string | null;
}

/**
 * Canonical attended-event review stored at reviews/{reviewId}.
 */
export interface ReviewDocument {
  clubId: string;
  eventId?: string | null;
  reviewerUserId: string;
  reviewerName: string;
  rating: number;
  comment: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt?: FirebaseFirestore.Timestamp | null;
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
  handler: "onMessageCreated";
  eventId: string;
  matchId: string;
  messageId: string;
  createdAt: FirebaseFirestore.Timestamp;
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
