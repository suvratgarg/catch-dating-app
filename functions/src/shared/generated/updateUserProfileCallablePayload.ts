/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import {ProfilePromptAnswer} from "./profilePromptAnswer";
import {PhotoPromptAnswer} from "./photoPromptAnswer";

/**
 * Callable request body for updateUserProfile. Values are normalized before Firestore writes.
 */
export interface UpdateUserProfileCallablePayload {
  fields: {
    name?: string;
    displayName?: string;
    email?: "" | string;
    instagramHandle?: string | null;
    /**
     * @maxItems 3
     */
    profilePrompts?: ProfilePromptAnswer[];
    phoneNumber?: string;
    /**
     * Milliseconds since epoch before conversion to Firestore Timestamp.
     */
    dateOfBirth?: number;
    gender?: "man" | "woman" | "nonBinary" | "other";
    profileComplete?: boolean;
    /**
     * @maxItems 6
     */
    photoUrls?: string[];
    /**
     * @maxItems 6
     */
    photoThumbnailUrls?: string[];
    /**
     * @maxItems 6
     */
    photoPrompts?: PhotoPromptAnswer[];
    /**
     * @maxItems 6
     */
    profilePhotos?: {
      id: string;
      url: string;
      thumbnailUrl: string;
      storagePath: string;
      thumbnailStoragePath: string;
      prompt?: PhotoPromptAnswer | null;
      moderation?: {
        status: "pending" | "approved" | "rejected";
        reason?: string | null;
        reviewedAt?: number | null;
      } | null;
      position: number;
      createdAt: number;
      updatedAt: number;
    }[];
    city?: string | null;
    latitude?: number | null;
    longitude?: number | null;
    /**
     * @minItems 1
     * @maxItems 8
     */
    interestedInGenders?: ("man" | "woman" | "nonBinary" | "other")[];
    minAgePreference?: number;
    maxAgePreference?: number;
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
    paceMinSecsPerKm?: number;
    paceMaxSecsPerKm?: number;
    /**
     * @maxItems 12
     */
    preferredDistances?: ("fiveK" | "tenK" | "halfMarathon" | "marathon")[];
    /**
     * @maxItems 12
     */
    runningReasons?: (
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
    preferredRunTimes?: (
      | "earlyMorning"
      | "morning"
      | "afternoon"
      | "evening"
      | "night"
    )[];
    runPreferencesVersion?: number;
    prefsNewCatches?: boolean;
    prefsMessages?: boolean;
    prefsEventReminders?: boolean;
    prefsRunStatusUpdates?: boolean;
    prefsClubUpdates?: boolean;
    prefsWeeklyDigest?: boolean;
    prefsShowOnMap?: boolean;
  };
}
