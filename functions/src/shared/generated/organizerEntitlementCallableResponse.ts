/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Bounded manager-facing entitlement projection: grants without admin internals, metered usage, and the versioned SKU catalog so clients render limits and prices without a second fetch.
 */
export interface OrganizerEntitlementCallableResponse {
  schemaVersion: 1;
  organizerId: string;
  catalogVersion: number;
  revision: number;
  /**
   * @maxItems 50
   */
  grants: {
    grantId: string;
    sku:
      | "wedding_essentials"
      | "wedding_pro"
      | "wedding_signature"
      | "wedding_transport_addon"
      | "planner_annual";
    skuLabel: string;
    unit: "program" | "organizerYear";
    quantityTotal: number;
    quantityConsumed: number;
    quantityRemaining: number;
    validFromMillis: number;
    validUntilMillis: number | null;
    source: "manualInvoice" | "checkout" | "promo";
    active: boolean;
    revoked: boolean;
  }[];
  meters: {
    flightDaysUsed: number;
    waConversationsUsed: number;
  };
  skuCatalog: {
    /**
     * This interface was referenced by `undefined`'s JSON-Schema definition
     * via the `patternProperty` "^(wedding_essentials|wedding_pro|wedding_signature|wedding_transport_addon|planner_annual)$".
     */
    [k: string]: {
      label: string;
      unit: "program" | "organizerYear";
      priceMinor: number | null;
      currency: "INR";
      limits: {
        guests: number | null;
        functions: number | null;
        staffAssignments: number | null;
        momentsPerFunction: number | null;
      };
      /**
       * @maxItems 4
       */
      capabilitiesAllowed: (
        | "arrivalsTransport"
        | "accommodation"
        | "forms"
        | "messaging"
      )[];
      includedFlightDays: number;
      includedWaConversations: number;
      stakeholderSeats: number | null;
    };
  };
}
