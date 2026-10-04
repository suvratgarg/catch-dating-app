/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface SalesPartnerAssignmentDocument {
  schemaVersion: 1;
  classification: "sales_private";
  revision: number;
  updatedAt: string;
  organizerId: string;
  partnerUid: string;
  status: "offered" | "accepted" | "declined" | "revoked";
  originatorUid: string | null;
  introducingSenderUid: string | null;
  catchOwnerUid: string;
  activationOwnerUid: string | null;
  relationshipContext: string | null;
  relationshipConfirmedAt: string | null;
  channel: ("email" | "whatsapp" | "other") | null;
  nextAction: string;
  reviewAt: string;
  expiresAt: string;
  assignedAt: string;
  reason: string;
}
