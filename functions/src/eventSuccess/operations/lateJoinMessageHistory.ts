import type {Firestore, Transaction} from "firebase-admin/firestore";
import {guestIdentity, requireDocumentId} from "./guestRecords";
import {EVENT_ASSISTANCE_MESSAGES} from "./firestoreMessageOutbox";
import {MessageRecord, parseMessageRecord} from "./messageOutbox";
import type {LateJoinSourceScope} from "./lateJoinSourceReader";
import {MAX_LATE_JOIN_HISTORY, projectLateJoinMessageHistory,
  LateJoinMessageHistory} from "./lateJoinHistoryProjection";
export {MAX_LATE_JOIN_HISTORY, projectLateJoinMessageHistory,
  LateJoinMessageHistory} from "./lateJoinHistoryProjection";
export type LateJoinHistoryScope = LateJoinSourceScope & {episodeId: string};

/** All occurrences and lifecycle states of this guest's late-join episode. */
export async function readLateJoinMessageHistory(db: Firestore, tx: Transaction,
  scope: LateJoinHistoryScope, now: number,
  currentIntent?: MessageRecord["intent"]): Promise<LateJoinMessageHistory> {
  guestIdentity(scope.context, scope.attendeeId);
  requireDocumentId(scope.episodeId);
  const snapshots = await tx.get(db.collection(EVENT_ASSISTANCE_MESSAGES)
    .where("intent.context.mode", "==", "live")
    .where("intent.context.organizerId", "==", scope.context.organizerId)
    .where("intent.eventId", "==", scope.context.eventId)
    .where("intent.attendeeId", "==", scope.attendeeId)
    .where("intent.episodeId", "==", scope.episodeId)
    .where("intent.workflow.kind", "==", "lateJoin")
    .limit(MAX_LATE_JOIN_HISTORY + 1));
  if (snapshots.docs.length > MAX_LATE_JOIN_HISTORY) {
    return {kind: "unavailable", reason: "historyLimit"};
  }
  const records = snapshots.docs.map((snapshot) => {
    const record = parseMessageRecord(snapshot.data());
    if (record.messageId !== snapshot.id) {
      throw new Error("Late-join history document identity mismatch");
    }
    return record;
  });
  return projectLateJoinMessageHistory(scope, records, now, currentIntent);
}
