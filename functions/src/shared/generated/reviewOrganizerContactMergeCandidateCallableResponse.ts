/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ReviewOrganizerContactMergeCandidateCallableResponse {
  organizerId: string;
  candidateId: string;
  decisionState: "differentPeople" | "reopened";
  revision: number;
}
