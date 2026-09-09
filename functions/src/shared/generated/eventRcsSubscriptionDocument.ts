/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Authenticated RCS subscription observations scoped to a provider agent and recipient endpoint, across events. Stop observations restrict event-service messages; subscribe requests never grant event consent. No automatic retention deletion.
 */
export type EventRcsSubscriptionDocument = (
  | {
      lastStop?: {
        [k: string]: unknown;
      };
      [k: string]: unknown;
    }
  | {
      lastSubscribeRequest?: {
        [k: string]: unknown;
      };
      [k: string]: unknown;
    }
) & {
  schemaVersion: 1;
  subscriptionId: string;
  routeId: "catchEventRcs";
  agentId: string;
  endpointHash: string;
  revision: number;
  lastStop: null | {
    callbackId: string;
    observedAt: number;
  };
  lastSubscribeRequest: null | {
    callbackId: string;
    observedAt: number;
  };
  updatedAt: number;
};
