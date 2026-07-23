/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Version 1 JSON response returned by the member waitlist and Host operating-application endpoint.
 */
export type JoinWaitlistHTTPResponse =
  | {
      ok: true;
      alreadyJoined: boolean;
    }
  | {
      error: string;
    };
