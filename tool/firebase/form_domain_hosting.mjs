// Firebase Hosting transport for the trusted form-domain operator. This module
// neither authenticates an operator nor grants Catch domain ownership. Its caller
// must verify the configured project/site and registry/DNS binding before apply.
// API: https://firebase.google.com/docs/reference/hosting/rest/v1beta1/projects.sites.customDomains
const api = "https://firebasehosting.googleapis.com/v1beta1/";
const segment = /^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/u;
const object = (value) => value !== null && typeof value === "object" && !Array.isArray(value);

export function hostingDomainTarget({projectId, projectNumber, siteId, hostname}) {
  if (typeof projectId !== "string" || !/^[a-z][a-z0-9-]{4,28}[a-z0-9]$/u.test(projectId) ||
      typeof projectNumber !== "string" || !/^[1-9][0-9]{0,19}$/u.test(projectNumber) ||
      typeof siteId !== "string" || !segment.test(siteId) ||
      typeof hostname !== "string" || hostname.length > 253 ||
      hostname.split(".").length < 3 || !hostname.split(".").every((label) => segment.test(label))) {
    throw new Error("An exact project ID/number, Hosting site and canonical subdomain are required.");
  }
  // Both names refer to the same project only because the caller resolves the
  // numeric identity from the explicitly selected, configured project first.
  const parent = `projects/${projectNumber}/sites/${siteId}`;
  return Object.freeze({projectId, projectNumber, siteId, hostname, parent,
    name: `${parent}/customDomains/${hostname}`,
    projectIdName: `projects/${projectId}/sites/${siteId}/customDomains/${hostname}`});
}

function timestamp(value) {
  if (typeof value !== "string" ||
      !/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,9})?Z$/u.test(value)) return NaN;
  const parsed = Date.parse(value);
  // Date.parse normalizes impossible calendar dates; those are not evidence.
  return Number.isFinite(parsed) && new Date(parsed).toISOString().slice(0, 19) === value.slice(0, 19)
    ? parsed : NaN;
}

function assertClock(now) {
  if (!Number.isSafeInteger(now) || now < 0) throw new Error("Invalid Hosting observation time.");
}

export function evaluateHostingDomain(target, resource, observedAt) {
  target = hostingDomainTarget(target);
  assertClock(observedAt);
  if (resource === null) return {exists: false, ready: false, observedAt,
    name: target.name, blockers: ["hosting-domain-missing"]};
  if (!object(resource) || ![target.name, target.projectIdName].includes(resource.name)) {
    throw new Error("Hosting returned a different or malformed custom-domain resource.");
  }
  if ((resource.reconciling != null && typeof resource.reconciling !== "boolean") ||
      (resource.redirectTarget != null && typeof resource.redirectTarget !== "string") ||
      (resource.issues != null && !Array.isArray(resource.issues)) ||
      (resource.cert != null && !object(resource.cert)) ||
      (resource.cert?.issues != null && !Array.isArray(resource.cert.issues))) {
    throw new Error("Hosting returned malformed custom-domain state.");
  }
  const blockers = [];
  if (resource.deleteTime != null || resource.expireTime != null) blockers.push("hosting-domain-deleted");
  if (resource.redirectTarget) blockers.push("hosting-domain-redirects");
  if (resource.reconciling) blockers.push("hosting-domain-reconciling");
  if (resource.hostState !== "HOST_ACTIVE") blockers.push("hosting-not-active");
  if (resource.ownershipState !== "OWNERSHIP_ACTIVE") blockers.push("hosting-ownership-not-active");
  if (resource.cert?.state !== "CERT_ACTIVE") blockers.push("certificate-not-active");
  const expiresAt = timestamp(resource.cert?.expireTime);
  if (!Number.isFinite(expiresAt) || expiresAt <= observedAt) blockers.push("certificate-expiry-unverified");
  if (resource.issues?.length || resource.cert?.issues?.length) blockers.push("hosting-provider-issues");
  return {exists: true, ready: blockers.length === 0, observedAt,
    name: target.name, blockers, hostState: resource.hostState ?? null,
    ownershipState: resource.ownershipState ?? null,
    certificateState: resource.cert?.state ?? null,
    certificateExpiresAt: Number.isFinite(expiresAt) ? expiresAt : null,
    etag: typeof resource.etag === "string" ? resource.etag : null,
    // These are instructions from Hosting, not fresh Catch TXT/CNAME proof.
    requiredDnsUpdates: resource.requiredDnsUpdates ?? null,
    issues: resource.issues ?? [], certificateIssues: resource.cert?.issues ?? []};
}

function options(method, url, data) {
  return {method, url, ...(data === undefined ? {} : {data}),
    responseType: "json", timeout: 30_000, maxRedirects: 0, retry: false,
    headers: {"Cache-Control": "no-cache"}};
}

function httpStatus(value) {
  const status = value?.response?.status ?? value?.status;
  return Number.isInteger(status) && status >= 100 && status <= 599 ? status : null;
}

async function requestResult(request, config) {
  try {
    const response = await request(config);
    return {status: httpStatus(response), data: response?.data};
  } catch (error) {
    // Do not expose authenticated request options, tokens or raw provider errors.
    return {status: httpStatus(error)};
  }
}

export async function readHostingDomain(target, {request, now = Date.now}) {
  target = hostingDomainTarget(target);
  const result = await requestResult(request, options("GET", `${api}${target.name}`));
  if (result.status === 404) return evaluateHostingDomain(target, null, now());
  if (result.status !== 200) throw new Error(
    `Hosting read failed (${result.status === null ? "transport or invalid response" : `HTTP ${result.status}`}).`
  );
  if (!object(result.data)) throw new Error("Hosting returned malformed custom-domain state.");
  return evaluateHostingDomain(target, result.data, now());
}

export async function provisionHostingDomain(target, {request, now = Date.now, apply = false}) {
  target = hostingDomainTarget(target);
  if (typeof apply !== "boolean") throw new Error("Hosting apply must be explicitly boolean.");
  const before = await readHostingDomain(target, {request, now});
  if (before.exists || !apply) return {action: before.exists ? "none" : "create-required", state: before};
  // A deterministic customDomainId makes retries converge on the same resource.
  // Never patch, redirect, delete or undelete an existing domain automatically.
  const url = `${api}${target.parent}/customDomains?customDomainId=${encodeURIComponent(target.hostname)}`;
  const result = await requestResult(request, options("POST", url, {}));
  if ([400, 401, 403, 404, 422].includes(result.status)) {
    throw new Error(`Hosting create rejected (HTTP ${result.status}).`);
  }
  // create returns a long-running Operation, never activation evidence. Even
  // success/done:true must be followed by an exact resource read. A timeout or
  // conflict might have created it; do not issue a second POST in this attempt.
  const outcome = result.status >= 200 && result.status < 300 ? "requested" : "unknown";
  try {
    return {action: "create", outcome, state: await readHostingDomain(target, {request, now})};
  } catch {
    return {action: "create", outcome, state: null, nextAction: "read-status"};
  }
}
