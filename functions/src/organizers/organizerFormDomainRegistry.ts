import {randomBytes} from "node:crypto";
import {resolveCname, resolveTxt} from "node:dns/promises";
import type {firestore} from "firebase-admin";
import {requireOrganizerManager} from "../shared/organizerManagerAuthority";
import {
  activateFormDomain, hasCurrentDomainOwnership, normalizeCustomFormHost,
  normalizeHostingTarget, parseOrganizerFormDomain, resolveCustomFormHost,
  revokeFormDomain, verifyFormDomain,
  type DomainProbe, type OrganizerFormDomain,
} from "./organizerFormDomains";

const COLLECTION = "organizerFormDomains";

function requireHostname(hostname: string): string {
  const normalized = normalizeCustomFormHost(hostname);
  if (!normalized || normalized !== hostname) {
    throw new Error("Invalid custom hostname");
  }
  return hostname;
}

/** Probe failures return no evidence. DNS is checked against the record. */
export async function probeFormDomain(
  hostname: string
): Promise<DomainProbe | null> {
  if (!normalizeCustomFormHost(hostname)) return null;
  try {
    const [txt, cname] = await Promise.all([
      resolveTxt(`_catch-verify.${hostname}`), resolveCname(hostname),
    ]);
    return {
      hostname, txtValues: txt.map((parts) => parts.join("")),
      cnameTarget: cname.length === 1 ? cname[0] : null,
      checkedAtMillis: Date.now(),
    };
  } catch {
    return null;
  }
}

export async function reserveOrganizerFormDomain(
  db: firestore.Firestore,
  input: {hostname: string; organizerId: string; formId: string;
    actorUid: string},
  nowMillis: number,
  trustedHostingTarget: string,
  assertManager: typeof requireOrganizerManager = requireOrganizerManager
): Promise<OrganizerFormDomain> {
  const hostname = requireHostname(input.hostname);
  const expectedCname = normalizeHostingTarget(trustedHostingTarget);
  if (!expectedCname ||
      !Number.isFinite(nowMillis)) throw new Error("Invalid hosting target");
  await assertManager({db, organizerId: input.organizerId,
    actorUid: input.actorUid});
  const domainRef = db.collection(COLLECTION).doc(hostname);
  const formRef = db.collection("organizerForms").doc(input.formId);
  return db.runTransaction(async (tx) => {
    const [existing, form] = await Promise.all([
      tx.get(domainRef), tx.get(formRef),
    ]);
    if (!form.exists || form.get("organizerId") !== input.organizerId ||
        form.get("status") !== "published" ||
        typeof form.get("publicFormId") !== "string") {
      throw new Error("Published form ownership is required");
    }
    const previous = existing.exists ?
      parseOrganizerFormDomain(existing.data()) : null;
    if (existing.exists && !previous) throw new Error("Invalid domain record");
    if (previous && previous.status !== "revoked") {
      throw new Error("Hostname is already reserved");
    }
    // A revoked hostname can be reassigned only with a fresh challenge and DNS
    // proof. The old binding cannot be reactivated.
    const record: OrganizerFormDomain = {
      hostname, organizerId: input.organizerId, formId: input.formId,
      publicFormId: form.get("publicFormId") as string,
      ownershipChallenge: `catch-verification=${
        randomBytes(24).toString("base64url")}`,
      expectedCname, status: "pending",
      certificateStatus: "pending", verifiedAtMillis: null,
      generation: (previous?.generation ?? 0) + 1,
    };
    tx.set(domainRef, record);
    return record;
  });
}

/** Trusted backend operation. Never accepts browser-supplied TXT. */
export async function verifyOrganizerFormDomain(
  db: firestore.Firestore, hostname: string, probe: DomainProbe | null,
  nowMillis: number
): Promise<OrganizerFormDomain> {
  requireHostname(hostname);
  return db.runTransaction(async (tx) => {
    const ref = db.collection(COLLECTION).doc(hostname);
    const snap = await tx.get(ref);
    if (!snap.exists || !probe) {
      throw new Error("Domain is not reserved or DNS is unavailable");
    }
    const record = parseOrganizerFormDomain(snap.data());
    if (!record) throw new Error("Invalid domain record");
    const verified = verifyFormDomain(record, probe,
      nowMillis);
    tx.set(ref, verified);
    return verified;
  });
}

/** Certificate status must be supplied by the trusted hosting operator. */
export async function markOrganizerFormCertificateReady(
  db: firestore.Firestore, hostname: string, generation: number
): Promise<void> {
  requireHostname(hostname);
  await db.runTransaction(async (tx) => {
    const ref = db.collection(COLLECTION).doc(hostname);
    const snap = await tx.get(ref);
    const record = parseOrganizerFormDomain(snap.data());
    if (!record || record.status !== "verified" ||
        record.generation !== generation) {
      throw new Error("Domain verification changed");
    }
    tx.update(ref, {certificateStatus: "ready"});
  });
}

export async function activateOrganizerFormDomain(
  db: firestore.Firestore, hostname: string, probe: DomainProbe | null,
  nowMillis: number
): Promise<OrganizerFormDomain> {
  requireHostname(hostname);
  return db.runTransaction(async (tx) => {
    const ref = db.collection(COLLECTION).doc(hostname);
    const snap = await tx.get(ref);
    if (!snap.exists || !probe) throw new Error("Domain or DNS is unavailable");
    const record = parseOrganizerFormDomain(snap.data());
    if (!record) throw new Error("Invalid domain record");
    const active = activateFormDomain(record,
      probe, nowMillis);
    tx.set(ref, active);
    return active;
  });
}

export async function revokeOrganizerFormDomain(
  db: firestore.Firestore, hostname: string, organizerId: string,
  actorUid: string,
  assertManager: typeof requireOrganizerManager = requireOrganizerManager
): Promise<void> {
  requireHostname(hostname);
  await assertManager({db, organizerId, actorUid});
  await db.runTransaction(async (tx) => {
    const ref = db.collection(COLLECTION).doc(hostname);
    const snap = await tx.get(ref);
    const record = parseOrganizerFormDomain(snap.data());
    if (!record || record.organizerId !== organizerId) {
      throw new Error("Domain is not owned by this organizer");
    }
    tx.set(ref, revokeFormDomain(record));
  });
}

/** Exact host, current DNS, and current form ownership all have to agree. */
export async function resolveOrganizerFormDomain(
  db: firestore.Firestore, requestHost: string, probe: DomainProbe | null,
  nowMillis: number
): Promise<{organizerId: string; publicFormId: string} | null> {
  const hostname = normalizeCustomFormHost(requestHost);
  if (!hostname) return null;
  const domainSnap = await db.collection(COLLECTION).doc(hostname).get();
  const record = parseOrganizerFormDomain(domainSnap.data());
  if (!record || !hasCurrentDomainOwnership(record, probe, nowMillis)) {
    return null;
  }
  const resolved = resolveCustomFormHost(hostname, record, probe, nowMillis);
  if (!resolved) return null;
  const formSnap = await db.collection("organizerForms")
    .doc(resolved.formId).get();
  if (!formSnap.exists ||
      formSnap.get("organizerId") !== resolved.organizerId ||
      formSnap.get("publicFormId") !== resolved.publicFormId ||
      formSnap.get("status") !== "published") return null;
  return {organizerId: resolved.organizerId,
    publicFormId: resolved.publicFormId};
}
