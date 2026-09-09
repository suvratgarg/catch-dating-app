import {HttpsError} from "firebase-functions/v2/https";
import type {Firestore, Transaction} from "firebase-admin/firestore";
import type {EventRehearsalDocument as Session,
  EventRehearsalActorDocument as Actor} from
  "../shared/generated/firestoreAdminTypes";
import type {EventRehearsalMessageDocument as Message} from
  "../shared/generated/eventRehearsalMessageDocument";
import {operationContentHash as hash} from "../operations/durableActions";
import {practiceMovementSource, Movement} from "./movementSource";
import {parsePracticeMovement, practiceMovementId, rehearsalMovements} from
  "./movementRecords";

type Plan = Message["plan"];
export type PracticeDepartures = ReadonlyMap<string, Movement | null>;
export function practicePlanGroup(plan: Plan): string {
  return plan.guidance.destination.kind === "groupCheckpoint" ?
    plan.guidance.destination.groupId : "event:whole";
}

/** Read only the latest saved departure in each requested synthetic group. */
export async function readPracticeDepartures(db: Firestore, tx: Transaction,
  sessionId: string, session: Session, plans: readonly Plan[],
  pending?: Movement | null): Promise<PracticeDepartures> {
  const groups = [...new Set(plans.map(practicePlanGroup))];
  if (groups.length > 41) {
    throw new HttpsError("resource-exhausted", "Too many practice groups.");
  }
  const entries = await Promise.all(groups.map(async (groupId) => {
    let source: ReturnType<typeof practiceMovementSource>;
    try {
      source = practiceMovementSource(sessionId, session, groupId);
    } catch (error) {
      if (!(error instanceof HttpsError)) throw error;
      return [groupId, null] as const;
    }
    // A parent departure transaction supplies its validated pending record.
    // Transport failures are never swallowed as missing movement evidence.
    const snaps = pending?.groupId === groupId ? null : await tx.get(
      db.collection(rehearsalMovements).where("sessionId", "==", sessionId)
        .where("clockId", "==", source.context.clockId)
        .where("groupId", "==", groupId)
        .orderBy("progressRevision", "desc").limit(1));
    const snap = snaps?.docs[0];
    if (!snap && pending?.groupId !== groupId) return [groupId, null] as const;
    try {
      const record = parsePracticeMovement(snap ? snap.data() : pending,
        source);
      if (snap && snap.id !== practiceMovementId(source,
        record.progressRevision)) return [groupId, null] as const;
      return [groupId, record] as const;
    } catch (error) {
      if (!(error instanceof HttpsError)) throw error;
      return [groupId, null] as const;
    }
  }));
  return new Map(entries);
}

/** Timetables,
  GPS and client-authored confirmation flags grant no authority. */
export function resolvePracticeGuidance(session: Session, actor: Actor,
  plan: Plan, departures: PracticeDepartures) {
  const groupId = practicePlanGroup(plan);
  const record = departures.get(groupId);
  if (!record) return null;
  try {
    const source = practiceMovementSource(actor.sessionId, session, groupId);
    parsePracticeMovement(record, source);
    const destination = source.destinations.find((d) =>
      hash(d.target) === hash(record.departure.destination));
    if (!source.eventOpen || !source.runtimeLive || !destination ||
        record.departure.sourceHash !== source.sourceHash) return null;
    // A configured entry rule can restrict a confirmed venue, never create
    // movement or relax a restriction. Route/checkpoint targets stay exact.
    const target = destination.target.kind === "fixedPlace" &&
      destination.target.lateEntry === "allowed" &&
      plan.policy.destination.kind === "fixedPlace" &&
      plan.policy.destination.placeId === destination.target.placeId ?
      {...destination.target, lateEntry: plan.policy.destination.lateEntry} :
      destination.target;
    const guidance = {revision: record.progressRevision,
      destination: target,
      materialKey: hash([source.sourceHash, target]),
      text: destination.text, validUntil: source.endAt};
    return {plan: {...plan, departureConfirmed: true, guidance,
      ...(plan.laterChoices ? {laterChoices: plan.laterChoices.filter((c) =>
        source.destinations.some((d) => hash(d.target) === hash(c.target)))} :
        {})}, binding: {groupId, progressRevision: record.progressRevision,
      sourceHash: source.sourceHash}};
  } catch (error) {
    if (!(error instanceof HttpsError)) throw error;
    return null;
  }
}

/** Reconfirming an unchanged destination must not create another message. */
export function practiceGuidanceMaterial(plan: Plan) {
  const {revision: omitted, ...guidance} = plan.guidance;
  void omitted;
  return hash(guidance);
}
export function practiceRecipeKey(plan: Plan) {
  const {guidance, departureConfirmed: omitted, ...recipe} = plan;
  void guidance; void omitted;
  return hash([practicePlanGroup(plan), recipe]);
}
