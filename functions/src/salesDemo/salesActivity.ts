import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";
import type {Blueprint, Session} from "./model";

/** Reviewed links confer no authority and cannot cross organizer boundaries. */
export async function checkDemoSalesLinks(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  organizerId: string | null,
  opportunityId: string | null,
): Promise<void> {
  if (!opportunityId) return;
  if (!organizerId) {
    throw new HttpsError("failed-precondition",
      "A Sales opportunity needs a reviewed organizer identity.");
  }
  const opportunity = (await tx.get(db.collection("salesOpportunities")
    .doc(opportunityId))).data();
  if (opportunity?.classification !== "sales_private" ||
      opportunity.organizerId !== organizerId ||
      opportunity.opportunityId !== opportunityId) {
    throw new HttpsError("failed-precondition",
      "Demo opportunity does not belong to this organizer.");
  }
}

/** Prepare all reads first; invoke only beside the confirmed session write. */
export async function prepareDemoSalesActivity(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  blueprint: Blueprint,
  session: Session,
  transition: "started" | "completed",
  recordedAt: string,
): Promise<() => void> {
  if (!blueprint.organizerId) return () => {};
  const organizerId = blueprint.organizerId;
  const account = (await tx.get(db.collection("organizerSalesAccounts")
    .doc(organizerId))).data();
  if (!account || account.classification !== "sales_private" ||
      account.organizerId !== organizerId ||
      account.researchStatus === "archived") return () => {};
  await checkDemoSalesLinks(tx, db, organizerId, blueprint.opportunityId);
  const activityId = "demo_" + createHash("sha256")
    .update(`${session.sessionId}\u0000${transition}`)
    .digest("hex").slice(0, 40);
  const ref = db.collection("salesActivities").doc(activityId);
  const prior = (await tx.get(ref)).data();
  const source = {kind: "sales_demo", sessionId: session.sessionId,
    blueprintId: blueprint.blueprintId, blueprintRevision: blueprint.revision,
    invitationId: session.invitationId};
  const type = `demo_${transition}`;
  if (prior) {
    if (prior.classification !== "sales_private" ||
        prior.organizerId !== organizerId || prior.type !== type ||
        prior.actorUid !== session.actorUid ||
        Object.entries(source).some(([key, value]) =>
          prior.source?.[key] !== value)) {
      throw new HttpsError("failed-precondition",
        "Confirmed demo activity has conflicting source identity.");
    }
    return () => {};
  }
  return () => tx.create(ref, {
    schemaVersion: 1, classification: "sales_private", activityId,
    organizerId, opportunityId: blueprint.opportunityId, type, source,
    channel: null, outcome: null, providerConfirmed: false,
    occurredAt: transition === "started" ? session.createdAt : recordedAt,
    recordedAt, actorUid: session.actorUid,
    note: transition === "started" ?
      "The invited contact started the private sample workflow." :
      "The invited contact completed the private sample workflow.",
  });
}
