/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Sanitized anonymous guest projection for a rehearsal.
 */
export interface EventRehearsalGuestBootstrapCallableResponse {
  slotToken: string;
  practiceBanner: string;
  session: {
    title: string;
    locationName: string;
    status: "draft" | "ready" | "running" | "paused" | "complete" | "expired";
    activeStepIndex: number;
    virtualNowMillis: number;
    attendeePrompt: string;
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
    runtimeRevision: number;
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
  };
  actor: {
    actorId: string;
    displayName: string;
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
    helpRequested: boolean;
    promptCompleted: boolean;
  };
}
