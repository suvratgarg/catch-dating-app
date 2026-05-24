/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import {ProfilePromptAnswer} from "./profilePromptAnswer";
import {PhotoPromptAnswer} from "./photoPromptAnswer";
import {ProfilePhoto} from "./profilePhoto";

/**
 * Backend-owned public profile projection stored at publicProfiles/{uid}. The uid is the document id and is not stored in document data.
 */
export interface PublicProfileDocument {
  name: string;
  age: number;
  gender: "man" | "woman" | "nonBinary" | "other";
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
  /**
   * @maxItems 3
   */
  profilePrompts: ProfilePromptAnswer[];
  /**
   * @maxItems 6
   */
  photoUrls: string[];
  /**
   * @maxItems 6
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
  runPreferencesVersion: number;
}
