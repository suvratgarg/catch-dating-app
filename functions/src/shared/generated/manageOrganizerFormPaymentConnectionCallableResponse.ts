/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Safe connection status and one-use OAuth link. No merchant credentials.
 */
export interface ManageOrganizerFormPaymentConnectionCallableResponse {
  available: boolean;
  authorizationUrl: string | null;
  connectionId: string | null;
  expiresAtMillis: number | null;
  /**
   * @maxItems 100
   */
  connections: {
    connectionId: string;
    status: "connecting" | "ready" | "needsAttention" | "disconnected";
    mode: "test" | "live";
    accountId: string | null;
    webhookVerified: boolean;
    lastErrorCode: string | null;
  }[];
  /**
   * Selected server-owned collection route. Null preserves legacy OAuth account selection.
   */
  collection?: null | {
    route:
      | "disabled"
      | "razorpayRoute"
      | "razorpayOAuth"
      | "stripeConnectDirect"
      | "stripeConnectDestination";
    mode: "test" | "live" | null;
    ready: boolean;
  };
}
