/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable booking and roster provenance for one operational event.
 */
export interface EventOrigin {
  mode: "catchNative" | "externalCompanion";
  bookingAuthority: "catch" | "external";
  rosterAuthority: "catchProjection" | "hostImport" | "providerSync";
  provider:
    | "catch"
    | "generic"
    | "luma"
    | "eventbrite"
    | "partiful"
    | "posh"
    | "bookmyshow"
    | "district"
    | "sortmyscene"
    | "airbnb";
  externalEventId: string | null;
  externalEventUrl: string | null;
  sourceExternalEventId: string | null;
  adapterVersion: string | null;
  connectedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  connectedBy: string | null;
}
