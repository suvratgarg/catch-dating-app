import * as admin from "firebase-admin";
import {defineString} from "firebase-functions/params";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from
  "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {requireOrganizerManager} from
  "../shared/organizerManagerAuthority";
import {normalizeCustomFormHost, parseOrganizerFormDomain} from
  "./organizerFormDomains";
import {
  probeFormDomain, reserveOrganizerFormDomain,
  revokeOrganizerFormDomain, verifyOrganizerFormDomain,
} from "./organizerFormDomainRegistry";

// Deployment configuration, never a client-controlled CNAME target. An empty
// value keeps reservations disabled until the hosting operator configures it.
const hostingTarget = defineString("FORM_DOMAIN_CNAME_TARGET", {default: ""});

type DomainAction = "reserve" | "verify" | "revoke";
interface DomainRequest {
  action: DomainAction;
  hostname: string;
  organizerId: string;
  formId?: string;
}

export function parseDomainRequest(value: unknown): DomainRequest {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new HttpsError("invalid-argument", "Invalid domain request.");
  }
  const data = value as Record<string, unknown>;
  const action = data.action;
  const allowed = action === "reserve" ?
    ["action", "hostname", "organizerId", "formId"] :
    ["action", "hostname", "organizerId"];
  if (!(["reserve", "verify", "revoke"] as unknown[]).includes(action) ||
      Object.keys(data).some((key) => !allowed.includes(key)) ||
      typeof data.hostname !== "string" ||
      normalizeCustomFormHost(data.hostname) !== data.hostname ||
      typeof data.organizerId !== "string" || !data.organizerId ||
      (action === "reserve" ?
        typeof data.formId !== "string" || !data.formId :
        data.formId !== undefined)) {
    throw new HttpsError("invalid-argument", "Invalid domain request.");
  }
  return data as unknown as DomainRequest;
}

/** Manager ownership operations. Certificate readiness stays operator-only. */
export async function manageOrganizerFormDomainHandler(
  request: CallableRequest<unknown>
): Promise<{hostname: string; status: string; ownershipChallenge?: string;
  expectedCname?: string}> {
  const actorUid = requireAuth(request);
  const input = parseDomainRequest(request.data);
  const db = admin.firestore();
  await checkRateLimit(db, actorUid, "manageOrganizerFormDomain");
  await requireOrganizerManager({db, organizerId: input.organizerId, actorUid});
  if (input.action === "revoke") {
    await revokeOrganizerFormDomain(db, input.hostname, input.organizerId,
      actorUid);
    return {hostname: input.hostname, status: "revoked"};
  }
  if (input.action === "reserve") {
    const record = await reserveOrganizerFormDomain(db, {
      hostname: input.hostname, organizerId: input.organizerId,
      formId: input.formId!, actorUid,
    }, Date.now(), hostingTarget.value());
    return {hostname: record.hostname, status: record.status,
      ownershipChallenge: record.ownershipChallenge,
      expectedCname: record.expectedCname};
  }
  const current = parseOrganizerFormDomain((await db.collection(
    "organizerFormDomains").doc(input.hostname).get()).data());
  if (!current || current.organizerId !== input.organizerId ||
      current.status !== "pending") {
    throw new HttpsError("failed-precondition", "Domain is not pending.");
  }
  const probe = await probeFormDomain(input.hostname);
  const record = await verifyOrganizerFormDomain(db, input.hostname,
    probe, Date.now(), input.organizerId);
  return {hostname: record.hostname, status: record.status};
}

export const manageOrganizerFormDomain = onCall(
  appCheckCallableOptionsWithLimits({maxInstances: 10, timeoutSeconds: 30}),
  (request) => manageOrganizerFormDomainHandler(request)
);
