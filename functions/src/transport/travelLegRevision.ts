import {HttpsError} from "firebase-functions/v2/https";
import {assertRevision} from "../shared/programAuthority";
import type {TransportOperationReceiptDocument} from
  "../shared/generated/firestoreAdminTypes";
import type {SetProgramTravelReadinessCallablePayload} from
  "../shared/generated/setProgramTravelReadinessCallablePayload";

/** A queued action may follow its own acknowledged observation. Other writes,
 * including flight refresh and itinerary edits, still invalidate the fence.
 */
export async function assertTravelLegRevision(params: {
  db: FirebaseFirestore.Firestore;
  tx: FirebaseFirestore.Transaction;
  programId: string;
  legId: string;
  actorUid: string;
  actualRevision: number;
  expectedRevision: number;
  afterObservation?:
    SetProgramTravelReadinessCallablePayload["afterObservation"];
}): Promise<void> {
  const prior = params.afterObservation;
  if (!prior) {
    assertRevision(params.actualRevision, params.expectedRevision);
    return;
  }
  const ref = params.db.collection("transportOperationReceipts").doc(
    `${params.programId}__${prior.action}__${prior.clientOperationId}`);
  const receipt = (await params.tx.get(ref)).data() as
    TransportOperationReceiptDocument | undefined;
  if (!receipt || receipt.programId !== params.programId ||
      receipt.actorUid !== params.actorUid || receipt.legId !== params.legId ||
      receipt.operationKind !== prior.action ||
      receipt.clientOperationId !== prior.clientOperationId ||
      !Number.isSafeInteger(receipt.resultRevision) ||
      receipt.resultRevision < params.expectedRevision) {
    throw new HttpsError("aborted",
      "The preceding arrival observation needs review before this action.");
  }
  assertRevision(params.actualRevision, receipt.resultRevision);
}
