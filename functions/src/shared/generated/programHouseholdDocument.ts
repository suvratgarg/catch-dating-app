/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned household/party grouping for program guests. Carries the invited party's primary contact and delivery preference; member guest ids are bounded.
 */
export interface ProgramHouseholdDocument {
  programId: string;
  organizerId: string;
  /**
   * Human label such as 'The Sharma family' used on invitations and rosters.
   */
  label: string;
  primaryContactName: string;
  primaryPhoneE164: string | null;
  primaryEmail: string | null;
  /**
   * @minItems 1
   * @maxItems 50
   */
  memberGuestIds: string[];
  /**
   * Invitation delivery preference; does not grant messaging consent by itself.
   */
  deliveryPreference: "whatsapp" | "sms" | "email" | "none";
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  revision: number;
}
