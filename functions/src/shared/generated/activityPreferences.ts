/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

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
