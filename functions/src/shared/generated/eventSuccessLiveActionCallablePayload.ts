/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Revision-fenced live control action accepted by controlEventSuccessLive.
 */
export interface EventSuccessLiveActionCallablePayload {
  eventId: string;
  expectedRevision: number;
  action:
    | "setActiveStep"
    | "startRevealCountdown"
    | "cancelRevealCountdown"
    | "publishReveal"
    | "complete";
  activeStepIndex?: number;
  roundIndex?: number;
  confirmed?: boolean;
  /**
   * Explicit Host acknowledgement that a sweep still has unresolved checked-in attendees.
   */
  accountabilityAcknowledged?: boolean;
}
