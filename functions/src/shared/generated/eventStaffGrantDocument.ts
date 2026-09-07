/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned, expiring event staff access. Event-wide operator permissions and group duties have independent expiry and authority; neither grants organizer or CRM access.
 */
export interface EventStaffGrantDocument {
  organizerId: string;
  eventId: string;
  uid: string;
  displayName: string;
  phoneLastFour: string;
  role: "checkInOperator" | "eventOperator";
  /**
   * @minItems 0
   * @maxItems 4
   */
  permissions: (
    | "viewRoster"
    | "setAttendance"
    | "reviewRuntimeClaims"
    | "publishLiveLocation"
  )[];
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
   * Latest expiry across event-wide permissions and group duties, for staff discovery and capacity. Each authority boundary checks its own expiry.
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
  /**
   * Independent event-wide permission expiry. Missing legacy values use expiresAt; null grants no event-wide permissions.
   */
  operatorExpiresAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * At most one independently expiring duty per configured event/group. No implied event-wide roster or check-in permission.
   *
   * @maxItems 20
   */
  groupDuties?: {
    groupId: string;
    duty: "lead" | "pacer" | "sweep";
    expiresAtMillis: number;
    sourceHash: string;
    grantedBy: string;
    grantedAtMillis: number;
  }[];
}
