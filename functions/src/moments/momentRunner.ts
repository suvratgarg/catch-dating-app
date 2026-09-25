import type {Firestore} from "firebase-admin/firestore";
import {
  evaluateCondition,
  type TravelLegEvent,
} from "./momentConditions";
import {
  loadAnchorFacts,
  MOMENT_RUNS_COLLECTION,
  MOMENT_SENDS_COLLECTION,
  MOMENTS_COLLECTION,
  momentFromDocument,
  resolveMomentRecipients,
  runFromDocument,
  type ResolvedRecipient,
} from "./momentDocuments";
import {
  evaluateRecipientPolicy,
  rollupPolicy,
  type ConsentFacts,
  type PolicyDecision,
  type QuietHours,
} from "./momentPolicy";
import {
  planManualRun,
  replan,
  resolveFireDisposition,
  selectDueRuns,
} from "./momentPlanning";
import type {
  AnchorFacts,
  MomentAction,
  MomentDefinition,
  MomentScope,
  RunRecord,
} from "./momentModel";

/**
 * Server runner for the unified moments engine. Three entry points:
 *
 * - `runMomentSweep` — a scheduled pass that replans armed anchored/
 *   scheduled moments against current anchor facts (superseding stale
 *   runs when a function's time moved) and fires whatever is due.
 * - `ingestTravelLegEvent` — evaluates triggered moments against a travel
 *   fact (readiness / flight-status transition) and fires immediately.
 * - `runManualMoment` — fires a `manual` initiation keyed by the caller's
 *   request id, so a retried "send now" cannot double-send.
 *
 * Delivery is through injected seams — the engine decides *who* and
 * *whether* (policy), the callers own *how* (WhatsApp provider, FCM,
 * attention projection). Send records under organizerMomentSends make
 * every per-recipient decision idempotent and auditable.
 */

export interface MomentRunnerDeps {
  firestore: () => Firestore;
  nowMillis: () => number;
  /** Quiet-hours deferral: returns the local ms when sends may resume, or
   *  null when the scope is inside sendable time (or has no quiet hours). */
  quietEndMillis: (scope: MomentScope, nowMillis: number) =>
    number | null | Promise<number | null>;
  /** Local-time inputs for the per-endpoint daily cap and quiet hours. */
  localDayKey: (scope: MomentScope, nowMillis: number) =>
    string | Promise<string>;
  localMinuteOfDay: (scope: MomentScope, nowMillis: number) =>
    number | Promise<number>;
  quietHoursFor: (scope: MomentScope) =>
    QuietHours | null | Promise<QuietHours | null>;
  /** Maximum sends per recipient endpoint per local day; 0 disables. */
  dailyCapFor: (scope: MomentScope) => number | Promise<number>;
  /** Push copy is scope-shaped at fire time, not a stored template. */
  pushCopyFor: (
    moment: MomentDefinition,
    facts: AnchorFacts,
  ) => Promise<{title: string; body: string}>;
  sendTemplateToPhone: (params: {
    e164: string;
    connectionId: string;
    templateId: string;
    variables: Readonly<Record<string, string>>;
    runId: string;
    recipientKey: string;
  }) => Promise<void>;
  sendPushToUid: (params: {
    uid: string;
    title: string;
    body: string;
    notificationType: string;
    /** User notification preference gating the FCM leg only; the
     *  in-app activity item is written regardless (reminder parity). */
    preferenceKey: string;
    scope: MomentScope;
    runId: string;
    recipientKey: string;
  }) => Promise<void>;
  writeStaffAttention: (params: {
    /** The resolved staff member being notified. */
    uid: string;
    duty: string;
    scopeIds: ReadonlyArray<string> | null;
    severity: "info" | "warning" | "urgent";
    title: string;
    scope: MomentScope;
    runId: string;
  }) => Promise<void>;
  /** Live consent facts for a resolved recipient; the moment carries the
   *  preference key for uid endpoints. */
  loadConsentFacts: (recipient: ResolvedRecipient,
    moment: MomentDefinition) => Promise<ConsentFacts>;
}

export interface SweepSummary {
  momentsReplanned: number;
  runsCreated: number;
  runsSuperseded: number;
  runsFired: number;
  runsDeferred: number;
  runsSkipped: number;
}

const MAX_DUE_RUNS_PER_SWEEP = 200;
const MOMENT_SWEEP_LIMIT = 500;

/**
 * Replans every armed moment and fires due planned runs. Each moment is
 * handled independently — one bad document cannot stall the sweep.
 */
export async function runMomentSweep(
  deps: MomentRunnerDeps,
): Promise<SweepSummary> {
  const db = deps.firestore();
  const now = deps.nowMillis();
  const summary: SweepSummary = {
    momentsReplanned: 0,
    runsCreated: 0,
    runsSuperseded: 0,
    runsFired: 0,
    runsDeferred: 0,
    runsSkipped: 0,
  };

  const momentsSnap = await db.collection(MOMENTS_COLLECTION)
    .where("status", "==", "armed")
    .limit(MOMENT_SWEEP_LIMIT)
    .get();
  const factsCache = new Map<string, AnchorFacts | null>();
  const moments: MomentDefinition[] = [];
  for (const doc of momentsSnap.docs) {
    const moment = momentFromDocument(doc.data());
    if (moment !== null) moments.push(moment);
  }

  const factsFor = async (scope: MomentScope) => {
    const key = `${scope.kind}:${scope.kind === "event" ?
      scope.eventId : scope.programId}`;
    if (!factsCache.has(key)) {
      factsCache.set(key, await loadAnchorFacts(db, scope));
    }
    return factsCache.get(key) ?? null;
  };

  // Pass 1: (re)plan anchored/scheduled runs against current facts.
  for (const moment of moments) {
    if (moment.initiation.kind !== "anchored" &&
        moment.initiation.kind !== "scheduled") continue;
    const facts = await factsFor(moment.scope);
    if (facts === null) continue;
    const existing = await db.collection(MOMENT_RUNS_COLLECTION)
      .where("momentId", "==", moment.momentId)
      .where("status", "==", "planned")
      .get();
    const runs = existing.docs.map((doc) =>
      runFromDocument(doc.data()));
    const plan = replan(moment, facts, runs, now);
    for (const runId of plan.supersede) {
      await db.collection(MOMENT_RUNS_COLLECTION).doc(runId)
        .update({status: "superseded"});
      summary.runsSuperseded += 1;
    }
    if (plan.create !== null) {
      // Create-only: a deterministic run id may already exist as a
      // completed (dispatched/skipped/superseded) journal entry and must
      // never be resurrected into a second fire.
      const runRef =
        db.collection(MOMENT_RUNS_COLLECTION).doc(plan.create.runId);
      if (!(await runRef.get()).exists) {
        await runRef.set({...plan.create});
        summary.runsCreated += 1;
      }
    }
    if (plan.supersede.length > 0 || plan.create !== null) {
      summary.momentsReplanned += 1;
    }
  }

  // Pass 2: fire due planned runs in order.
  const dueSnap = await db.collection(MOMENT_RUNS_COLLECTION)
    .where("status", "==", "planned")
    .get();
  const due = selectDueRuns(
    dueSnap.docs.map((doc) => runFromDocument(doc.data())),
    now, MAX_DUE_RUNS_PER_SWEEP);
  const byId = new Map(moments.map((moment) => [moment.momentId, moment]));
  for (const run of due) {
    const moment = byId.get(run.momentId) ??
      await loadMoment(db, run.momentId);
    if (moment === null) {
      await markRun(db, run, "skipped", {reason: "missingMoment"});
      summary.runsSkipped += 1;
      continue;
    }
    const facts = await factsFor(moment.scope);
    if (facts === null) {
      await markRun(db, run, "skipped", {reason: "missingScopeFacts"});
      summary.runsSkipped += 1;
      continue;
    }
    const outcome = await dispatchRun(db, deps, moment, run, facts, now);
    if (outcome === "deferred") summary.runsDeferred += 1;
    else if (outcome === "fired") summary.runsFired += 1;
    else summary.runsSkipped += 1;
  }
  return summary;
}

async function loadMoment(
  db: Firestore,
  momentId: string,
): Promise<MomentDefinition | null> {
  const doc = await db.collection(MOMENTS_COLLECTION).doc(momentId).get();
  return doc.exists ? momentFromDocument(doc.data()!) : null;
}

/**
 * Evaluates armed triggered moments against one travel-leg fact and fires
 * the runs it produces. Deterministic run ids make a repeated fact (e.g.
 * a retried projection write) harmless.
 */
export async function ingestTravelLegEvent(
  deps: MomentRunnerDeps,
  event: TravelLegEvent,
): Promise<{firedRuns: number}> {
  const db = deps.firestore();
  const now = deps.nowMillis();
  const snap = await db.collection(MOMENTS_COLLECTION)
    .where("status", "==", "armed")
    .get();
  const scope: MomentScope = {kind: "program", programId: event.programId};
  const facts = await loadAnchorFacts(db, scope);
  let firedRuns = 0;
  for (const doc of snap.docs) {
    const moment = momentFromDocument(doc.data());
    if (moment === null || moment.initiation.kind !== "triggered") continue;
    if (facts === null) continue;
    const result = evaluateCondition(moment, event, facts, now);
    if (result.kind !== "fire") continue;
    const ref = db.collection(MOMENT_RUNS_COLLECTION).doc(result.run.runId);
    const existing = await ref.get();
    if (existing.exists) continue;
    await ref.set({...result.run});
    const outcome = await dispatchRun(db, deps, moment, result.run,
      facts, now);
    if (outcome === "fired") firedRuns += 1;
  }
  return {firedRuns};
}

/** Fires a manual moment once per caller-supplied request key. */
export async function runManualMoment(
  deps: MomentRunnerDeps,
  momentId: string,
  requestKey: string,
): Promise<{runId: string} | {rejected: string}> {
  const db = deps.firestore();
  const moment = await loadMoment(db, momentId);
  if (moment === null) return {rejected: "missingMoment"};
  if (moment.initiation.kind !== "manual") {
    return {rejected: "notManual"};
  }
  const planned = planManualRun(moment, requestKey, deps.nowMillis());
  if (planned.kind !== "planned") {
    return {rejected: planned.reason};
  }
  const ref = db.collection(MOMENT_RUNS_COLLECTION)
    .doc(planned.run.runId);
  if ((await ref.get()).exists) return {runId: planned.run.runId};
  await ref.set({...planned.run});
  const facts = await loadAnchorFacts(db, moment.scope);
  if (facts === null) {
    await markRun(db, planned.run, "skipped", {reason: "missingScopeFacts"});
    return {rejected: "missingScopeFacts"};
  }
  const outcome = await dispatchRun(db, deps, moment, planned.run,
    facts, deps.nowMillis());
  return outcome === "skipped" ? {rejected: "skipped"} :
    {runId: planned.run.runId};
}

type DispatchOutcome = "fired" | "deferred" | "skipped";

async function dispatchRun(
  db: Firestore,
  deps: MomentRunnerDeps,
  moment: MomentDefinition,
  run: RunRecord,
  facts: AnchorFacts,
  now: number,
): Promise<DispatchOutcome> {
  const disposition = resolveFireDisposition(run, moment, facts, now);
  if (disposition !== "dispatch") {
    await markRun(db, run, "skipped", {reason: disposition});
    return "skipped";
  }
  const quietEnd = await deps.quietEndMillis(moment.scope, now);
  if (quietEnd !== null) {
    await db.collection(MOMENT_RUNS_COLLECTION).doc(run.runId)
      .update({dueAtMillis: quietEnd});
    return "deferred";
  }
  const dailyCap = await deps.dailyCapFor(moment.scope);
  const quietHours = await deps.quietHoursFor(moment.scope);
  const localMinute = await deps.localMinuteOfDay(moment.scope, now);
  const dayKey = await deps.localDayKey(moment.scope, now);

  const resolution = await resolveMomentRecipients(db, moment, run);
  const decisions: PolicyDecision[] = [];
  const byRecipient = new Map<string, ResolvedRecipient>();
  for (const recipient of resolution.recipients) {
    byRecipient.set(recipient.recipientKey, recipient);
  }
  for (const recipient of resolution.recipients) {
    const consent = await deps.loadConsentFacts(recipient, moment);
    const sendRef = db.collection(MOMENT_SENDS_COLLECTION)
      .doc(`${run.runId}_${recipient.recipientKey}`);
    const prior = await sendRef.get();
    if (prior.exists) {
      // Idempotent across sweep retries and replan races.
      decisions.push({kind: "send"});
      continue;
    }
    const sentToday = await countSendsToday(
      db, recipient.recipientKey, dayKey);
    const decision = evaluateRecipientPolicy({
      endpoint: recipient.endpoint,
      consent,
      explicitConsentRequired: moment.action.kind === "sendTemplate",
      quietHours,
      localMinuteOfDay: localMinute,
      sentTodayForEndpoint: sentToday,
      dailyCap,
    });
    decisions.push(decision);
    if (decision.kind === "defer") continue; // resolved run-level next pass
    if (decision.kind === "suppress") {
      await sendRef.set({
        momentId: moment.momentId,
        recipientKey: recipient.recipientKey,
        decision: "suppressed",
        reason: decision.reason,
        dayKey,
        createdAtMillis: now,
      });
      continue;
    }
    await deliver(deps, moment, run, facts, recipient);
    await sendRef.set({
      momentId: moment.momentId,
      recipientKey: recipient.recipientKey,
      decision: "sent",
      dayKey,
      createdAtMillis: now,
    });
  }
  if (decisions.some((d) => d.kind === "defer")) {
    const retry = await deps.quietEndMillis(moment.scope, now) ??
      now + 60_000;
    await db.collection(MOMENT_RUNS_COLLECTION).doc(run.runId)
      .update({dueAtMillis: retry});
    return "deferred";
  }
  const rollup = rollupPolicy(decisions);
  await markRun(db, run, "dispatched", {
    recipients: resolution.recipients.length,
    sent: rollup.send,
    suppressed: rollup.suppressed,
    suppressedNoEndpoint: resolution.suppressedNoEndpoint,
  });
  return "fired";
}

async function deliver(
  deps: MomentRunnerDeps,
  moment: MomentDefinition,
  run: RunRecord,
  facts: AnchorFacts,
  recipient: ResolvedRecipient,
): Promise<void> {
  const action: MomentAction = moment.action;
  if (action.kind === "sendTemplate" &&
      recipient.endpoint.kind === "phone") {
    await deps.sendTemplateToPhone({
      e164: recipient.endpoint.e164,
      connectionId: action.connectionId,
      templateId: action.templateId,
      variables: action.variables,
      runId: run.runId,
      recipientKey: recipient.recipientKey,
    });
    return;
  }
  if (action.kind === "push" && recipient.endpoint.kind === "uid") {
    // Copy is resolved from the scope at fire time by the wiring layer.
    const copy = await deps.pushCopyFor(moment, facts);
    await deps.sendPushToUid({
      uid: recipient.endpoint.uid,
      title: copy.title,
      body: copy.body,
      notificationType: action.notificationType,
      preferenceKey: action.preferenceKey,
      scope: moment.scope,
      runId: run.runId,
      recipientKey: recipient.recipientKey,
    });
    return;
  }
  if (action.kind === "staffAttention" &&
      moment.audience.kind === "staffDuty" &&
      recipient.endpoint.kind === "uid") {
    await deps.writeStaffAttention({
      uid: recipient.endpoint.uid,
      duty: action.duty,
      scopeIds: moment.audience.scopeIds,
      severity: action.severity,
      title: action.titleTemplate,
      scope: moment.scope,
      runId: run.runId,
    });
    return;
  }
  throw new RangeError(
    `No delivery path for action ${action.kind} ` +
    `to ${recipient.endpoint.kind}`);
}

async function countSendsToday(
  db: Firestore,
  recipientKey: string,
  dayKey: string,
): Promise<number> {
  const snap = await db.collection(MOMENT_SENDS_COLLECTION)
    .where("recipientKey", "==", recipientKey)
    .where("dayKey", "==", dayKey)
    .where("decision", "==", "sent")
    .get();
  return snap.size;
}

async function markRun(
  db: Firestore,
  run: RunRecord,
  status: RunRecord["status"],
  extra: Record<string, unknown>,
): Promise<void> {
  await db.collection(MOMENT_RUNS_COLLECTION).doc(run.runId).update({
    status,
    ...extra,
  });
}
