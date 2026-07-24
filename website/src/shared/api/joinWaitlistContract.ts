import type {JoinWaitlistHTTPRequest} from
  "../contracts/generated/joinWaitlistHttpRequest";
import type {JoinWaitlistHTTPResponse} from
  "../contracts/generated/joinWaitlistHttpResponse";
import {
  joinWaitlistRequestSchema,
  joinWaitlistResponseSchema,
} from "../contracts/generated/joinWaitlistSchemas";
import {matchesJsonSchema} from "../contracts/jsonSchema";

export type {
  JoinWaitlistHTTPRequest,
  JoinWaitlistHTTPResponse,
};

export function isJoinWaitlistHttpRequest(
  value: unknown
): value is JoinWaitlistHTTPRequest {
  return matchesJsonSchema(value, joinWaitlistRequestSchema);
}

export function parseJoinWaitlistHttpResponse(
  value: unknown
): JoinWaitlistHTTPResponse {
  if (!matchesJsonSchema(value, joinWaitlistResponseSchema)) {
    throw new Error(
      "Catch returned an unexpected waitlist response. Please try again."
    );
  }
  return value as JoinWaitlistHTTPResponse;
}
