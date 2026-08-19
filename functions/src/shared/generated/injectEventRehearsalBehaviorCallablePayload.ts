/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Applies a deterministic synthetic-actor behavior or an internal-only fault.
 */
export interface InjectEventRehearsalBehaviorCallablePayload {
  sessionId: string;
  expectedRevision: number;
  clientActionId: string;
  actorId: string | null;
  behavior:
    | "arrive"
    | "arriveLate"
    | "markNoShow"
    | "leaveEarly"
    | "return"
    | "walkIn"
    | "ambiguousClaim"
    | "resolveClaim"
    | "optOut"
    | "optIn"
    | "keepApart"
    | "disconnect"
    | "reconnect"
    | null;
  faultId:
    | "none"
    | "latency"
    | "oneShotFailure"
    | "listenerDisconnect"
    | "staleRevision"
    | "duplicateDelivery"
    | "legacyFixture"
    | "reducedMotion"
    | "lowBandwidth";
}
