/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Finance review decision for proposed event-messaging ceilings. The callable records evidence only and does not create, update, or activate a spending budget.
 */
export interface AdminDecideEventMessagingBudgetCallablePayload {
  requestId: string;
  organizerId: string;
  eventId: string;
  routeId: "catchEventSms" | "catchEventRcs" | "organizerEventWhatsapp";
  senderId: string;
  purpose:
    | "joiningUpdate"
    | "joiningInstructions"
    | "planChanged"
    | "eventCancelled"
    | "eventFinished"
    | "guestRequirement"
    | "assignmentChanged"
    | "participationCheck"
    | "followUp";
  expectedRevision: number;
  expectedRuntimeSourceHash: string;
  expectedSenderReviewHash: string;
  expectedBudgetSourceHash: string;
  decision:
    | {
        kind: "approve";
        currency: string;
        eventLimitMicros: number;
        senderDayLimitMicros: number;
        validUntil: number;
      }
    | {
        kind: "hold";
      }
    | {
        kind: "reject";
      };
  note: string;
}
