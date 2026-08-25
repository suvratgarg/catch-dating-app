/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type PublishEventLivePositionCallablePayload = {
  [k: string]: unknown;
} & {
  eventId: string;
  sharing: boolean;
  latitude: number | null;
  longitude: number | null;
  accuracyMeters: number | null;
  headingDegrees: number | null;
};
