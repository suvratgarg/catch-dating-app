import {FieldValue, Timestamp, type Firestore} from
  "firebase-admin/firestore";
import {validateHostAcquisitionConsentDocument} from
  "../shared/generated/validators/hostAcquisitionConsentDocument";
import {hasCurrentHostConsent, HOST_ATTRIBUTION_LIFETIME_MS} from
  "./consentPolicy";
import {HOST_CONSENT_COLLECTION} from "./consentStore";

// These are reviewed campaign labels, never arbitrary URL/query values.
export const hostCampaignLabels: Record<string, readonly string[]> = {
  utm_source: ["google", "meta", "newsletter", "catch", "partner"],
  utm_medium: ["cpc", "paid_social", "email", "organic", "referral"],
  utm_campaign: ["launch", "launch_2026", "planner_launch",
    "host_acquisition_2026", "synthetic_launch"],
  utm_content: ["host_hero", "host_footer", "claim_cta", "application_cta"],
};
const paths = new Set(["/host/", "/host/overview/", "/host/platform/",
  "/host/planners/", "/host/clubs/", "/host/directory/", "/claim/",
  "/host/claim/", "/host/apply/", "/host/stack/", "/host/workflows/"]);
interface Touch {
  capturedAt: number; landingPath: string; values: Record<string, string>;
}
export interface HostAttributionSnapshot {
  version: 1; consentId: string; acceptedAt: number; expiresAt: number;
  firstTouch: Touch | null; lastTouch: Touch | null;
}
const object = (value: unknown): Record<string, unknown> | null =>
  value && typeof value === "object" && !Array.isArray(value) ?
    value as Record<string, unknown> : null;

function touch(value: unknown, chosenAt: number, acceptedAt: number):
Touch | null {
  const raw = object(value);
  if (!raw || typeof raw.capturedAt !== "string" ||
      typeof raw.landingPath !== "string") return null;
  const capturedAt = Date.parse(raw.capturedAt);
  if (!Number.isSafeInteger(capturedAt) || capturedAt <= 0 ||
      new Date(capturedAt).toISOString() !== raw.capturedAt ||
      capturedAt < chosenAt || capturedAt > acceptedAt ||
      acceptedAt - capturedAt >= HOST_ATTRIBUTION_LIFETIME_MS) return null;
  const landingPath = raw.landingPath.endsWith("/") ? raw.landingPath :
    `${raw.landingPath}/`;
  if (!paths.has(landingPath)) return null;
  const values: Record<string, string> = {};
  const submitted = object(raw.values) ?? {};
  for (const [key, allowed] of Object.entries(hostCampaignLabels)) {
    const value = submitted[key];
    if (typeof value === "string" && allowed.includes(value)) {
      values[key] = value;
    }
  }
  // An unlabelled visit is unassigned, not an inferred organic campaign.
  if (!Object.keys(values).length) return null;
  return {capturedAt, landingPath, values};
}

/** Called only in the accepting transaction with its current consent read.
 * No raw URLs, referrers, click IDs, contact details or capability survive.
 * The snapshot expires with the original choice, never a retry/submission. */
export function prepareHostAttribution(input: {
  enabled: boolean; isNew: boolean; eventId: string; consentId: string;
  consentDocument: unknown; attribution: unknown; now: number;
}): HostAttributionSnapshot | null {
  if (!input.enabled || !input.isNew || !Number.isSafeInteger(input.now) ||
      !/^host_lead_[0-9]{13}_[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}$/u
        .test(input.eventId)) return null;
  const acceptedAt = Number(input.eventId.split("_")[2]);
  const consent = input.consentDocument;
  if (!validateHostAcquisitionConsentDocument(consent) ||
      consent.status !== "active" || consent.consentId !== input.consentId ||
      !hasCurrentHostConsent(consent.authority, input.now, "analytics") ||
      acceptedAt < consent.authority.acceptedAt || acceptedAt > input.now) {
    return null;
  }
  const raw = object(input.attribution);
  if (!raw) return null;
  const firstTouch = touch(raw.firstTouch,
    consent.authority.chosenAt, acceptedAt);
  const lastTouch = touch(raw.lastTouch,
    consent.authority.chosenAt, acceptedAt);
  if (!firstTouch && !lastTouch || firstTouch && lastTouch &&
      firstTouch.capturedAt > lastTouch.capturedAt) return null;
  return {version: 1, consentId: input.consentId, acceptedAt,
    expiresAt: consent.authority.expiresAt, firstTouch, lastTouch};
}

const CLEANUP_BATCH = 500;
const WITHDRAWALS_PER_RUN = 100;

/** Erases only optional attribution; operational application history remains.
 * Rechecks query results transactionally. Readers must still recheck current
 * consent because bounded cleanup is not synchronous authorization. A short
 * page proves no further row matched when the query ran. */
async function clearAttribution(db: Firestore, consentId: string | null,
  now: number, limit = CLEANUP_BATCH):
  Promise<{cleared: number; scanned: number; drained: boolean}> {
  if (!Number.isSafeInteger(now) || now <= 0) {
    return {cleared: 0, scanned: 0, drained: false};
  }
  const field = consentId ? "acquisitionAttribution.consentId" :
    "acquisitionAttribution.expiresAt";
  const rows = await db.collection("salesInboundIntents")
    .where(field, consentId ? "==" : "<=", consentId ?? now).limit(limit).get();
  let cleared = 0;
  for (const row of rows.docs) {
    const changed = await db.runTransaction(async (tx) => {
      const current = await tx.get(row.ref);
      const snapshot = object(current.data()?.acquisitionAttribution);
      if (!snapshot || (consentId ? snapshot.consentId !== consentId :
        !Number.isSafeInteger(snapshot.expiresAt) ||
          Number(snapshot.expiresAt) <= 0 ||
          Number(snapshot.expiresAt) > now)) {
        return false;
      }
      tx.update(row.ref, {acquisitionAttribution: FieldValue.delete()});
      return true;
    });
    if (changed) cleared++;
  }
  return {cleared, scanned: rows.size, drained: rows.size < limit};
}

export const expireHostAttribution = async (db: Firestore, now = Date.now()) =>
  (await clearAttribution(db, null, now)).cleared;

/** Request-path withdrawal stays bounded to one batch. The tombstone keeps
 * attributionCleanupPending until the expiry worker proves nothing remains. */
export const withdrawHostAttribution = async (db: Firestore,
  consentId: string) => /^[a-f0-9]{64}$/u.test(consentId) ?
  (await clearAttribution(db, consentId, Date.now())).cleared : 0;

/** Resumes withdrawals before snapshot expiry, touching at most one batch of
 * intents per run. A revoked capability can never create another snapshot, so
 * a drained query lets the tombstone flag clear under a transactional recheck.
 * Returns how many snapshots were erased. */
export async function drainWithdrawnHostAttribution(db: Firestore,
  now = Date.now()): Promise<number> {
  if (!Number.isSafeInteger(now) || now <= 0) return 0;
  const pending = await db.collection(HOST_CONSENT_COLLECTION)
    .where("attributionCleanupPending", "==", true)
    .limit(WITHDRAWALS_PER_RUN).get();
  let budget = CLEANUP_BATCH;
  let cleared = 0;
  for (const tombstone of pending.docs) {
    if (budget <= 0) break;
    const page = await clearAttribution(db, tombstone.id, now, budget);
    cleared += page.cleared;
    budget -= page.scanned;
    if (!page.drained) continue;
    await db.runTransaction(async (tx) => {
      const current = (await tx.get(tombstone.ref)).data();
      if (!validateHostAcquisitionConsentDocument(current) ||
          current.consentId !== tombstone.id ||
          current.status !== "revoked" ||
          current.attributionCleanupPending !== true) return;
      tx.update(tombstone.ref, {attributionCleanupPending: false,
        updatedAt: Timestamp.fromMillis(now)});
    });
  }
  return cleared;
}
