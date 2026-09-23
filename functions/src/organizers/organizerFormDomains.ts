/**
 * Domain activation policy for the hosting adapter. Records are inert until a
 * trusted DNS probe and certificate observer supply current evidence.
 * Never route from an unvalidated request Host alone.
 */
export interface OrganizerFormDomain {
  hostname: string;
  organizerId: string;
  formId: string;
  publicFormId: string;
  ownershipChallenge: string;
  expectedCname: string;
  status: "pending" | "verified" | "active" | "revoked";
  certificateStatus: "pending" | "ready" | "failed";
  verifiedAtMillis: number | null;
  generation: number;
}

export interface DomainProbe {
  hostname: string;
  txtValues: readonly string[];
  cnameTarget: string | null;
  checkedAtMillis: number;
}

const MAX_PROBE_AGE_MS = 15 * 60 * 1000;

export function normalizeCustomFormHost(raw: string): string | null {
  // Host headers with ports, paths, userinfo, wildcards, or invalid DNS labels
  // must never select a tenant. Only one exact lowercase ASCII hostname routes.
  const host = raw.toLowerCase();
  if (host.length > 253 || !host.includes(".") || host.endsWith(".") ||
      !/^[a-z0-9.-]+$/u.test(host)) return null;
  const labels = host.split(".");
  if (labels.some((label) => label.length < 1 || label.length > 63 ||
      !/^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$/u.test(label))) return null;
  if (labels.length < 3 || /^\d+$/u.test(labels[labels.length - 1]) ||
      host === "catchdates.com" || host.endsWith(".catchdates.com") ||
      host.endsWith(".firebaseapp.com") || host.endsWith(".web.app") ||
      host.endsWith(".localhost")) return null;
  return host;
}

export function hasCurrentDomainOwnership(
  domain: OrganizerFormDomain,
  probe: DomainProbe | null,
  nowMillis: number
): boolean {
  if (!probe || domain.status === "revoked" ||
      normalizeCustomFormHost(domain.hostname) !== domain.hostname ||
      normalizeCustomFormHost(probe.hostname) !== domain.hostname ||
      !Number.isFinite(nowMillis) || !Number.isFinite(probe.checkedAtMillis) ||
      probe.checkedAtMillis > nowMillis ||
      nowMillis - probe.checkedAtMillis > MAX_PROBE_AGE_MS) return false;
  return probe.txtValues.includes(domain.ownershipChallenge) &&
    probe.cnameTarget?.replace(/\.$/u, "").toLowerCase() === domain.expectedCname;
}

export function verifyFormDomain(
  domain: OrganizerFormDomain,
  probe: DomainProbe,
  nowMillis: number
): OrganizerFormDomain {
  if (domain.status !== "pending" || !hasCurrentDomainOwnership(domain, probe, nowMillis)) {
    throw new Error("Domain ownership or routing is unverified");
  }
  return {...domain, status: "verified", verifiedAtMillis: nowMillis};
}

export function activateFormDomain(
  domain: OrganizerFormDomain,
  probe: DomainProbe,
  nowMillis: number
): OrganizerFormDomain {
  if (domain.status !== "verified" || domain.certificateStatus !== "ready" ||
      !hasCurrentDomainOwnership(domain, probe, nowMillis)) {
    throw new Error("Domain or certificate is not ready");
  }
  return {...domain, status: "active"};
}

export function resolveCustomFormHost(
  requestHost: string,
  domain: OrganizerFormDomain | null,
  probe: DomainProbe | null,
  nowMillis: number,
  expectedOrganizerId?: string
): {organizerId: string; formId: string; publicFormId: string} | null {
  const hostname = normalizeCustomFormHost(requestHost);
  if (!hostname || !domain || domain.hostname !== hostname ||
      domain.status !== "active" || domain.certificateStatus !== "ready" ||
      !domain.verifiedAtMillis ||
      (expectedOrganizerId && domain.organizerId !== expectedOrganizerId) ||
      !hasCurrentDomainOwnership(domain, probe, nowMillis)) return null;
  return {organizerId: domain.organizerId, formId: domain.formId,
    publicFormId: domain.publicFormId};
}

export function revokeFormDomain(domain: OrganizerFormDomain): OrganizerFormDomain {
  return {...domain, status: "revoked", certificateStatus: "pending"};
}
