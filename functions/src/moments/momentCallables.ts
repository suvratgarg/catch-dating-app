import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import type {Firestore} from "firebase-admin/firestore";
import {
  eventOrganizerRef,
  isEventOrganizerManager,
  requireEventOrganizer,
} from "../shared/eventOrganizers";
import {
  requireProgramAccess,
  requireProgramDuty,
} from "../shared/programAuthority";
import {requireDoc} from "../shared/validation";
import type {EventDocument} from "../shared/generated/firestoreAdminTypes";
import {
  MOMENTS_COLLECTION,
  momentFromDocument,
  readAction,
  readAudience,
  readInitiation,
  readScope,
} from "./momentDocuments";
import {
  armMoment,
  pauseMoment,
  resumeMoment,
  reviseMoment,
  sameScope,
  scopeId,
  validateMomentDefinition,
  type LifecycleResult,
  type MomentDefinition,
  type MomentScope,
} from "./momentModel";

/**
 * Organizer-facing moment management, kept as deps-injected handlers so the
 * onCall wiring lands with the generated contract validators in the shared
 * registration window. Authority: program moments need manager access or an
 * active communications/coordinator duty; event moments are
 * organizer-manager only (event staff do not configure sends in v1).
 *
 * Every mutation round-trips through the pure lifecycle in momentModel:
 * edits drop a moment back to draft and clear its approval (approve the
 * rule once per definition, not once ever), and arming writes the
 * approval record.
 */

export interface MomentCallablesDeps {
  firestore: () => Firestore;
  nowMillis: () => number;
  authorizeManage: (
    db: Firestore,
    scope: MomentScope,
    actorUid: string,
  ) => Promise<void>;
}

export const defaultMomentCallablesDeps: Omit<MomentCallablesDeps,
  "authorizeManage"> = {
    firestore: () => admin.firestore(),
    nowMillis: () => Date.now(),
  };

/** Default authority: manager, or staff holding the communications duty
 *  (program coordinators satisfy every duty); event moments are
 *  organizer-manager only. */
export async function requireMomentManageAuthority(
  db: Firestore,
  scope: MomentScope,
  actorUid: string,
): Promise<void> {
  if (scope.kind === "program") {
    const access = await requireProgramAccess({
      db,
      programId: scope.programId,
      actorUid,
    });
    if (access.role !== "manager") {
      requireProgramDuty(access, "communications");
    }
    return;
  }
  const eventSnap = await db.collection("events").doc(scope.eventId).get();
  const event = requireDoc<EventDocument>(eventSnap, "EventDocument");
  const organizerSnap = await eventOrganizerRef(db, event).get();
  const organizer = requireEventOrganizer(organizerSnap, event);
  if (!isEventOrganizerManager(organizer, event, actorUid)) {
    throw new HttpsError(
      "permission-denied",
      "Only an organizer manager can manage moments for this event.");
  }
}

interface ActorParams {
  actorUid: string;
}

export interface UpsertMomentParams extends ActorParams {
  /** Whole moment payload; `scope` is immutable on update. */
  payload: Record<string, unknown>;
}

/** Creates a draft moment or revises an existing one back to draft. */
export async function upsertOrganizerMoment(
  deps: MomentCallablesDeps,
  params: UpsertMomentParams,
): Promise<{moment: MomentDefinition}> {
  const db = deps.firestore();
  const scope = readScope(params.payload.scope);
  const initiation = readInitiation(params.payload.initiation);
  const audience = readAudience(params.payload.audience);
  const action = readAction(params.payload.action);
  const name = typeof params.payload.name === "string" ?
    params.payload.name.trim() : "";
  if (!scope || !initiation || !audience || !action || name.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "Moment requires scope, name, initiation, audience, and action.");
  }
  await deps.authorizeManage(db, scope, params.actorUid);

  const momentId = typeof params.payload.momentId === "string" &&
    params.payload.momentId.length > 0 ?
    params.payload.momentId : db.collection(MOMENTS_COLLECTION).doc().id;
  const ref = db.collection(MOMENTS_COLLECTION).doc(momentId);
  const existing = await ref.get();

  if (existing.exists) {
    const current = momentFromDocument(
      existing.data() as Record<string, unknown>);
    if (current === null) {
      throw new HttpsError(
        "failed-precondition", "Stored moment is unreadable.");
    }
    if (!sameScope(current.scope, scope)) {
      throw new HttpsError(
        "invalid-argument", "A moment's scope cannot change.");
    }
    const result = reviseMoment(current,
      {name, initiation, sense: readSense(params.payload.sense),
        audience, action});
    return lifecycleWrite(db, deps, ref, current, result);
  }
  const next: MomentDefinition = {
    momentId,
    scope,
    name,
    initiation,
    sense: readSense(params.payload.sense),
    audience,
    action,
    status: "draft",
    approval: null,
    origin: "organizer",
    revision: 1,
  };
  const violations = validateMomentDefinition(next);
  if (violations.length > 0) {
    throw new HttpsError(
      "invalid-argument",
      `Invalid moment: ${violations.join(", ")}`);
  }
  await ref.set(momentToDocument(next, deps.nowMillis(), true));
  return {moment: next};
}

interface MomentRefParams extends ActorParams {
  scope: MomentScope;
  momentId: string;
}

/** Approve-the-rule-once: arms the moment under the actor's approval. */
export async function armOrganizerMoment(
  deps: MomentCallablesDeps,
  params: MomentRefParams,
): Promise<{moment: MomentDefinition}> {
  return transition(deps, params, (current) =>
    armMoment(current, {
      approvedByUid: params.actorUid,
      approvedAtMillis: deps.nowMillis(),
    }));
}

export async function pauseOrganizerMoment(
  deps: MomentCallablesDeps,
  params: MomentRefParams,
): Promise<{moment: MomentDefinition}> {
  return transition(deps, params, pauseMoment);
}

/** Resuming reuses the standing approval — the rule did not change. */
export async function resumeOrganizerMoment(
  deps: MomentCallablesDeps,
  params: MomentRefParams,
): Promise<{moment: MomentDefinition}> {
  return transition(deps, params, resumeMoment);
}

async function transition(
  deps: MomentCallablesDeps,
  params: MomentRefParams,
  apply: (moment: MomentDefinition) => LifecycleResult,
): Promise<{moment: MomentDefinition}> {
  const db = deps.firestore();
  await deps.authorizeManage(db, params.scope, params.actorUid);
  const ref = db.collection(MOMENTS_COLLECTION).doc(params.momentId);
  const snap = await ref.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Moment not found.");
  }
  const current = momentFromDocument(snap.data() as Record<string, unknown>);
  if (current === null) {
    throw new HttpsError(
      "failed-precondition", "Stored moment is unreadable.");
  }
  if (!sameScope(current.scope, params.scope)) {
    throw new HttpsError(
      "permission-denied", "Moment does not belong to this scope.");
  }
  return lifecycleWrite(db, deps, ref, current, apply(current));
}

async function lifecycleWrite(
  db: Firestore,
  deps: MomentCallablesDeps,
  ref: FirebaseFirestore.DocumentReference,
  _current: MomentDefinition,
  result: LifecycleResult,
): Promise<{moment: MomentDefinition}> {
  if (result.kind === "rejected") {
    if (result.reason === "invalidDefinition") {
      throw new HttpsError(
        "invalid-argument",
        `Invalid moment: ${(result.violations ?? []).join(", ")}`);
    }
    throw new HttpsError(
      "failed-precondition", `Cannot transition moment: ${result.reason}`);
  }
  await ref.set(
    momentToDocument(result.moment, deps.nowMillis(), false),
    {merge: true});
  return {moment: result.moment};
}

/** Lists moments for one scope; the caller already holds manage access. */
export async function listOrganizerMoments(
  deps: MomentCallablesDeps,
  params: ActorParams & {scope: MomentScope},
): Promise<{moments: MomentDefinition[]}> {
  const db = deps.firestore();
  await deps.authorizeManage(db, params.scope, params.actorUid);
  const snap = await db.collection(MOMENTS_COLLECTION)
    .where("scopeKind", "==", params.scope.kind)
    .where("scopeId", "==", scopeId(params.scope))
    .get();
  const moments: MomentDefinition[] = [];
  for (const doc of snap.docs) {
    const moment = momentFromDocument(doc.data());
    if (moment !== null) moments.push(moment);
  }
  moments.sort((a, b) => a.momentId.localeCompare(b.momentId));
  return {moments};
}

function readSense(raw: unknown): MomentDefinition["sense"] {
  return raw === "individual" ? "individual" : "audience";
}

/** Serializes a definition for storage; scopeKind/scopeId are denormalized
 *  for list queries. */
function momentToDocument(
  moment: MomentDefinition,
  nowMillis: number,
  isCreate: boolean,
): Record<string, unknown> {
  return {
    momentId: moment.momentId,
    scope: moment.scope,
    scopeKind: moment.scope.kind,
    scopeId: scopeId(moment.scope),
    name: moment.name,
    initiation: moment.initiation,
    sense: moment.sense,
    audience: moment.audience,
    action: moment.action,
    status: moment.status,
    approval: moment.approval,
    origin: moment.origin,
    revision: moment.revision,
    updatedAtMillis: nowMillis,
    ...(isCreate ? {createdAtMillis: nowMillis} : {}),
  };
}
