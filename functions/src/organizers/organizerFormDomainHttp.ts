import * as admin from "firebase-admin";
import {onRequest} from "firebase-functions/v2/https";
import {normalizeCustomFormHost} from "./organizerFormDomains";
import {checkIpRateLimit} from "../shared/rateLimit";
import {
  probeFormDomain, resolveOrganizerFormDomain,
} from "./organizerFormDomainRegistry";

/**
 * A hostname parameter is an untrusted lookup key, never tenant authority.
 * This endpoint discloses only the public ID of an active, DNS-verified form.
 * The website must compare the echoed hostname to window.location.hostname.
 */
export async function resolvePublicFormDomainRequest(
  method: string,
  requestedHost: unknown,
  resolve: (hostname: string) => Promise<string | null>
): Promise<{status: number; body: {hostname?: string;
  publicFormId?: string; error?: string}}> {
  if (method !== "GET") {
    return {status: 405, body: {error: "Method not allowed"}};
  }
  if (typeof requestedHost !== "string" ||
      normalizeCustomFormHost(requestedHost) !== requestedHost) {
    return {status: 404, body: {error: "Form unavailable"}};
  }
  const publicFormId = await resolve(requestedHost);
  if (!publicFormId) return {status: 404, body: {error: "Form unavailable"}};
  return {status: 200, body: {hostname: requestedHost, publicFormId}};
}

export const resolvePublicFormDomain = onRequest(
  {region: "asia-south1", maxInstances: 10, timeoutSeconds: 15,
    cors: false, invoker: "public"},
  async (request, response) => {
    response.set("Cache-Control", "no-store");
    response.set("X-Content-Type-Options", "nosniff");
    response.set("X-Robots-Tag", "noindex, nofollow");
    if (!checkIpRateLimit(request.ip ?? "unknown", 60, 60 * 1000)) {
      response.status(429).json({error: "Try again later"});
      return;
    }
    try {
      const result = await resolvePublicFormDomainRequest(
        request.method, request.query.hostname,
        async (hostname) => {
          const resolved = await resolveOrganizerFormDomain(
            admin.firestore(), hostname, () => probeFormDomain(hostname),
            Date.now);
          return resolved?.publicFormId ?? null;
        }
      );
      response.status(result.status).json(result.body);
    } catch {
      response.status(503).json({error: "Form unavailable"});
    }
  }
);
