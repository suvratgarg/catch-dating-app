import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";

export const PRIVACY_RESTRICTIONS = "salesPrivacyRestrictions";
export const PRIVACY_POLICIES = "salesPrivacyPolicies";
export const PRIVACY_PLANS = "salesPrivacyPlans";
export const PRIVACY_BATCH_RECEIPTS = "salesPrivacyBatchReceipts";
export const MAX_INVENTORY_ITEMS = 240;
export const MAX_COLLECTION_SCAN = 250;
export const MAX_BATCH_ITEMS = 20;

export function privacyHash(value: unknown): string {
  function stable(item: unknown): string {
    if (Array.isArray(item)) return `[${item.map(stable).join(",")}]`;
    if (item && typeof item === "object") return `{${Object.entries(item)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, child]) => `${JSON.stringify(key)}:${stable(child)}`)
      .join(",")}}`;
    return JSON.stringify(item);
  }
  return createHash("sha256").update(stable(value)).digest("hex");
}

export function privacyId(value: unknown, label: string): string {
  if (typeof value !== "string" || !/^[A-Za-z0-9][A-Za-z0-9._:-]{0,179}$/u
    .test(value)) throw new HttpsError("invalid-argument", `Invalid ${label}.`);
  return value;
}

export function privacyRequestId(value: unknown): string {
  if (typeof value !== "string" || !/^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$/u
    .test(value)) throw new HttpsError("invalid-argument", "Invalid request ID.");
  return value;
}

/** Existence, not a mutable status flag, is the permanent reintroduction fence. */
export async function assertSalesPrivacyOpen(
  tx: FirebaseFirestore.Transaction, db: FirebaseFirestore.Firestore,
  organizerId: string,
): Promise<void> {
  const snap = await tx.get(db.collection(PRIVACY_RESTRICTIONS).doc(
    privacyId(organizerId, "organizer ID")));
  if (snap.exists) throw new HttpsError("failed-precondition",
    "Private Sales processing is restricted for this organizer.");
}

/** Use at read boundaries that cannot share a domain transaction. */
export async function assertSalesPrivacyOpenRead(
  db: FirebaseFirestore.Firestore, organizerId: string,
): Promise<void> {
  const snap = await db.collection(PRIVACY_RESTRICTIONS).doc(
    privacyId(organizerId, "organizer ID")).get();
  if (snap.exists) throw new HttpsError("failed-precondition",
    "Private Sales processing is restricted for this organizer.");
}
