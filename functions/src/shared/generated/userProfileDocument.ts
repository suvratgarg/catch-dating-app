/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

import {ProfilePromptAnswer} from "./profilePromptAnswer";
import {PhotoPromptAnswer} from "./photoPromptAnswer";
import {ProfilePhoto} from "./profilePhoto";

/**
 * Canonical private profile document stored at users/{uid}. The uid is the document id and is not stored in document data.
 */
export interface UserProfileDocument {
  name: string;
  firstName: string;
  lastName: string;
  displayName: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  dateOfBirth: {
    _seconds: number;
    _nanoseconds: number;
  };
  gender: "man" | "woman" | "nonBinary" | "other";
  phoneNumber: string;
  profileComplete: boolean;
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
  email: "" | string;
  instagramHandle?: string | null;
  /**
   * @maxItems 3
   */
  profilePrompts: ProfilePromptAnswer[];
  /**
   * @maxItems 12
   */
  photoUrls: string[];
  /**
   * @maxItems 12
   */
  photoThumbnailUrls: string[];
  /**
   * @maxItems 6
   */
  photoPrompts: PhotoPromptAnswer[];
  /**
   * @maxItems 6
   */
  profilePhotos?: ProfilePhoto[];
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
  prefsNewCatches: boolean;
  prefsMessages: boolean;
  prefsRunReminders: boolean;
  prefsRunStatusUpdates: boolean;
  prefsClubUpdates: boolean;
  prefsWeeklyDigest: boolean;
  prefsShowOnMap: boolean;
  fcmToken?: string;
  deleted?: boolean;
  deletedAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
