import {createHash} from "node:crypto";
import type {SalesActivity} from "../admin/sales/types";

export interface ClaimSalesTransition {
  organizerId: string;
  claimRequestId: string;
  transitionId: string;
  status: "requested" | "approved" | "rejected";
  actorUid: string;
  recordedAt: string;
}

/** Read before any product writes; stage only if the claim transition succeeds.
 * This projection records an existing product decision and grants no authority.
 */
export async function prepareClaimSalesTransition(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  transition: ClaimSalesTransition
): Promise<() => void> {
  const restriction = await tx.get(db.collection("salesPrivacyRestrictions")
    .doc(transition.organizerId));
  if (restriction.exists) return () => {};
  const account = await tx.get(db.collection("organizerSalesAccounts")
    .doc(transition.organizerId));
  const data = account.data();
  if (!account.exists || data?.classification !== "sales_private" ||
      data.organizerId !== transition.organizerId ||
      data.researchStatus === "archived") return () => {};
  const activityId = `claim_${createHash("sha256")
    .update(transition.transitionId).digest("hex").slice(0, 40)}`;
  const taskId = `claim_${createHash("sha256")
    .update(transition.claimRequestId).digest("hex").slice(0, 40)}_followup`;
  const hasOwner = typeof data.assignedOwnerUid === "string" &&
    data.assignedOwnerUid.length > 0;
  const taskRef = db.collection("salesTasks").doc(taskId);
  const previousTask = hasOwner ? (await tx.get(taskRef)).data() : undefined;
  const note = {
    requested: "An organizer ownership claim was submitted for review.",
    approved: "Organizer ownership was approved through claim review.",
    rejected: "Organizer ownership was rejected through claim review.",
  }[transition.status];
  return () => {
    tx.create(db.collection("salesActivities").doc(activityId), {
      schemaVersion: 1, classification: "sales_private", activityId,
      organizerId: transition.organizerId, opportunityId: null,
      type: `claim_${transition.status}`, channel: null, outcome: null,
      providerConfirmed: false, occurredAt: transition.recordedAt,
      recordedAt: transition.recordedAt, note, actorUid: transition.actorUid,
      source: {kind: "organizer_claim",
        claimRequestId: transition.claimRequestId,
        transitionId: transition.transitionId},
    } satisfies SalesActivity);
    // The canonical claim queue owns the review. Sales receives a follow-up
    // only when an employee is already assigned; a claimant is never assigned
    // as an internal sales employee merely because they submitted a claim.
    if (hasOwner) {
      tx.set(taskRef, {
        schemaVersion: 1, classification: "sales_private", taskId,
        organizerId: transition.organizerId, contactId: null,
        revision: (previousTask?.revision ?? 0) + 1,
        kind: "service_commitment",
        title: transition.status === "requested" ?
          "Follow up on organizer claim review" :
          "Follow up on organizer claim outcome",
        dueAt: previousTask?.dueAt ?? null,
        ownerUid: data.assignedOwnerUid, status: "open",
        createdAt: previousTask?.createdAt ?? transition.recordedAt,
        updatedAt: transition.recordedAt,
        updatedBy: transition.actorUid,
      });
    }
  };
}
