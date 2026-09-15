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
import {parsePracticeRouteDecision, readPracticeRouteDecision,
  RouteDecision} from "./routeDecisions";

type Plan = Message["plan"];
export interface PracticeProgress {
  movement: Movement;
  progressRevision: number;
  destination: Movement["departure"]["destination"];
  sourceHash: string;
}
export type PracticeDepartures = ReadonlyMap<string,
  PracticeProgress | Movement | null>;
export type PendingPracticeProgress = Movement | RouteDecision | null;
export function practicePlanGroup(plan: Plan): string {
  return plan.guidance.destination.kind === "groupCheckpoint" ?
    plan.guidance.destination.groupId : "event:whole";
}

/** Read only the latest saved departure in each requested synthetic group. */
export async function readPracticeDepartures(db: Firestore, tx: Transaction,
  sessionId: string, session: Session, plans: readonly Plan[],
  pending?: PendingPracticeProgress,
  additionalGroups: readonly string[] = []): Promise<PracticeDepartures> {
  const groups = [...new Set([...plans.map(practicePlanGroup),
    ...additionalGroups])];
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
    // A parent movement transaction supplies its validated pending progress.
    // Transport failures are never swallowed as missing movement evidence.
    const pendingMovement = pending?.groupId === groupId &&
      "departure" in pending ? pending : null;
    const pendingDecision = pending?.groupId === groupId &&
      !("departure" in pending) ? pending : null;
    const [snaps, savedDecision] = await Promise.all([
      pendingMovement ? null : tx.get(db.collection(rehearsalMovements)
        .where("sessionId", "==", sessionId)
        .where("clockId", "==", source.context.clockId)
        .where("groupId", "==", groupId)
        .orderBy("progressRevision", "desc").limit(1)),
      pendingDecision ? null : readPracticeRouteDecision(db, tx, source),
    ]);
    const snap = snaps?.docs[0];
    if (!snap && !pendingMovement) return [groupId, null] as const;
    try {
      const movement = parsePracticeMovement(snap ? snap.data() :
        pendingMovement,
      source);
      if (snap && snap.id !== practiceMovementId(source,
        movement.progressRevision)) return [groupId, null] as const;
      const decision = pendingDecision ? parsePracticeRouteDecision(
        pendingDecision, source) : savedDecision;
      if (decision &&
          (decision.progressRevision === movement.progressRevision ||
          decision.progressRevision > movement.progressRevision &&
            decision.departureRevision !== movement.progressRevision)) {
        return [groupId, null] as const;
      }
      const active = decision &&
        decision.progressRevision > movement.progressRevision ? decision : null;
      return [groupId, {movement,
        progressRevision: active?.progressRevision ?? movement.progressRevision,
        destination: active?.destination ?? movement.departure.destination,
        sourceHash: active?.sourceHash ?? movement.departure.sourceHash}] as
        const;
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
  const saved = departures.get(groupId);
  if (!saved) return null;
  const progress = practiceProgress(saved);
  try {
    const source = practiceMovementSource(actor.sessionId, session, groupId);
    parsePracticeMovement(progress.movement, source);
    const destination = source.destinations.find((d) =>
      hash(d.target) === hash(progress.destination));
    if (!source.eventOpen || !source.runtimeLive || !destination ||
        progress.sourceHash !== source.sourceHash) return null;
    // A configured entry rule can restrict a confirmed venue, never create
    // movement or relax a restriction. Route/checkpoint targets stay exact.
    const target = destination.target.kind === "fixedPlace" &&
      destination.target.lateEntry === "allowed" &&
      plan.policy.destination.kind === "fixedPlace" &&
      plan.policy.destination.placeId === destination.target.placeId ?
      {...destination.target, lateEntry: plan.policy.destination.lateEntry} :
      destination.target;
    const guidance = {revision: progress.progressRevision,
      destination: target,
      materialKey: hash([source.sourceHash, target]),
      text: destination.text, validUntil: source.endAt};
    return {plan: {...plan, departureConfirmed: true, guidance,
      ...(plan.laterChoices ? {laterChoices: plan.laterChoices.filter((c) =>
        source.destinations.some((d) => hash(d.target) === hash(c.target)))} :
        {})}, binding: {groupId, progressRevision: progress.progressRevision,
      sourceHash: source.sourceHash}};
  } catch (error) {
    if (!(error instanceof HttpsError)) throw error;
    return null;
  }
}

/** Normalizes older in-memory callers that still provide a movement record. */
export function practiceProgress(
  value: PracticeProgress | Movement): PracticeProgress {
  return "movement" in value ? value : {movement: value,
    progressRevision: value.progressRevision,
    destination: value.departure.destination,
    sourceHash: value.departure.sourceHash};
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
