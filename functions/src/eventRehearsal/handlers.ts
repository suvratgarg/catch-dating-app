import {createHash, randomBytes, timingSafeEqual} from "node:crypto";
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {adminRolesFromToken} from "../admin/adminAuth";
import {requireAuth} from "../shared/auth";
import {
  appCheckCallableOptions,
  appCheckCallableOptionsWithLimits,
} from "../shared/callableOptions";
import type {
  EventDocument,
  EventRehearsalActionDocument,
  EventRehearsalActorDocument,
  EventRehearsalDocument,
  EventRehearsalGuestViewDocument,
} from "../shared/generated/firestoreAdminTypes";
import type {ControlEventRehearsalCallablePayload} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import type {ControlEventRehearsalSpatialCallablePayload} from
  "../shared/generated/controlEventRehearsalSpatialCallablePayload";
import type {CreateEventRehearsalCallablePayload} from
  "../shared/generated/createEventRehearsalCallablePayload";
import type {CreateEventRehearsalCallableResponse} from
  "../shared/generated/createEventRehearsalCallableResponse";
import type {EventRehearsalBootstrapCallableResponse} from
  "../shared/generated/eventRehearsalBootstrapCallableResponse";
import type {EventRehearsalGuestBootstrapCallableResponse} from
  "../shared/generated/eventRehearsalGuestBootstrapCallableResponse";
import type {EventRehearsalReproductionCallableResponse} from
  "../shared/generated/eventRehearsalReproductionCallableResponse";
import type {GetEventRehearsalBootstrapCallablePayload} from
  "../shared/generated/getEventRehearsalBootstrapCallablePayload";
import type {GetEventRehearsalGuestBootstrapCallablePayload} from
  "../shared/generated/getEventRehearsalGuestBootstrapCallablePayload";
import type {InjectEventRehearsalBehaviorCallablePayload} from
  "../shared/generated/injectEventRehearsalBehaviorCallablePayload";
import type {ResetEventRehearsalCallablePayload} from
  "../shared/generated/resetEventRehearsalCallablePayload";
import type {RotateEventRehearsalGuestLinkCallablePayload} from
  "../shared/generated/rotateEventRehearsalGuestLinkCallablePayload";
import type {SubmitEventRehearsalGuestActionCallablePayload} from
  "../shared/generated/submitEventRehearsalGuestActionCallablePayload";
import type {UpdateEventRehearsalSetupCallablePayload} from
  "../shared/generated/updateEventRehearsalSetupCallablePayload";
import {
  validateControlEventRehearsalCallablePayload,
} from "../shared/generated/validators/controlEventRehearsalInput";
import {
  validateControlEventRehearsalSpatialCallablePayload,
} from
  "../shared/generated/validators/controlEventRehearsalSpatialInput";
import {
  validateCreateEventRehearsalCallablePayload,
} from "../shared/generated/validators/createEventRehearsalInput";
import {
  validateGetEventRehearsalBootstrapCallablePayload,
} from
  "../shared/generated/validators/getEventRehearsalBootstrapInput";
import {
  validateGetEventRehearsalGuestBootstrapCallablePayload,
} from
  "../shared/generated/validators/getEventRehearsalGuestBootstrapInput";
import {
  validateInjectEventRehearsalBehaviorCallablePayload,
} from
  "../shared/generated/validators/injectEventRehearsalBehaviorInput";
import {
  validateResetEventRehearsalCallablePayload,
} from "../shared/generated/validators/resetEventRehearsalInput";
import {
  validateRotateEventRehearsalGuestLinkCallablePayload,
} from
  "../shared/generated/validators/rotateEventRehearsalGuestLinkInput";
import {
  validateSubmitEventRehearsalGuestActionCallablePayload,
} from
  "../shared/generated/validators/submitEventRehearsalGuestActionInput";
import {
  validateUpdateEventRehearsalSetupCallablePayload,
} from
  "../shared/generated/validators/updateEventRehearsalSetupInput";
import {requireOrganizerManager} from "../shared/organizerManagerAuthority";
import {checkRateLimit} from "../shared/rateLimit";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {
  actorAtMoment,
  applyRehearsalBehavior,
  applyRehearsalGuestAction,
  applyRehearsalSpatialAction,
  buildRehearsalActors,
  cuesBetween,
  eventRehearsalActionDocumentId,
  momentForStep,
  REHEARSAL_MAX_ACTIONS,
  REHEARSAL_MAX_ACTIVE_SESSIONS,
  REHEARSAL_RETENTION_MILLIS,
  resolveRehearsalControl,
} from "./engine";

const sessions = "eventRehearsals";
const actors = "eventRehearsalActors";
const actions = "eventRehearsalActions";
const guestViews = "eventRehearsalGuestViews";
const websiteBaseUrl = (process.env.WEBSITE_BASE_URL ??
  "https://catchdates.com").replace(/\/$/u, "");

type RehearsalSetup = EventRehearsalDocument["setup"];
type Firestore = FirebaseFirestore.Firestore;

interface CreateOverrides {
  setup?: RehearsalSetup;
  sourceEventRevision?: string | null;
}

/** Creates an isolated rehearsal and its deterministic synthetic roster. */
export async function createEventRehearsalHandler(
  request: CallableRequest<unknown>
): Promise<CreateEventRehearsalCallableResponse> {
  const uid = requireAuth(request);
  const data = validateCallableWithAjv<CreateEventRehearsalCallablePayload>(
    request,
    validateCreateEventRehearsalCallablePayload
  );
  const db = admin.firestore();
  await checkRateLimit(db, uid, "createEventRehearsal");
  await requireOrganizerManager({
    db,
    organizerId: data.organizerId,
    actorUid: uid,
  });
  await assertActiveSessionLimit(db, uid);
  return createSession(db, uid, data);
}

/** Returns Host-authorized state without reading live runtime data. */
export async function getEventRehearsalBootstrapHandler(
  request: CallableRequest<unknown>
): Promise<EventRehearsalBootstrapCallableResponse> {
  const uid = requireAuth(request);
  const data = validateCallableWithAjv<
    GetEventRehearsalBootstrapCallablePayload
  >(
    request,
    validateGetEventRehearsalBootstrapCallablePayload
  );
  const db = admin.firestore();
  await checkRateLimit(db, uid, "getEventRehearsalBootstrap");
  const session = await requireHostSession(db, data.sessionId, uid);
  await maybeApplyReadFault(session);
  return hostProjection(db, data.sessionId, session, request);
}

/** Updates the frozen safe snapshot while the rehearsal is not running. */
export async function updateEventRehearsalSetupHandler(
  request: CallableRequest<unknown>
): Promise<EventRehearsalBootstrapCallableResponse> {
  const uid = requireAuth(request);
  const data = validateCallableWithAjv<
    UpdateEventRehearsalSetupCallablePayload
  >(
    request,
    validateUpdateEventRehearsalSetupCallablePayload
  );
  const db = admin.firestore();
  await checkRateLimit(db, uid, "updateEventRehearsalSetup");
  await requireHostSession(db, data.sessionId, uid);
  const sessionRef = db.collection(sessions).doc(data.sessionId);
  const actorQuery = db.collection(actors)
    .where("sessionId", "==", data.sessionId);
  const guestViewQuery = db.collection(guestViews)
    .where("sessionId", "==", data.sessionId);
  await db.runTransaction(async (tx) => {
    const [snap, actorSnaps, guestViewSnaps] = await Promise.all([
      tx.get(sessionRef),
      tx.get(actorQuery),
      tx.get(guestViewQuery),
    ]);
    const session = requireSession(snap);
    if (!["draft", "ready"].includes(session.status)) {
      throw new HttpsError(
        "failed-precondition",
        "Setup is frozen after a rehearsal starts. Reset or fork the run."
      );
    }
    if (session.setupRevision !== data.expectedRevision) {
      throw staleRevision(session.setupRevision);
    }
    const now = admin.firestore.Timestamp.now();
    const nextActors = buildRehearsalActors(
      data.sessionId,
      data.actorCount,
      session.seed,
      now
    );
    const nextActorDocumentIds = new Set(nextActors.map((actor) =>
      actorDocumentId(data.sessionId, actor.actorId)
    ));
    tx.update(sessionRef, {
      setup: {
        ...data.setup,
        ...(session.setup.movementSimulation &&
            !data.setup.movementSimulation ? {
            movementSimulation: session.setup.movementSimulation,
          } : {}),
      },
      scenarioId: data.scenarioId,
      actorCount: data.actorCount,
      setupRevision: session.setupRevision + 1,
      updatedAt: now,
    });
    for (const actorSnap of actorSnaps.docs) {
      if (!nextActorDocumentIds.has(actorSnap.id)) tx.delete(actorSnap.ref);
    }
    for (const actor of nextActors) {
      tx.set(
        db.collection(actors).doc(
          actorDocumentId(data.sessionId, actor.actorId)
        ),
        actor
      );
    }
    for (const guestViewSnap of guestViewSnaps.docs) {
      tx.delete(guestViewSnap.ref);
    }
  });
  return hostProjection(
    db,
    data.sessionId,
    await requireHostSession(db, data.sessionId, uid),
    request
  );
}

/** Applies lifecycle, playbook-step, and virtual-clock actions atomically. */
export async function controlEventRehearsalHandler(
  request: CallableRequest<unknown>
): Promise<EventRehearsalBootstrapCallableResponse> {
  const uid = requireAuth(request);
  const data = validateCallableWithAjv<ControlEventRehearsalCallablePayload>(
    request,
    validateControlEventRehearsalCallablePayload
  );
  const db = admin.firestore();
  await checkRateLimit(db, uid, "controlEventRehearsal");
  const authorized = await requireHostSession(db, data.sessionId, uid);
  const sessionRef = db.collection(sessions).doc(data.sessionId);
  const actorQuery = db.collection(actors)
    .where("sessionId", "==", data.sessionId);
  const actionRef = db.collection(actions)
    .doc(eventRehearsalActionDocumentId(
      data.sessionId,
      "host",
      data.clientActionId
    ));
  if ((await actionRef.get()).exists) {
    return hostProjection(db, data.sessionId, authorized, request);
  }
  await maybeApplyActionFault(db, data.sessionId, authorized);
  await db.runTransaction(async (tx) => {
    const [sessionSnap, actorSnaps, actionSnap] = await Promise.all([
      tx.get(sessionRef),
      tx.get(actorQuery),
      tx.get(actionRef),
    ]);
    if (actionSnap.exists) return;
    const session = requireSession(sessionSnap);
    assertActionCapacity(session);
    assertCurrentRevision(session, data.expectedRevision);
    if (actorSnaps.size > 50) {
      throw new HttpsError(
        "resource-exhausted",
        "Rehearsal roster is too large."
      );
    }
    const resolved = resolveControlOrThrow(session, data);
    const now = admin.firestore.Timestamp.now();
    const virtualNow = admin.firestore.Timestamp.fromMillis(
      resolved.virtualNowMillis
    );
    const nextRevision = session.runtimeRevision + 1;
    tx.update(sessionRef, {
      status: resolved.status,
      activeStepIndex: resolved.activeStepIndex,
      virtualNow,
      runtimeRevision: nextRevision,
      actionCount: session.actionCount + 1,
      updatedAt: now,
      completedAt: resolved.status === "complete" ? now : null,
    });
    const actorDocuments = actorSnaps.docs.map((doc) => ({
      ref: doc.ref,
      value: requireDoc<EventRehearsalActorDocument>(
        doc,
        "EventRehearsalActorDocument"
      ),
    })).sort((a, b) => a.value.actorId.localeCompare(b.value.actorId));
    const cueMap = new Map<number, ReturnType<typeof cuesBetween>[number]>();
    if (data.action === "advanceClock") {
      for (const cue of cuesBetween(
        session.scenarioId,
        session.virtualStartedAt.toMillis(),
        session.virtualNow.toMillis(),
        resolved.virtualNowMillis
      )) {
        cueMap.set(cue.actorIndex, cue);
      }
    }
    for (const [index, actor] of actorDocuments.entries()) {
      const cue = cueMap.get(index);
      const atMoment = actorAtMoment(
        actor.value,
        momentForStep(resolved.activeStepIndex),
        now
      );
      const next = cue ? applyRehearsalBehavior(
        atMoment,
        cue.behavior,
        actorDocuments.map((item) => item.value.actorId),
        now
      ) : atMoment;
      tx.set(actor.ref, next);
    }
    tx.create(actionRef, actionDocument({
      sessionId: data.sessionId,
      clientActionId: data.clientActionId,
      actorUid: uid,
      actorId: null,
      kind: "control",
      name: data.action,
      runtimeRevision: nextRevision,
      virtualNow,
      createdAt: now,
    }));
  });
  return hostProjection(
    db,
    data.sessionId,
    await requireHostSession(db, data.sessionId, uid),
    request
  );
}

/** Injects a behavior or a privileged QA fault into the isolated domain. */
export async function injectEventRehearsalBehaviorHandler(
  request: CallableRequest<unknown>
): Promise<EventRehearsalBootstrapCallableResponse> {
  const uid = requireAuth(request);
  const data =
    validateCallableWithAjv<InjectEventRehearsalBehaviorCallablePayload>(
      request,
      validateInjectEventRehearsalBehaviorCallablePayload
    );
  const db = admin.firestore();
  await checkRateLimit(db, uid, "injectEventRehearsalBehavior");
  await requireHostSession(db, data.sessionId, uid);
  if (data.faultId !== "none" && !canUseInternalFaults(request)) {
    throw new HttpsError(
      "permission-denied",
      "Advanced fault injection is limited to internal QA accounts."
    );
  }
  const sessionRef = db.collection(sessions).doc(data.sessionId);
  const actionRef = db.collection(actions)
    .doc(eventRehearsalActionDocumentId(
      data.sessionId,
      "host",
      data.clientActionId
    ));
  const actorRef = data.actorId ?
    db.collection(actors).doc(actorDocumentId(data.sessionId, data.actorId)) :
    null;
  const actorQuery = db.collection(actors)
    .where("sessionId", "==", data.sessionId);
  await db.runTransaction(async (tx) => {
    const reads = await Promise.all([
      tx.get(sessionRef),
      tx.get(actionRef),
      tx.get(actorQuery),
      ...(actorRef ? [tx.get(actorRef)] : []),
    ]);
    const session = requireSession(
      reads[0] as FirebaseFirestore.DocumentSnapshot
    );
    const actionSnap = reads[1] as FirebaseFirestore.DocumentSnapshot;
    const actorSnaps = reads[2] as FirebaseFirestore.QuerySnapshot;
    if (actionSnap.exists) return;
    assertActionCapacity(session);
    assertCurrentRevision(session, data.expectedRevision);
    if (data.behavior && !["running", "paused"].includes(session.status)) {
      throw new HttpsError(
        "failed-precondition",
        "Synthetic guest behavior is available only while the rehearsal " +
          "is running or paused."
      );
    }
    const now = admin.firestore.Timestamp.now();
    const nextRevision = session.runtimeRevision + 1;
    if (data.behavior) {
      if (!actorRef) {
        throw new HttpsError("invalid-argument", "actorId is required.");
      }
      const actorSnap = reads[3] as FirebaseFirestore.DocumentSnapshot;
      if (!actorSnap?.exists) {
        throw new HttpsError("not-found", "Synthetic actor not found.");
      }
      const actor = requireDoc<EventRehearsalActorDocument>(
        actorSnap,
        "EventRehearsalActorDocument"
      );
      tx.set(actorRef, applyRehearsalBehavior(
        actor,
        data.behavior,
        actorSnaps.docs.map((doc) =>
          requireDoc<EventRehearsalActorDocument>(
            doc,
            "EventRehearsalActorDocument"
          ).actorId
        ),
        now
      ));
    }
    tx.update(sessionRef, {
      faultId: data.faultId,
      faultConsumed: false,
      runtimeRevision: nextRevision,
      actionCount: session.actionCount + 1,
      updatedAt: now,
    });
    tx.create(actionRef, actionDocument({
      sessionId: data.sessionId,
      clientActionId: data.clientActionId,
      actorUid: uid,
      actorId: data.actorId,
      kind: "behavior",
      name: data.behavior ?? `fault:${data.faultId}`,
      runtimeRevision: nextRevision,
      virtualNow: session.virtualNow,
      createdAt: now,
    }));
  });
  return hostProjection(
    db,
    data.sessionId,
    await requireHostSession(db, data.sessionId, uid),
    request
  );
}

/** Persists a revision-fenced Room placement for one synthetic actor. */
export async function controlEventRehearsalSpatialHandler(
  request: CallableRequest<unknown>
): Promise<EventRehearsalBootstrapCallableResponse> {
  const uid = requireAuth(request);
  const data = validateCallableWithAjv<
    ControlEventRehearsalSpatialCallablePayload
  >(request, validateControlEventRehearsalSpatialCallablePayload);
  const db = admin.firestore();
  await checkRateLimit(db, uid, "controlEventRehearsalSpatial");
  await requireHostSession(db, data.sessionId, uid);
  const sessionRef = db.collection(sessions).doc(data.sessionId);
  const actorRef = db.collection(actors)
    .doc(actorDocumentId(data.sessionId, data.actorId));
  const actionRef = db.collection(actions)
    .doc(eventRehearsalActionDocumentId(
      data.sessionId,
      "host-spatial",
      data.clientActionId
    ));
  await db.runTransaction(async (tx) => {
    const [sessionSnap, actorSnap, actionSnap] = await Promise.all([
      tx.get(sessionRef),
      tx.get(actorRef),
      tx.get(actionRef),
    ]);
    if (actionSnap.exists) return;
    const session = requireSession(sessionSnap);
    assertActionCapacity(session);
    assertCurrentRevision(session, data.expectedRevision);
    if (!["running", "paused"].includes(session.status)) {
      throw new HttpsError(
        "failed-precondition",
        "Room placement is available only while the rehearsal is running " +
          "or paused."
      );
    }
    if (!actorSnap.exists) {
      throw new HttpsError("not-found", "Synthetic actor not found.");
    }
    const actor = requireDoc<EventRehearsalActorDocument>(
      actorSnap,
      "EventRehearsalActorDocument"
    );
    const now = admin.firestore.Timestamp.now();
    let nextActor: EventRehearsalActorDocument;
    try {
      nextActor = applyRehearsalSpatialAction(
        actor,
        data.action,
        data.destinationUnitId,
        data.scope,
        Math.max(1, Math.ceil(session.actorCount / 4)),
        now
      );
    } catch (error) {
      throw new HttpsError(
        "invalid-argument",
        error instanceof Error ? error.message : "Invalid Room placement."
      );
    }
    const nextRevision = session.runtimeRevision + 1;
    tx.set(actorRef, nextActor);
    tx.update(sessionRef, {
      runtimeRevision: nextRevision,
      actionCount: session.actionCount + 1,
      updatedAt: now,
    });
    tx.create(actionRef, actionDocument({
      sessionId: data.sessionId,
      clientActionId: data.clientActionId,
      actorUid: uid,
      actorId: data.actorId,
      kind: "spatial",
      name: data.destinationUnitId ?
        `${data.action}:${data.destinationUnitId}` : data.action,
      runtimeRevision: nextRevision,
      virtualNow: session.virtualNow,
      createdAt: now,
    }));
  });
  return hostProjection(
    db,
    data.sessionId,
    await requireHostSession(db, data.sessionId, uid),
    request
  );
}

/** Resets the current run or forks the frozen setup to a new session. */
export async function resetEventRehearsalHandler(
  request: CallableRequest<unknown>
): Promise<
  CreateEventRehearsalCallableResponse |
  EventRehearsalBootstrapCallableResponse
> {
  const uid = requireAuth(request);
  const data = validateCallableWithAjv<ResetEventRehearsalCallablePayload>(
    request,
    validateResetEventRehearsalCallablePayload
  );
  const db = admin.firestore();
  await checkRateLimit(db, uid, "resetEventRehearsal");
  const session = await requireHostSession(db, data.sessionId, uid);
  if (data.fork) {
    await assertActiveSessionLimit(db, uid);
    return createSession(db, uid, {
      organizerId: session.organizerId,
      sourceEventId: session.sourceEventId,
      scenarioId: session.scenarioId,
      seed: data.seed ?? session.seed,
      actorCount: session.actorCount,
    }, {
      setup: session.setup,
      sourceEventRevision: session.sourceEventRevision,
    });
  }
  await deleteSessionChildren(db, data.sessionId);
  const now = admin.firestore.Timestamp.now();
  await db.collection(sessions).doc(data.sessionId).update({
    seed: data.seed ?? session.seed,
    status: "draft",
    setupRevision: session.setupRevision + 1,
    runtimeRevision: 0,
    actionCount: 0,
    activeStepIndex: 0,
    virtualNow: now,
    virtualStartedAt: now,
    faultId: "none",
    faultConsumed: false,
    completedAt: null,
    updatedAt: now,
    expiresAt: admin.firestore.Timestamp.fromMillis(
      now.toMillis() + REHEARSAL_RETENTION_MILLIS
    ),
  });
  await writeActors(
    db,
    data.sessionId,
    buildRehearsalActors(
      data.sessionId,
      session.actorCount,
      data.seed ?? session.seed,
      now
    )
  );
  return hostProjection(
    db,
    data.sessionId,
    await requireHostSession(db, data.sessionId, uid),
    request
  );
}

/** Rotates the public id and secret, revoking existing guest slots. */
export async function rotateEventRehearsalGuestLinkHandler(
  request: CallableRequest<unknown>
): Promise<EventRehearsalBootstrapCallableResponse> {
  const uid = requireAuth(request);
  const data =
    validateCallableWithAjv<RotateEventRehearsalGuestLinkCallablePayload>(
      request,
      validateRotateEventRehearsalGuestLinkCallablePayload
    );
  const db = admin.firestore();
  await checkRateLimit(db, uid, "rotateEventRehearsalGuestLink");
  await requireHostSession(db, data.sessionId, uid);
  await deleteBySession(db, guestViews, data.sessionId);
  const publicRehearsalId = randomToken(24);
  await db.collection(sessions).doc(data.sessionId).update({
    publicRehearsalId,
    viewerTokenHash: sha256(publicRehearsalId),
    updatedAt: admin.firestore.Timestamp.now(),
  });
  const next = await requireHostSession(db, data.sessionId, uid);
  return hostProjection(db, data.sessionId, next, request);
}

/** Redeems a share secret into a short-lived anonymous synthetic guest slot. */
export async function getEventRehearsalGuestBootstrapHandler(
  request: CallableRequest<unknown>
): Promise<EventRehearsalGuestBootstrapCallableResponse> {
  const data =
    validateCallableWithAjv<GetEventRehearsalGuestBootstrapCallablePayload>(
      request,
      validateGetEventRehearsalGuestBootstrapCallablePayload
    );
  const db = admin.firestore();
  await checkRateLimit(
    db,
    guestRateLimitIdentity(data.publicRehearsalId, data.clientInstanceId),
    "getEventRehearsalGuestBootstrap"
  );
  const resolved = await resolvePublicSession(db, data.publicRehearsalId);
  await maybeApplyGuestReadFault(resolved.session);
  const view = await resolveOrRedeemGuestView({
    db,
    sessionId: resolved.id,
    session: resolved.session,
    clientInstanceId: data.clientInstanceId,
    viewerToken: data.viewerToken,
    slotToken: data.slotToken,
  });
  const actorSnap = await db.collection(actors)
    .doc(actorDocumentId(resolved.id, view.actorId)).get();
  if (!actorSnap.exists) {
    throw new HttpsError("not-found", "Practice guest is no longer available.");
  }
  await db.collection(guestViews).doc(
    guestViewDocumentId(resolved.id, view.slotId)
  ).update({lastSeenAt: admin.firestore.Timestamp.now()});
  return rehearsalGuestProjection(
    resolved.session,
    requireDoc<EventRehearsalActorDocument>(
      actorSnap,
      "EventRehearsalActorDocument"
    ),
    view.slotToken
  );
}

/** Applies a guest action only to the slot's synthetic actor. */
export async function submitEventRehearsalGuestActionHandler(
  request: CallableRequest<unknown>
): Promise<EventRehearsalGuestBootstrapCallableResponse> {
  const data =
    validateCallableWithAjv<SubmitEventRehearsalGuestActionCallablePayload>(
      request,
      validateSubmitEventRehearsalGuestActionCallablePayload
    );
  const db = admin.firestore();
  await checkRateLimit(
    db,
    guestRateLimitIdentity(data.publicRehearsalId, data.slotToken),
    "submitEventRehearsalGuestAction"
  );
  const resolved = await resolvePublicSession(db, data.publicRehearsalId);
  const slotId = data.slotToken.slice(0, 24);
  const viewRef = db.collection(guestViews)
    .doc(guestViewDocumentId(resolved.id, slotId));
  const sessionRef = db.collection(sessions).doc(resolved.id);
  const actionRef = db.collection(actions)
    .doc(eventRehearsalActionDocumentId(
      resolved.id,
      `guest-${slotId}`,
      data.clientActionId
    ));
  let actorId: string | null = null;
  await db.runTransaction(async (tx) => {
    const [sessionSnap, viewSnap, actionSnap] = await Promise.all([
      tx.get(sessionRef),
      tx.get(viewRef),
      tx.get(actionRef),
    ]);
    if (actionSnap.exists) return;
    const session = requireSession(sessionSnap);
    if (session.publicRehearsalId !== data.publicRehearsalId) {
      throw new HttpsError(
        "permission-denied",
        "Dress rehearsal link expired."
      );
    }
    const view = requireGuestViewSnapshot(viewSnap, data.slotToken);
    actorId = view.actorId;
    const actorRef = db.collection(actors)
      .doc(actorDocumentId(resolved.id, view.actorId));
    const actorSnap = await tx.get(actorRef);
    assertActionCapacity(session);
    if (!["running", "paused"].includes(session.status)) {
      throw new HttpsError(
        "failed-precondition",
        "Guest controls are available only while the dress rehearsal is " +
          "running or paused."
      );
    }
    if (!actorSnap.exists) {
      throw new HttpsError("not-found", "Practice guest not found.");
    }
    const actor = requireDoc<EventRehearsalActorDocument>(
      actorSnap,
      "EventRehearsalActorDocument"
    );
    const now = admin.firestore.Timestamp.now();
    const nextRevision = session.runtimeRevision + 1;
    tx.set(actorRef, applyRehearsalGuestAction(actor, data.action, now));
    tx.update(sessionRef, {
      runtimeRevision: nextRevision,
      actionCount: session.actionCount + 1,
      updatedAt: now,
    });
    tx.create(actionRef, actionDocument({
      sessionId: resolved.id,
      clientActionId: data.clientActionId,
      actorUid: null,
      actorId: actor.actorId,
      kind: "guest",
      name: data.action,
      runtimeRevision: nextRevision,
      virtualNow: session.virtualNow,
      createdAt: now,
    }));
  });
  const latest = await requirePublicSessionById(db, resolved.id);
  if (!actorId) {
    const existingAction = requireDoc<EventRehearsalActionDocument>(
      await actionRef.get(),
      "EventRehearsalActionDocument"
    );
    actorId = existingAction.actorId;
  }
  if (!actorId) {
    throw new HttpsError("not-found", "Practice guest not found.");
  }
  const actorSnap = await db.collection(actors)
    .doc(actorDocumentId(resolved.id, actorId)).get();
  return rehearsalGuestProjection(
    latest,
    requireDoc<EventRehearsalActorDocument>(
      actorSnap,
      "EventRehearsalActorDocument"
    ),
    data.slotToken
  );
}

/** Completes a rehearsal through the Host-control lifecycle invariant. */
export async function completeEventRehearsalHandler(
  request: CallableRequest<unknown>
): Promise<EventRehearsalBootstrapCallableResponse> {
  const uid = requireAuth(request);
  const data = validateCallableWithAjv<
    GetEventRehearsalBootstrapCallablePayload
  >(
    request,
    validateGetEventRehearsalBootstrapCallablePayload
  );
  const db = admin.firestore();
  await checkRateLimit(db, uid, "completeEventRehearsal");
  await requireHostSession(db, data.sessionId, uid);
  const sessionRef = db.collection(sessions).doc(data.sessionId);
  const actorQuery = db.collection(actors)
    .where("sessionId", "==", data.sessionId);
  const actionRef = db.collection(actions).doc(
    eventRehearsalActionDocumentId(
      data.sessionId,
      "system",
      "system_complete"
    )
  );
  await db.runTransaction(async (tx) => {
    const [sessionSnap, actorSnaps, actionSnap] = await Promise.all([
      tx.get(sessionRef),
      tx.get(actorQuery),
      tx.get(actionRef),
    ]);
    const session = requireSession(sessionSnap);
    if (session.status === "complete" || actionSnap.exists) return;
    assertActionCapacity(session);
    const resolved = resolveControlOrThrow(session, {
      sessionId: data.sessionId,
      expectedRevision: session.runtimeRevision,
      clientActionId: "system_complete",
      action: "complete",
    });
    const now = admin.firestore.Timestamp.now();
    const nextRevision = session.runtimeRevision + 1;
    tx.update(sessionRef, {
      status: resolved.status,
      activeStepIndex: resolved.activeStepIndex,
      runtimeRevision: nextRevision,
      actionCount: session.actionCount + 1,
      completedAt: now,
      updatedAt: now,
    });
    for (const actorDoc of actorSnaps.docs) {
      const actor = requireDoc<EventRehearsalActorDocument>(
        actorDoc,
        "EventRehearsalActorDocument"
      );
      tx.set(actorDoc.ref, actorAtMoment(actor, "complete", now));
    }
    tx.create(actionRef, actionDocument({
      sessionId: data.sessionId,
      clientActionId: "system_complete",
      actorUid: uid,
      actorId: null,
      kind: "control",
      name: "complete",
      runtimeRevision: nextRevision,
      virtualNow: session.virtualNow,
      createdAt: now,
    }));
  });
  return hostProjection(
    db,
    data.sessionId,
    await requireHostSession(db, data.sessionId, uid),
    request
  );
}

/** Exports deterministic setup and action history without personal data. */
export async function exportEventRehearsalReproductionHandler(
  request: CallableRequest<unknown>
): Promise<EventRehearsalReproductionCallableResponse> {
  const uid = requireAuth(request);
  const data = validateCallableWithAjv<
    GetEventRehearsalBootstrapCallablePayload
  >(
    request,
    validateGetEventRehearsalBootstrapCallablePayload
  );
  const db = admin.firestore();
  await checkRateLimit(db, uid, "exportEventRehearsalReproduction");
  const session = await requireHostSession(db, data.sessionId, uid);
  const actionSnaps = await db.collection(actions)
    .where("sessionId", "==", data.sessionId)
    .limit(REHEARSAL_MAX_ACTIONS)
    .get();
  return {
    schemaVersion: 1,
    sessionId: data.sessionId,
    scenarioId: session.scenarioId,
    seed: session.seed,
    setup: session.setup,
    actions: actionSnaps.docs.map((doc) => {
      const action = requireDoc<EventRehearsalActionDocument>(
        doc,
        "EventRehearsalActionDocument"
      );
      return {
        clientActionId: action.clientActionId,
        actorId: action.actorId,
        kind: action.kind,
        name: action.name,
        runtimeRevision: action.runtimeRevision,
        virtualNowMillis: action.virtualNow.toMillis(),
      };
    }).sort((a, b) => a.runtimeRevision - b.runtimeRevision),
  };
}

/** Hourly cleanup enforces the 24-hour product retention contract. */
export async function expireEventRehearsalsHandler(
  db: Firestore = admin.firestore(),
  now: FirebaseFirestore.Timestamp = admin.firestore.Timestamp.now()
): Promise<number> {
  const expired = await db.collection(sessions)
    .where("expiresAt", "<=", now).limit(200).get();
  for (const session of expired.docs) {
    await deleteSessionChildren(db, session.id);
    await session.ref.delete();
  }
  return expired.size;
}

async function createSession(
  db: Firestore,
  uid: string,
  data: CreateEventRehearsalCallablePayload,
  overrides: CreateOverrides = {}
): Promise<CreateEventRehearsalCallableResponse> {
  const now = admin.firestore.Timestamp.now();
  const sessionId = randomToken(18);
  const publicRehearsalId = randomToken(24);
  const source = data.sourceEventId ?
    await sourceSetup(db, data.organizerId, data.sourceEventId) : null;
  const setup = overrides.setup ?? source?.setup ?? sampleSetup();
  const session: EventRehearsalDocument = {
    organizerId: data.organizerId,
    clubId: source?.clubId ?? data.organizerId,
    ownerUid: uid,
    sourceEventId: data.sourceEventId,
    sourceEventRevision: overrides.sourceEventRevision ??
      source?.revision ?? null,
    publicRehearsalId,
    viewerTokenHash: sha256(publicRehearsalId),
    scenarioId: data.scenarioId,
    seed: data.seed,
    actorCount: data.actorCount,
    actionCount: 0,
    status: "draft",
    setup,
    setupRevision: 0,
    runtimeRevision: 0,
    activeStepIndex: 0,
    virtualStartedAt: now,
    virtualNow: now,
    faultId: "none",
    faultConsumed: false,
    createdAt: now,
    updatedAt: now,
    expiresAt: admin.firestore.Timestamp.fromMillis(
      now.toMillis() + REHEARSAL_RETENTION_MILLIS
    ),
    completedAt: null,
  };
  const syntheticActors = buildRehearsalActors(
    sessionId,
    data.actorCount,
    data.seed,
    now
  );
  const batch = db.batch();
  batch.create(db.collection(sessions).doc(sessionId), session);
  for (const actor of syntheticActors) {
    batch.set(
      db.collection(actors).doc(actorDocumentId(sessionId, actor.actorId)),
      actor
    );
  }
  await batch.commit();
  return {
    sessionId,
    guestUrl: guestUrl(publicRehearsalId),
    setupRevision: 0,
    runtimeRevision: 0,
  };
}

async function sourceSetup(
  db: Firestore,
  organizerId: string,
  eventId: string
): Promise<{setup: RehearsalSetup; clubId: string; revision: string}> {
  const snap = await db.collection("events").doc(eventId).get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Source event not found.");
  }
  const event = requireDoc<EventDocument>(snap, "EventDocument");
  const eventOrganizerId = event.organizerId ?? event.clubId;
  if (eventOrganizerId !== organizerId) {
    throw new HttpsError(
      "permission-denied",
      "The source event does not belong to this organizer."
    );
  }
  const durationMinutes = Math.max(
    30,
    Math.min(360, Math.round(
      (event.endTime.toMillis() - event.startTime.toMillis()) / 60000
    ))
  );
  const setup = rehearsalSetupFromEvent(event);
  return {
    clubId: event.clubId,
    revision: sha256(JSON.stringify({
      name: event.name ?? null,
      startTimeMillis: event.startTime.toMillis(),
      endTimeMillis: event.endTime.toMillis(),
      meetingLocation: event.meetingLocation,
      itinerary: event.itinerary ?? [],
      routePlan: event.eventFormat.activityDetails?.routePlan ?? null,
    })).slice(0, 32),
    setup: {...setup, durationMinutes},
  };
}

/** Builds a frozen rehearsal snapshot with synthetic movement only. */
export function rehearsalSetupFromEvent(event: EventDocument): RehearsalSetup {
  const routePlan = event.eventFormat.activityDetails?.routePlan ?? null;
  const itinerary = event.itinerary ?? [];
  const path = routePlan?.path ?? [];
  const trackingMode = routePlan?.version === 2 ?
    routePlan.liveTrackingPolicy?.mode ?? "disabled" : "disabled";
  const midpoint = path.length ? path[Math.floor(path.length / 2)] : null;
  const livePositions: NonNullable<
    RehearsalSetup["movementSimulation"]
  >["livePositions"] = midpoint && trackingMode !== "disabled" ? [{
    role: "host",
    latitude: midpoint.latitude,
    longitude: midpoint.longitude,
    recordedOffsetMinutes: 30,
  }, ...(trackingMode === "authorizedOperators" && path.length > 1 ? [{
    role: "operator" as const,
    latitude: path[0].latitude,
    longitude: path[0].longitude,
    recordedOffsetMinutes: 29,
  }] : [])] : [];
  const nextStop = itinerary.find((item) =>
    item.kind === "stop" || item.kind === "finish" || Boolean(item.location)
  );
  return {
    title: event.name?.trim() ||
      `${activityLabel(event.eventFormat.activityKind)} dress rehearsal`,
    locationName: event.meetingLocation.name || event.meetingPoint,
    durationMinutes: Math.max(
      30,
      Math.min(360, Math.round(
        (event.endTime.toMillis() - event.startTime.toMillis()) / 60000
      ))
    ),
    hostGoal: "Help every guest understand what happens next.",
    attendeePrompt: "Introduce yourself to someone you have not met yet.",
    moduleIds: [
      "arrival",
      "firstHello",
      "pods",
      "rotations",
      "conversationCues",
      "reveal",
      "afterglow",
      "accountability",
    ],
    ...(routePlan || itinerary.length ? {
      movementSimulation: {
        itinerary,
        routePlan,
        livePositions,
        lateArrivalGuidance: nextStop ?
          `Join at the next published stop: ${nextStop.title}.` :
          `Meet the route lead at ${event.meetingLocation.name}.`,
      },
    } : {}),
  };
}

function sampleSetup(): RehearsalSetup {
  return {
    title: "Catch social mixer dress rehearsal",
    locationName: "Practice venue",
    durationMinutes: 120,
    hostGoal: "Learn the whole Host flow before guests arrive.",
    attendeePrompt: "Find one thing you have in common with your group.",
    moduleIds: [
      "arrival",
      "firstHello",
      "pods",
      "rotations",
      "conversationCues",
      "reveal",
      "afterglow",
      "accountability",
    ],
  };
}

async function requireHostSession(
  db: Firestore,
  sessionId: string,
  uid: string
): Promise<EventRehearsalDocument> {
  const session = await requirePublicSessionById(db, sessionId);
  await requireOrganizerManager({
    db,
    organizerId: session.organizerId,
    actorUid: uid,
  });
  return session;
}

async function requirePublicSessionById(
  db: Firestore,
  sessionId: string
): Promise<EventRehearsalDocument> {
  const snap = await db.collection(sessions).doc(sessionId).get();
  const session = requireSession(snap);
  if (session.expiresAt.toMillis() <= Date.now()) {
    throw new HttpsError("not-found", "This dress rehearsal has expired.");
  }
  return session;
}

function requireSession(
  snap: FirebaseFirestore.DocumentSnapshot
): EventRehearsalDocument {
  if (!snap.exists) {
    throw new HttpsError("not-found", "Dress rehearsal not found.");
  }
  return requireDoc<EventRehearsalDocument>(snap, "EventRehearsalDocument");
}

async function hostProjection(
  db: Firestore,
  sessionId: string,
  session: EventRehearsalDocument,
  request: CallableRequest<unknown>,
): Promise<EventRehearsalBootstrapCallableResponse> {
  const [actorSnaps, actionSnaps] = await Promise.all([
    db.collection(actors).where("sessionId", "==", sessionId).limit(50).get(),
    db.collection(actions).where("sessionId", "==", sessionId)
      .limit(REHEARSAL_MAX_ACTIONS).get(),
  ]);
  const movementSimulation = rehearsalMovementProjection(session);
  return {
    session: {
      id: sessionId,
      organizerId: session.organizerId,
      sourceEventId: session.sourceEventId,
      scenarioId: session.scenarioId,
      seed: session.seed,
      actorCount: session.actorCount,
      actionCount: session.actionCount,
      status: session.status,
      setup: {
        ...session.setup,
        ...(movementSimulation ? {
          movementSimulation,
        } : {}),
      },
      setupRevision: session.setupRevision,
      runtimeRevision: session.runtimeRevision,
      activeStepIndex: session.activeStepIndex,
      virtualNowMillis: session.virtualNow.toMillis(),
      faultId: session.faultId,
      expiresAtMillis: session.expiresAt.toMillis(),
    },
    actors: actorSnaps.docs.map((doc) => {
      const actor = requireDoc<EventRehearsalActorDocument>(
        doc,
        "EventRehearsalActorDocument"
      );
      return {
        actorId: actor.actorId,
        displayName: actor.displayName,
        persona: actor.persona,
        status: actor.status,
        guestMoment: actor.guestMoment,
        optedOut: actor.optedOut,
        keepApartActorIds: actor.keepApartActorIds,
        helpRequested: actor.helpRequested,
        promptCompleted: actor.promptCompleted,
        layoutUnitId: actor.layoutUnitId,
        confirmedLayoutUnitId: actor.confirmedLayoutUnitId,
      };
    }).sort((a, b) => a.actorId.localeCompare(b.actorId)),
    actions: actionSnaps.docs.map((doc) => {
      const action = requireDoc<EventRehearsalActionDocument>(
        doc,
        "EventRehearsalActionDocument"
      );
      return {
        clientActionId: action.clientActionId,
        actorId: action.actorId,
        kind: action.kind,
        name: action.name,
        runtimeRevision: action.runtimeRevision,
        virtualNowMillis: action.virtualNow.toMillis(),
      };
    }).sort((a, b) => a.runtimeRevision - b.runtimeRevision),
    guestUrl: guestUrl(session.publicRehearsalId),
    canUseInternalFaults: canUseInternalFaults(request),
  };
}

export function rehearsalGuestProjection(
  session: EventRehearsalDocument,
  actor: EventRehearsalActorDocument,
  slotToken: string
): EventRehearsalGuestBootstrapCallableResponse {
  const movementSimulation = rehearsalMovementProjection(session);
  return {
    slotToken,
    practiceBanner: "Practice mode · Nothing here affects a real event",
    session: {
      title: session.setup.title,
      locationName: session.setup.locationName,
      status: session.status,
      activeStepIndex: session.activeStepIndex,
      virtualNowMillis: session.virtualNow.toMillis(),
      attendeePrompt: session.setup.attendeePrompt,
      moduleIds: session.setup.moduleIds,
      runtimeRevision: session.runtimeRevision,
      faultId: session.faultId,
      ...(movementSimulation ? {
        movementSimulation,
      } : {}),
    },
    actor: {
      actorId: actor.actorId,
      displayName: actor.displayName,
      status: actor.status,
      guestMoment: actor.guestMoment,
      optedOut: actor.optedOut,
      helpRequested: actor.helpRequested,
      promptCompleted: actor.promptCompleted,
    },
  };
}

/** Derives deterministic route progress from the virtual rehearsal clock. */
export function rehearsalMovementProjection(
  session: EventRehearsalDocument
): RehearsalSetup["movementSimulation"] {
  const movement = session.setup.movementSimulation;
  if (!movement) return undefined;
  const durationMinutes = Math.max(1, session.setup.durationMinutes);
  const virtualStartedAt = session.virtualStartedAt ?? session.virtualNow;
  const elapsedMinutes = Math.max(0, Math.min(
    durationMinutes,
    Math.floor(
      (session.virtualNow.toMillis() - virtualStartedAt.toMillis()) / 60000
    )
  ));
  const path = movement.routePlan?.path ?? [];
  const progressIndex = path.length > 1 ? Math.min(
    path.length - 1,
    Math.round((elapsedMinutes / durationMinutes) * (path.length - 1))
  ) : 0;
  return {
    ...movement,
    livePositions: movement.livePositions.map((position, index) => {
      const point = path.length ? path[Math.max(0, progressIndex - index)] :
        position;
      return {
        ...position,
        latitude: point.latitude,
        longitude: point.longitude,
        recordedOffsetMinutes: Math.max(0, elapsedMinutes - index),
      };
    }),
  };
}

async function resolvePublicSession(
  db: Firestore,
  publicRehearsalId: string
): Promise<{id: string; session: EventRehearsalDocument}> {
  const snaps = await db.collection(sessions)
    .where("publicRehearsalId", "==", publicRehearsalId).limit(1).get();
  if (snaps.empty) {
    throw new HttpsError("not-found", "Dress rehearsal link not found.");
  }
  const snap = snaps.docs[0];
  if (!snap) {
    throw new HttpsError("not-found", "Dress rehearsal link not found.");
  }
  const session = requireSession(snap);
  if (session.expiresAt.toMillis() <= Date.now()) {
    throw new HttpsError("not-found", "This dress rehearsal link has expired.");
  }
  return {id: snap.id, session};
}

async function redeemGuestView(
  db: Firestore,
  sessionId: string,
  session: EventRehearsalDocument,
  clientInstanceId: string,
  viewerToken: string | null
): Promise<EventRehearsalGuestViewDocument & {slotToken: string}> {
  const bearerToken = viewerToken ?? session.publicRehearsalId;
  if (!safeHashEquals(session.viewerTokenHash, sha256(bearerToken))) {
    throw new HttpsError(
      "permission-denied",
      "Dress rehearsal link is invalid."
    );
  }
  const slotId = sha256(`${sessionId}:${clientInstanceId}`).slice(0, 24);
  const slotToken = `${slotId}_${sha256(
    `${session.viewerTokenHash}:${clientInstanceId}`
  ).slice(0, 40)}`;
  const viewRef = db.collection(guestViews)
    .doc(guestViewDocumentId(sessionId, slotId));
  const actorQuery = db.collection(actors)
    .where("sessionId", "==", sessionId).limit(50);
  const viewQuery = db.collection(guestViews)
    .where("sessionId", "==", sessionId).limit(50);
  return db.runTransaction(async (tx) => {
    const [existing, actorSnaps, viewSnaps] = await Promise.all([
      tx.get(viewRef),
      tx.get(actorQuery),
      tx.get(viewQuery),
    ]);
    if (existing.exists) {
      const view = requireDoc<EventRehearsalGuestViewDocument>(
        existing,
        "EventRehearsalGuestViewDocument"
      );
      if (!safeHashEquals(view.tokenHash, sha256(slotToken))) {
        throw new HttpsError("permission-denied", "Guest slot is invalid.");
      }
      return {...view, slotToken};
    }
    const claimed = new Set(viewSnaps.docs.map((doc) =>
      requireDoc<EventRehearsalGuestViewDocument>(
        doc,
        "EventRehearsalGuestViewDocument"
      ).actorId
    ));
    const sortedActors = actorSnaps.docs.map((doc) =>
      requireDoc<EventRehearsalActorDocument>(
        doc,
        "EventRehearsalActorDocument"
      )
    ).sort((a, b) => a.actorId.localeCompare(b.actorId));
    const actor = sortedActors.find((candidate) =>
      !claimed.has(candidate.actorId)
    ) ?? sortedActors[viewSnaps.size % Math.max(1, sortedActors.length)];
    if (!actor) {
      throw new HttpsError("not-found", "No practice guests are available.");
    }
    const now = admin.firestore.Timestamp.now();
    const view: EventRehearsalGuestViewDocument = {
      sessionId,
      slotId,
      actorId: actor.actorId,
      tokenHash: sha256(slotToken),
      createdAt: now,
      lastSeenAt: now,
      expiresAt: session.expiresAt,
    };
    tx.create(viewRef, view);
    return {...view, slotToken};
  });
}

async function resolveOrRedeemGuestView({
  db,
  sessionId,
  session,
  clientInstanceId,
  viewerToken,
  slotToken,
}: {
  db: Firestore;
  sessionId: string;
  session: EventRehearsalDocument;
  clientInstanceId: string;
  viewerToken: string | null;
  slotToken: string | null;
}): Promise<EventRehearsalGuestViewDocument & {slotToken: string}> {
  if (slotToken) {
    try {
      return await requireGuestView(db, sessionId, slotToken);
    } catch (error) {
      if (
        !(error instanceof HttpsError) ||
        error.code !== "permission-denied"
      ) {
        throw error;
      }
      // Setup changes and reset intentionally revoke prior actor leases. The
      // The still-valid public link can redeem this browser deterministically.
    }
  }
  return redeemGuestView(
    db,
    sessionId,
    session,
    clientInstanceId,
    viewerToken
  );
}

async function requireGuestView(
  db: Firestore,
  sessionId: string,
  slotToken: string
): Promise<EventRehearsalGuestViewDocument & {slotToken: string}> {
  const slotId = slotToken.slice(0, 24);
  const snap = await db.collection(guestViews)
    .doc(guestViewDocumentId(sessionId, slotId)).get();
  return {
    ...requireGuestViewSnapshot(snap, slotToken),
    slotToken,
  };
}

function requireGuestViewSnapshot(
  snap: FirebaseFirestore.DocumentSnapshot,
  slotToken: string
): EventRehearsalGuestViewDocument {
  if (!snap.exists) {
    throw new HttpsError("permission-denied", "Guest slot expired.");
  }
  const view = requireDoc<EventRehearsalGuestViewDocument>(
    snap,
    "EventRehearsalGuestViewDocument"
  );
  if (!safeHashEquals(view.tokenHash, sha256(slotToken)) ||
      view.expiresAt.toMillis() <= Date.now()) {
    throw new HttpsError("permission-denied", "Guest slot expired.");
  }
  return view;
}

async function assertActiveSessionLimit(
  db: Firestore,
  uid: string
): Promise<void> {
  const snaps = await db.collection(sessions)
    .where("ownerUid", "==", uid).limit(100).get();
  const active = snaps.docs.map((doc) =>
    requireDoc<EventRehearsalDocument>(doc, "EventRehearsalDocument")
  ).filter((session) =>
    session.expiresAt.toMillis() > Date.now() &&
    !["complete", "expired"].includes(session.status)
  );
  if (active.length >= REHEARSAL_MAX_ACTIVE_SESSIONS) {
    throw new HttpsError(
      "resource-exhausted",
      "Complete or wait for an existing dress rehearsal before creating " +
        "another."
    );
  }
}

async function writeActors(
  db: Firestore,
  sessionId: string,
  values: EventRehearsalActorDocument[]
): Promise<void> {
  const batch = db.batch();
  for (const actor of values) {
    batch.set(
      db.collection(actors).doc(actorDocumentId(sessionId, actor.actorId)),
      actor
    );
  }
  await batch.commit();
}

async function deleteSessionChildren(
  db: Firestore,
  sessionId: string
): Promise<void> {
  await Promise.all([
    deleteBySession(db, actors, sessionId),
    deleteBySession(db, actions, sessionId),
    deleteBySession(db, guestViews, sessionId),
  ]);
}

async function deleteBySession(
  db: Firestore,
  collection: string,
  sessionId: string
): Promise<void> {
  const snaps = await db.collection(collection)
    .where("sessionId", "==", sessionId).limit(500).get();
  if (snaps.empty) return;
  const batch = db.batch();
  for (const doc of snaps.docs) batch.delete(doc.ref);
  await batch.commit();
}

function actionDocument(
  value: EventRehearsalActionDocument
): EventRehearsalActionDocument {
  return value;
}

function assertCurrentRevision(
  session: EventRehearsalDocument,
  expectedRevision: number
): void {
  if (session.runtimeRevision !== expectedRevision) {
    throw staleRevision(session.runtimeRevision);
  }
}

function assertActionCapacity(session: EventRehearsalDocument): void {
  if (session.actionCount >= REHEARSAL_MAX_ACTIONS) {
    throw new HttpsError(
      "resource-exhausted",
      "This rehearsal reached its 500-action limit. Reset or fork to continue."
    );
  }
}

function staleRevision(current: number): HttpsError {
  return new HttpsError(
    "aborted",
    `This rehearsal changed on another screen. Refresh revision ${current}.`
  );
}

function resolveControlOrThrow(
  session: EventRehearsalDocument,
  data: ControlEventRehearsalCallablePayload
) {
  try {
    return resolveRehearsalControl(session, data.action, data.minutes ?? 5);
  } catch (error) {
    throw new HttpsError(
      "failed-precondition",
      error instanceof Error ? error.message : "Invalid rehearsal transition."
    );
  }
}

async function maybeApplyActionFault(
  db: Firestore,
  sessionId: string,
  session: EventRehearsalDocument
): Promise<void> {
  if (session.faultId === "latency") await delay(1500);
  if (session.faultId === "staleRevision") {
    throw new HttpsError("aborted", "Injected stale revision conflict.");
  }
  if (session.faultId === "oneShotFailure" && !session.faultConsumed) {
    await db.collection(sessions).doc(sessionId).update({
      faultConsumed: true,
      updatedAt: admin.firestore.Timestamp.now(),
    });
    throw new HttpsError(
      "unavailable",
      "Injected one-shot failure. Retry is safe."
    );
  }
}

async function maybeApplyReadFault(
  session: EventRehearsalDocument
): Promise<void> {
  if (session.faultId === "latency") await delay(1000);
}

async function maybeApplyGuestReadFault(
  session: EventRehearsalDocument
): Promise<void> {
  if (session.faultId === "listenerDisconnect") {
    throw new HttpsError(
      "unavailable",
      "Injected listener disconnect. The guest view will retry."
    );
  }
  if (session.faultId === "lowBandwidth") await delay(1200);
}

function canUseInternalFaults(request: CallableRequest<unknown>): boolean {
  const token = request.auth?.token as Record<string, unknown> | undefined;
  return token?.internalQa === true || adminRolesFromToken(token).length > 0;
}

function actorDocumentId(sessionId: string, actorId: string): string {
  return `${sessionId}_${actorId}`;
}

function guestViewDocumentId(sessionId: string, slotId: string): string {
  return `${sessionId}_${slotId}`;
}

function guestUrl(publicRehearsalId: string): string {
  return `${websiteBaseUrl}/rehearse/${publicRehearsalId}`;
}

function guestRateLimitIdentity(
  publicRehearsalId: string,
  clientIdentity: string
): string {
  return `rehearsal_${sha256(`${publicRehearsalId}:${clientIdentity}`)
    .slice(0, 40)}`;
}

function randomToken(bytes: number): string {
  return randomBytes(bytes).toString("base64url");
}

function sha256(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

function safeHashEquals(expected: string, actual: string): boolean {
  if (expected.length !== actual.length) return false;
  return timingSafeEqual(Buffer.from(expected), Buffer.from(actual));
}

function activityLabel(value: EventDocument["discoveryActivityKind"]): string {
  return value.replace(/([a-z])([A-Z])/gu, "$1 $2")
    .replace(/^./u, (letter) => letter.toUpperCase());
}

function delay(milliseconds: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

export const createEventRehearsal = onCall(
  appCheckCallableOptions,
  createEventRehearsalHandler
);
export const getEventRehearsalBootstrap = onCall(
  appCheckCallableOptionsWithLimits({memory: "512MiB"}),
  getEventRehearsalBootstrapHandler
);
export const updateEventRehearsalSetup = onCall(
  appCheckCallableOptions,
  updateEventRehearsalSetupHandler
);
export const controlEventRehearsal = onCall(
  appCheckCallableOptions,
  controlEventRehearsalHandler
);
export const injectEventRehearsalBehavior = onCall(
  appCheckCallableOptions,
  injectEventRehearsalBehaviorHandler
);
export const controlEventRehearsalSpatial = onCall(
  appCheckCallableOptions,
  controlEventRehearsalSpatialHandler
);
export const resetEventRehearsal = onCall(
  appCheckCallableOptions,
  resetEventRehearsalHandler
);
export const rotateEventRehearsalGuestLink = onCall(
  appCheckCallableOptions,
  rotateEventRehearsalGuestLinkHandler
);
export const getEventRehearsalGuestBootstrap = onCall(
  appCheckCallableOptions,
  getEventRehearsalGuestBootstrapHandler
);
export const submitEventRehearsalGuestAction = onCall(
  appCheckCallableOptions,
  submitEventRehearsalGuestActionHandler
);
export const completeEventRehearsal = onCall(
  appCheckCallableOptions,
  completeEventRehearsalHandler
);
export const exportEventRehearsalReproduction = onCall(
  appCheckCallableOptions,
  exportEventRehearsalReproductionHandler
);
export const expireEventRehearsals = onSchedule(
  {schedule: "every 60 minutes", region: "asia-south1"},
  async () => {
    await expireEventRehearsalsHandler();
  }
);
