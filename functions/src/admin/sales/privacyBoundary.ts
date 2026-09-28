import {HttpsError} from "firebase-functions/v2/https";
import {PRIVACY_RESTRICTIONS, privacyId} from "../salesPrivacy/model";

/** Scope from validated records and nested immutable receipt results. */
export function salesMaterialOrganizerIds(value: unknown): string[] {
  const ids = new Set<string>();
  const visit = (node: unknown, depth: number) => {
    if (depth > 24) {
      throw new HttpsError("failed-precondition",
        "Sales scope is too deeply nested to verify.");
    }
    if (Array.isArray(node)) node.forEach((child) => visit(child, depth + 1));
    else if (node && typeof node === "object") {
      for (const [key, child] of Object.entries(node)) {
        if (key === "organizerId" && typeof child === "string") {
          ids.add(privacyId(child, "organizer ID"));
        } else if (key === "organizerIds" && Array.isArray(child)) {
          child.forEach((id) => ids.add(privacyId(id, "organizer ID")));
        } else visit(child, depth + 1);
      }
    }
  };
  visit(value, 0);
  if (ids.size > 100) {
    throw new HttpsError("resource-exhausted",
      "Sales scope exceeds the reviewed privacy boundary.");
  }
  return [...ids];
}
export async function assertSalesMaterialPrivacyOpen(
  db: FirebaseFirestore.Firestore, material: unknown,
  tx?: FirebaseFirestore.Transaction,
): Promise<void> {
  for (const id of salesMaterialOrganizerIds(material)) {
    const ref = db.collection(PRIVACY_RESTRICTIONS).doc(id);
    const snap = tx ? await tx.get(ref) : await ref.get();
    if (snap.exists) {
      throw new HttpsError("failed-precondition",
        "Private Sales processing is restricted for this organizer.");
    }
  }
}
/** Preserve server pagination while withholding restricted page rows. */
export async function filterSalesPrivacyRows<T>(
  db: FirebaseFirestore.Firestore, rows: T[],
): Promise<T[]> {
  const ids = salesMaterialOrganizerIds(rows);
  const restricted = new Set<string>();
  await Promise.all(ids.map(async (id) => {
    if ((await db.collection(PRIVACY_RESTRICTIONS).doc(id).get()).exists) {
      restricted.add(id);
    }
  }));
  return rows.filter((row) => !salesMaterialOrganizerIds(row)
    .some((id) => restricted.has(id)));
}
