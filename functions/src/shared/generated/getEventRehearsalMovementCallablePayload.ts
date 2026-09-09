/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface GetEventRehearsalMovementCallablePayload {
  sessionId: string;
  expectedSetupRevision: number;
  scope: {
    groupId: string;
    progressRevision?: number;
    beforeRevision?: number;
  };
}
