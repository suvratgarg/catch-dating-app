/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned household invitation grouping for program guests. Carries the invited party's primary contact and delivery preference; member guest ids are bounded.
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
   * @minItems 0
   * @maxItems 50
   */
  memberGuestIds: string[];
  /**
   * Invitation delivery preference; does not grant messaging consent by itself.
   */
  deliveryPreference: "whatsapp" | "sms" | "email" | "none";
  /**
   * Optional side assignment used for per-side counts and seating; labels are configured on the program.
   */
  side?: ("partnerA" | "partnerB" | "mutual") | null;
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
  /**
   * Explicit household messaging consent. Absent means never asked; granted:true only ever follows an explicit tick — RSVP acceptance alone is not consent.
   */
  messagingConsent?: {
    granted: boolean;
    grantedAt: {
      _seconds: number;
      _nanoseconds: number;
    } | null;
    /**
     * Channel that recorded the consent decision; whatsappStop is an inbound STOP reply captured by the messaging webhook.
     */
    source: "householdRsvpLink" | "staff" | "import" | "whatsappStop" | null;
  } | null;
}
