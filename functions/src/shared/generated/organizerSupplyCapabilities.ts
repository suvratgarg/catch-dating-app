/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Canonical organizer-level ceiling for member affordances. Event policy may narrow these capabilities but may never widen them.
 */
export type OrganizerSupplyCapabilities = {
  mode: "unclaimed_read_only" | "claimed_managed";
  bookable: boolean;
  paymentsEnabled: boolean;
  waitlistEnabled: boolean;
  hostContactEnabled: boolean;
  claimable: boolean;
  reviewPolicy: "after_event_end" | "attended_event_only";
} & (
  | {
      mode: "unclaimed_read_only";
      bookable: false;
      paymentsEnabled: false;
      waitlistEnabled: false;
      hostContactEnabled: false;
      reviewPolicy: "after_event_end";
      [k: string]: unknown;
    }
  | {
      mode: "claimed_managed";
      bookable: true;
      paymentsEnabled: true;
      waitlistEnabled: true;
      hostContactEnabled: true;
      claimable: false;
      reviewPolicy: "attended_event_only";
      [k: string]: unknown;
    }
);
