/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Applies a bounded action from an anonymous rehearsal guest slot.
 */
export interface SubmitEventRehearsalGuestActionCallablePayload {
  publicRehearsalId: string;
  slotToken: string;
  clientActionId: string;
  action:
    | "checkIn"
    | "confirmArrival"
    | "optOut"
    | "optIn"
    | "askForHelp"
    | "completePrompt";
}
