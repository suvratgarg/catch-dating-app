import {HttpsError} from "firebase-functions/v2/https";
import type {SalesPrincipal} from "./types";

export const SALES_STAFF_ACTIONS = [
  "hosts.search", "hosts.get", "hosts.update", "tasks.list", "tasks.upsert",
  "opportunities.list", "opportunities.upsert", "activities.log",
  "contacts.list", "contacts.upsert", "evidence.list", "evidence.add",
  "evidence.propose", "evidenceProposals.list", "receipts.get", "fields.list",
] as const;

export function isAssignedSalesStaff(principal: SalesPrincipal): boolean {
  return principal.roles.includes("salesStaff") &&
    !principal.roles.some((role) => role === "admin" || role === "adminOwner");
}

export async function assignedSalesAccountIds(
  db: FirebaseFirestore.Firestore, uid: string,
): Promise<string[]> {
  const result = await db.collection("organizerSalesAccounts")
    .where("assignedOwnerUid", "==", uid).limit(31).get();
  if (result.size > 30) {
    throw new HttpsError("resource-exhausted",
      "Sales staff assignment scope needs owner curation.");
  }
  return result.docs.map((doc) => doc.id).sort();
}

/** Read the canonical assignment inside each mutation/replay transaction. */
export async function assertSalesStaffAccount(
  db: FirebaseFirestore.Firestore, principal: SalesPrincipal,
  organizerId: string, tx?: FirebaseFirestore.Transaction,
): Promise<void> {
  if (!isAssignedSalesStaff(principal)) return;
  if (!principal.organizerIds?.includes(organizerId)) {
    throw new HttpsError("permission-denied",
      "Account is outside Sales staff scope.");
  }
  const ref = db.collection("organizerSalesAccounts").doc(organizerId);
  const account = (await (tx ? tx.get(ref) : ref.get())).data();
  if (account?.assignedOwnerUid !== principal.uid ||
      account?.organizerId !== organizerId ||
      account?.classification !== "sales_private") {
    throw new HttpsError("permission-denied",
      "Current Sales assignment is required.");
  }
}

export async function assertSalesStaffScope(
  db: FirebaseFirestore.Firestore, principal: SalesPrincipal,
  tx?: FirebaseFirestore.Transaction,
): Promise<void> {
  if (!isAssignedSalesStaff(principal)) return;
  if (!Array.isArray(principal.organizerIds) ||
      principal.organizerIds.length > 30) {
    throw new HttpsError("permission-denied",
      "Bounded Sales staff scope is required.");
  }
  await Promise.all(principal.organizerIds.map((organizerId) =>
    assertSalesStaffAccount(db, principal, organizerId, tx)));
}
