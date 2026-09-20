/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Applies a bounded action from an anonymous rehearsal guest slot.
 */
export type SubmitEventRehearsalGuestActionCallablePayload = {
  [k: string]: unknown;
} & {
  publicRehearsalId: string;
  slotToken: string;
  clientActionId: string;
  action:
    | "checkIn"
    | "confirmArrival"
    | "optOut"
    | "optIn"
    | "askForHelp"
    | "completePrompt"
    | "submitRequiredData"
    | "respondToAssistance";
  messageId?: string;
  intentRevision?: number;
  choiceId?: string;
  requiredData?: {
    /**
     * @minItems 1
     * @maxItems 10
     */
    fieldIds: (
      | "displayName"
      | "gender"
      | "interestedInGenders"
      | "relationshipGoal"
      | "dateOfBirth"
      | "paceBand"
      | "skillBand"
      | "dietaryAndSeatingNotes"
      | "questionnaireAnswerIds"
      | "teamName"
    )[];
    expectedProfileRevision: number;
    expectedRequestRevision: number;
    expectedSourceHash: string;
  };
};
