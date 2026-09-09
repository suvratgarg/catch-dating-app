/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceGroupStaffCallableResponse {
  outcome: "read" | "applied" | "replayed";
  operationRevision: number | null;
  view: {
    context: {
      mode: "live";
      eventId: string;
      organizerId: string;
    };
    groupId: string;
    sourceHash: string;
    serverTime: number;
    uid: string;
    displayName: string;
    phoneLastFour: string;
    revision: number;
    status: "none" | "assigned" | "expired" | "revoked" | "sourceChanged";
    duty: {
      groupId: string;
      duty: "lead" | "pacer" | "sweep";
      expiresAtMillis: number;
      sourceHash: string;
      grantedBy: string;
      grantedAtMillis: number;
    } | null;
    operatorExpiresAtMillis: number | null;
    canAssign: boolean;
    /**
     * @maxItems 3
     */
    availableDuties: ("lead" | "pacer" | "sweep")[];
  };
}
