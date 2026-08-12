/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned, expiring least-privilege access to one event's operational roster. It never grants organizer, CRM, provider, campaign, analytics, or event-edit authority.
 */
export interface EventStaffGrantDocument {
  organizerId: string;
  eventId: string;
  uid: string;
  displayName: string;
  phoneLastFour: string;
  role: "checkInOperator";
  /**
   * @minItems 3
   * @maxItems 3
   */
  permissions: ("viewRoster" | "setAttendance" | "reviewRuntimeClaims")[];
  status: "active" | "revoked";
  createdBy: string;
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
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  revokedBy: string | null;
  revokedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  revision: number;
}
