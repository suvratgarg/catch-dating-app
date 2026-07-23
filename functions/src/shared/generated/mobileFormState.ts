/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Schema-owned values used by installable-app forms when the editable presentation value is derived into one or more backend payload fields rather than written verbatim.
 */
export interface MobileFormState {
  /**
   * Create/edit event duration. Save adapters derive endTimeMillis from this value and startTimeMillis.
   */
  eventDurationMinutes?: number;
  /**
   * Whether the event form reveals and emits cohort capacity limits.
   */
  eventCohortCapsEnabled?: boolean;
  /**
   * Whether the event form reveals and emits demand-pricing rules.
   */
  eventDynamicPricingEnabled?: boolean;
  /**
   * Whether a host includes an optional live event-success card.
   */
  eventSuccessLiveCardIncluded?: boolean;
  eventSuccessManualQaScenario?:
    | "socialRun"
    | "racketPairs"
    | "quizTeams"
    | "singlesMixer";
  exploreActivityTag?: string;
  exploreArea?: string;
  exploreDistanceFilter?: "any" | "oneKm" | "threeKm" | "fiveKm" | "tenKm";
  exploreHighRatedOnly?: boolean;
  exploreJoinedOnly?: boolean;
  hostBroadcastTemplate?: "reminder" | "meetingPoint" | "change";
  hostEventsLifecycleFilter?: "upcoming" | "live" | "past";
  hostInboxAudienceSegment?: "booked" | "prospective";
  hostRosterFilter?:
    | "all"
    | "booked"
    | "waitlist"
    | "slots"
    | "requests"
    | "due"
    | "checkedIn"
    | "attended"
    | "noShow";
  /**
   * Read-only date text rendered by the onboarding date picker before it is saved as a timestamp.
   */
  onboardingDateOfBirthText?: string;
  /**
   * Phone identifier used by the local Suvbot tester action.
   */
  suvbotTesterPhoneNumber?: string;
}
