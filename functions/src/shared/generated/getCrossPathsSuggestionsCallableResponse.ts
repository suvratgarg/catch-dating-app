/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Roster-private Cross Paths suggestions. The response contains only sanitized person and event projections plus a short-lived server-signed token.
 */
export interface GetCrossPathsSuggestionsCallableResponse {
  schemaVersion: 1;
  rankingVersion: 1;
  /**
   * @maxItems 2
   */
  suggestions: {
    person: {
      uid: string;
      name: string;
      age: number;
      gender: "man" | "woman" | "nonBinary" | "other";
      city: string | null;
      /**
       * @minItems 3
       * @maxItems 6
       */
      photoUrls: string[];
      /**
       * @minItems 3
       * @maxItems 3
       */
      promptAnswers: {
        prompt: string;
        answer: string;
      }[];
      relationshipGoal: string;
    };
    event: {
      eventId: string;
      organizerId: string | null;
      startTime: string;
      endTime: string;
      meetingPoint: string;
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
      photoUrl: string | null;
      viewerBookingStatus: "signedUp" | "canBookNow";
      pairHoldAvailable: boolean;
    };
    /**
     * @minItems 4
     * @maxItems 5
     */
    reasonCodes: (
      | "attending_event"
      | "viewer_attending"
      | "booking_available"
      | "mutual_preferences"
      | "showcase_ready"
    )[];
    suggestionToken: string;
    tokenExpiresAt: string;
  }[];
}
