/**
 * Firestore document interfaces for Cloud Functions.
 *
 * These mirror the Dart freezed models in
 * lib/<feature>/domain/<Model>.dart exactly.
 * Enum values match what Dart's json_serializable serialises by default
 * (enum member name, camelCase — e.g. DrinkingHabit.socially → "socially").
 *
 * SYNC RULE: any change to a Dart model field or enum value that is read or
 * written by a Cloud Function must be reflected here, and vice-versa.
 * The TypeScript compiler will then surface the mismatch in the function code.
 *
 * Fields marked with "@JsonKey(includeToJson: false)" in Dart are the document
 * ID and are NOT stored inside the document data; they are noted below.
 *
 * Timestamps are stored as Firestore timestamps in the DB. In admin SDK code,
 * use FirebaseFirestore.Timestamp and FieldValue.serverTimestamp() to write.
 */

// FirebaseFirestore.Timestamp is available globally via
// @google-cloud/firestore, a transitive dependency of firebase-admin.

// Shared enum types.

export type Gender = "man" | "woman" | "nonBinary" | "other";

export type SexualOrientation =
  | "straight"
  | "gay"
  | "bisexual"
  | "pansexual"
  | "asexual"
  | "other";

export type EducationLevel =
  | "highSchool"
  | "someCollege"
  | "bachelors"
  | "masters"
  | "phd"
  | "tradeSchool"
  | "other";

export type Religion =
  | "hindu"
  | "muslim"
  | "christian"
  | "sikh"
  | "jain"
  | "buddhist"
  | "other"
  | "nonReligious";

export type Language =
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
  | "other";

export type RelationshipGoal =
  | "relationship"
  | "casual"
  | "marriage"
  | "friendship"
  | "unsure";

export type DrinkingHabit = "never" | "socially" | "often";

export type SmokingHabit = "never" | "occasionally" | "often";

export type WorkoutFrequency = "never" | "sometimes" | "often" | "everyday";

export type DietaryPreference =
  | "omnivore"
  | "vegetarian"
  | "vegan"
  | "jain"
  | "other";

export type ChildrenStatus =
  | "dontHave"
  | "haveWantMore"
  | "haveNoMore"
  | "wantSomeday"
  | "dontWant";

export type PaceLevel = "easy" | "moderate" | "fast" | "competitive";

export type PreferredDistance = "fiveK" | "tenK" | "halfMarathon" | "marathon";

export type RunReason =
  | "fitness"
  | "community"
  | "mindfulness"
  | "challenge"
  | "weightLoss"
  | "raceTraining"
  | "social";

export type SwipeDirection = "like" | "pass";

export type IndianCity =
  | "mumbai"
  | "delhi"
  | "bangalore"
  | "hyderabad"
  | "chennai"
  | "kolkata"
  | "pune"
  | "ahmedabad"
  | "indore";

// Document interfaces.

/**
 * /users/{uid}
 * Dart: lib/user_profile/domain/user_profile.dart — UserProfile
 * Note: "uid" is the document ID, not stored in the document data.
 */
export interface UserProfileDoc {
  // Core
  email: string;
  name: string;
  dateOfBirth: FirebaseFirestore.Timestamp;
  bio: string;
  gender: Gender;
  sexualOrientation: SexualOrientation;
  phoneNumber: string;
  profileComplete: boolean;
  // Photos
  photoUrls: string[];
  // Location (optional — set during onboarding)
  city?: IndianCity;
  latitude?: number;
  longitude?: number;
  // Matching preferences
  joinedRunClubIds: string[];
  savedRunIds: string[];
  interestedInGenders: Gender[];
  minAgePreference: number;
  maxAgePreference: number;
  // Runtime — written by FcmService, not part of the profile form
  fcmToken?: string;
  // Safety/account lifecycle fields written by account deletion flow.
  deleted?: boolean;
  deletedAt?: FirebaseFirestore.Timestamp;
  // Background (optional)
  height?: number;
  occupation?: string;
  company?: string;
  education?: EducationLevel;
  religion?: Religion;
  languages?: Language[];
  // Intentions (optional)
  relationshipGoal?: RelationshipGoal;
  // Lifestyle (optional)
  drinking?: DrinkingHabit;
  smoking?: SmokingHabit;
  workout?: WorkoutFrequency;
  diet?: DietaryPreference;
  children?: ChildrenStatus;
  // Running preferences
  paceMinSecsPerKm: number;
  paceMaxSecsPerKm: number;
  preferredDistances: PreferredDistance[];
  runningReasons: RunReason[];
  // Notification / discovery preferences
  prefsNewCatches: boolean;
  prefsRunReminders: boolean;
  prefsWeeklyDigest: boolean;
  prefsShowOnMap: boolean;
}

/**
 * /publicProfiles/{uid}
 * Dart: lib/publicProfile/domain/public_profile.dart — PublicProfile
 * Note: "uid" is the document ID, not stored in the document data.
 * Written exclusively by syncPublicProfile Cloud Function.
 */
export interface PublicProfileDoc {
  name: string;
  age: number; // Computed from UserProfileDoc.dateOfBirth by syncPublicProfile
  bio: string;
  gender: Gender;
  photoUrls: string[];
  city?: IndianCity;
  latitude?: number;
  longitude?: number;
  height?: number;
  occupation?: string;
  company?: string;
  education?: EducationLevel;
  religion?: Religion;
  languages?: Language[];
  relationshipGoal?: RelationshipGoal;
  drinking?: DrinkingHabit;
  smoking?: SmokingHabit;
  workout?: WorkoutFrequency;
  diet?: DietaryPreference;
  children?: ChildrenStatus;
  paceMinSecsPerKm: number;
  paceMaxSecsPerKm: number;
  preferredDistances: PreferredDistance[];
  runningReasons: RunReason[];
}

/**
 * /runClubs/{clubId}
 * Dart: lib/run_clubs/domain/run_club.dart — RunClub
 * Note: "id" is the document ID, not stored in the document data.
 */
export interface RunClubDoc {
  name: string;
  description: string;
  location: IndianCity;
  area: string;
  hostUserId: string;
  hostName: string;
  hostAvatarUrl?: string | null;
  createdAt: FirebaseFirestore.Timestamp;
  imageUrl?: string | null;
  tags: string[];
  memberUserIds: string[];
  memberCount: number;
  rating: number;
  reviewCount: number;
  nextRunAt?: FirebaseFirestore.Timestamp | null;
  nextRunLabel?: string | null;
  instagramHandle?: string | null;
  phoneNumber?: string | null;
  email?: string | null;
}

/**
 * Eligibility constraints set by the host when creating a run.
 * Dart: lib/runs/domain/run_constraints.dart — RunConstraints
 */
export interface RunConstraints {
  minAge: number; // default 0 (no lower bound)
  maxAge: number; // default 99 (no upper bound)
  maxMen?: number; // null/absent = no cap
  maxWomen?: number; // null/absent = no cap
}

/**
 * /runs/{runId}
 * Dart: lib/runs/domain/run.dart — Run
 * Note: "id" is the document ID, not stored in the document data.
 */
export interface RunDoc {
  runClubId: string;
  startTime: FirebaseFirestore.Timestamp;
  endTime: FirebaseFirestore.Timestamp;
  meetingPoint: string;
  startingPointLat?: number | null;
  startingPointLng?: number | null;
  locationDetails?: string | null;
  distanceKm: number;
  pace: PaceLevel;
  capacityLimit: number;
  description: string;
  priceInPaise: number;
  signedUpUserIds: string[];
  attendedUserIds: string[];
  waitlistUserIds: string[];
  constraints: RunConstraints;
  // Denormalized counts maintained atomically on sign-up/cancel.
  // Keys are Gender enum names: 'man', 'woman', 'nonBinary', 'other'.
  genderCounts: Record<string, number>;
}

export type PaymentStatus = "pending" | "completed" | "failed" | "refunded";

/**
 * /payments/{paymentId}
 * Dart: lib/payments/domain/payment.dart — Payment
 * Note: "id" is the document ID
 * (= Razorpay paymentId for paid, auto-id for free).
 */
export interface PaymentDoc {
  userId: string;
  orderId: string;
  paymentId: string;
  runId: string;
  amount: number; // in paise
  currency: string;
  status: PaymentStatus;
  createdAt: FirebaseFirestore.Timestamp;
  /**
   * True when payment succeeded but sign-up failed due to a race or refund.
   */
  signUpFailed?: boolean;
}

/**
 * /swipes/{userId}/outgoing/{targetId}
 * Dart: lib/swipes/domain/swipe.dart — Swipe
 */
export interface SwipeDoc {
  swiperId: string;
  targetId: string;
  runId: string;
  direction: SwipeDirection;
  createdAt: FirebaseFirestore.Timestamp;
}

/**
 * /matches/{matchId}
 * Dart: lib/matches/domain/match.dart — Match
 * Note: "id" is the document ID, not stored in the document data.
 * Written exclusively by onSwipeCreated Cloud Function.
 */
export interface MatchDoc {
  user1Id: string;
  user2Id: string;
  // Always [user1Id, user2Id], used for Firestore arrayContains queries.
  participantIds: string[];
  runId: string;
  createdAt: FirebaseFirestore.Timestamp;
  lastMessageAt: FirebaseFirestore.Timestamp | null;
  lastMessagePreview: string | null;
  lastMessageSenderId: string | null;
  unreadCounts: Record<string, number>; // { [uid]: unreadCount }
  status?: "active" | "blocked";
  blockedBy?: string;
  blockedAt?: FirebaseFirestore.Timestamp;
}

/**
 * /blocks/{blockerUserId}__{blockedUserId}
 * Server-enforced safety edge. Either direction blocks shared dating surfaces.
 */
export interface BlockDoc {
  blockerUserId: string;
  blockedUserId: string;
  createdAt: FirebaseFirestore.Timestamp;
  source: "profile" | "chat" | "match" | "support";
  reasonCode?: string;
}

/**
 * /reports/{reportId}
 * Server-owned safety report for abuse/moderation review.
 */
export interface ReportDoc {
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
 * /chats/{matchId}/messages/{messageId}
 * Dart: lib/chats/domain/chat_message.dart — ChatMessage
 * Note: "id" is the document ID, not stored in the document data.
 */
export interface ChatMessageDoc {
  senderId: string;
  text: string;
  sentAt: FirebaseFirestore.Timestamp;
}

/**
 * /reviews/{reviewId}
 * Dart: lib/reviews/domain/review.dart — Review
 * Note: "id" is the document ID, not stored in the document data.
 * The current client uses one deterministic review document per
 * `(runClubId, reviewerUserId)` pair.
 */
export interface ReviewDoc {
  runClubId: string;
  runId?: string;
  reviewerUserId: string;
  reviewerName: string;
  rating: number;
  comment: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt?: FirebaseFirestore.Timestamp;
}

/**
 * /moderationFlags/{flagId}
 * Server-owned moderation ticket created when auto-moderation flags content.
 */
export interface ModerationFlagDoc {
  targetUserId: string;
  flagType: "explicit_photo" | "banned_text" | "underage_content";
  source: "profile_photo" | "club_image" | "chat_message" | "user_bio"
    | "club_description" | "review_comment";
  status: "pending" | "reviewed" | "dismissed";
  createdAt: FirebaseFirestore.Timestamp;
  reviewedAt?: FirebaseFirestore.Timestamp;
  contextId?: string;
  context?: string;
  safeSearchResults?: Record<string, string>;
}
