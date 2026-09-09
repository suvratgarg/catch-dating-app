import {HttpsError} from "firebase-functions/v2/https";
import type {Firestore, Transaction, DocumentSnapshot} from
  "firebase-admin/firestore";
import {operationContentHash as hash} from "../operations/durableActions";
import {validateEventRehearsalMovementDocument} from
  "../shared/generated/validators/eventRehearsalMovementDocument";
import type {GetEventRehearsalMovementCallablePayload as Input} from
  "../shared/generated/getEventRehearsalMovementCallablePayload";
import {invalidSource} from "../eventSuccess/operations/groupProgressSource";
import type {Movement, MovementSource} from "./movementSource";

export const rehearsalMovements = "eventRehearsalMovements";
export type MovementScope = Input["scope"];
export function practiceMovementId(source: MovementSource, revision: number) {
  return "departure-roster:" + hash([source.context,
    source.groupId, revision]);
}
export function parsePracticeMovement(value: unknown, source: MovementSource,
  expectedRevision?: number): Movement {
  if (!validateEventRehearsalMovementDocument(value) ||
      value.sessionId !== source.sessionId ||
      value.clockId !== source.context.clockId ||
      value.groupId !== source.groupId ||
      expectedRevision !== undefined &&
        value.progressRevision !== expectedRevision ||
      value.departure.confirmedAt > source.now ||
      value.departure.confirmedAt < source.startAt) throw invalidSource();
  const {departure, report} = value;
  const members = departure.roster?.members ?? [];
  const ids = members.map((m) => m.attendeeId);
  if (!canonical(ids) || members.some((m) => source.groupId === "event:whole" ?
    m.membershipHash !== null : !m.membershipHash || !m.episodeId)) {
    throw invalidSource();
  }
  const target = departure.destination;
  const checkpointId = target.kind === "itineraryStop" ? target.stopId :
    target.kind === "groupCheckpoint" ? target.checkpointId : null;
  const request = departure.checkpointRequest;
  if (request && (!departure.roster || !checkpointId ||
      request.dueAt < departure.confirmedAt)) throw invalidSource();
  if (report && (!departure.roster || !checkpointId ||
      report.rosterHash !== hash(departure) ||
      report.reportedAt < departure.confirmedAt ||
      report.reportedAt > source.now || !canonical(report.accountedFor) ||
      report.accountedFor.some((id) => !ids.includes(id)))) {
    throw invalidSource();
  }
  assertManagement(value, source);
  return value;
}

function assertManagement(record: Movement, source: MovementSource) {
  const {assignment: a, closeout: c, ...base} = record;
  const {departure} = record;
  const original = departure.checkpointRequest;
  const time = (at: number) => at >= departure.confirmedAt && at <= source.now;
  if (a && (!original || !time(a.assignedAt) || a.reason !== a.reason.trim() ||
      a.operationId === departure.operationId ||
      a.responsibleOperatorId === a.previousResponsibleOperatorId ||
      a.revision === 1 && a.previousResponsibleOperatorId !==
        original.responsibleOperatorId)) throw invalidSource();
  if (!c) return;
  if (!original || !time(c.changedAt) || c.reason !== c.reason.trim() ||
      c.previousRevision !== c.revision - 1 ||
      c.operationId === departure.operationId ||
      c.operationId === a?.operationId ||
      c.decision.kind === "reopen" && c.previousRevision === 0) {
    throw invalidSource();
  }
  if (c.decision.kind !== "close") return;
  const {report, dispositions} = c.decision;
  parsePracticeMovement({...base, report}, {...source, now: c.changedAt});
  const ids = [...report.accountedFor,
    ...dispositions.map((d) => d.attendeeId)].sort();
  if (!record.report || report.revision > record.report.revision ||
      dispositions.length === 0 ||
      !canonical(dispositions.map((d) => d.attendeeId)) ||
      hash(ids) !== hash(departure.roster!.members.map((m) => m.attendeeId)) ||
      dispositions.some((d) => d.resolvedAt < departure.confirmedAt ||
        d.resolvedAt > c.changedAt)) throw invalidSource();
}
function canonical(ids: readonly string[]) {
  return ids.every((id, i) => i === 0 || ids[i - 1] < id);
}

/** Page at 25 manifests; an older selected departure is explicit. */
export async function readPracticeMovements(db: Firestore, tx: Transaction,
  source: MovementSource, scope: MovementScope) {
  const base = db.collection(rehearsalMovements)
    .where("sessionId", "==", source.sessionId)
    .where("clockId", "==", source.context.clockId)
    .where("groupId", "==", source.groupId);
  const pageQuery = scope.beforeRevision === undefined ? base :
    base.where("progressRevision", "<", scope.beforeRevision);
  const [latestSnaps, pageSnaps] = await Promise.all([
    tx.get(base.orderBy("progressRevision", "desc").limit(1)),
    tx.get(pageQuery.orderBy("progressRevision", "desc").limit(26)),
  ]);
  const read = (snap: DocumentSnapshot) => {
    const value = parsePracticeMovement(snap.data(), source);
    if (snap.id !== practiceMovementId(source, value.progressRevision)) {
      throw invalidSource();
    }
    return value;
  };
  const current = latestSnaps.empty ? null : read(latestSnaps.docs[0]);
  const page = pageSnaps.docs.map(read);
  let selected = current;
  if (scope.progressRevision !== undefined) {
    const snap = await tx.get(db.collection(rehearsalMovements).doc(
      practiceMovementId(source, scope.progressRevision)));
    if (!snap.exists) {
      throw new HttpsError("not-found", "Recorded departure not found.");
    }
    selected = read(snap);
    if (selected.progressRevision !== scope.progressRevision || !current ||
        selected.progressRevision > current.progressRevision) {
      throw invalidSource();
    }
  }
  return {current, selected, page: page.slice(0, 25),
    nextBeforeRevision: page.length > 25 ? page[24].progressRevision : null};
}
export type MovementRecords = Awaited<ReturnType<typeof readPracticeMovements>>;
