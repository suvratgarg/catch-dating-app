/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Exact Finance scope for a read-only event-messaging setup and current budget-decision review.
 */
export interface AdminReviewEventMessagingBudgetCallablePayload {
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
}
