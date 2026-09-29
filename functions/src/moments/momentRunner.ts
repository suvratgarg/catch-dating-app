/* firestore-index: organizerMoments (
  scopeKind:ASCENDING,
  scopeId:ASCENDING,
  status:ASCENDING
) */
/* firestore-index: organizerMomentRuns (
  status:ASCENDING,
  dueAtMillis:ASCENDING
) */
import {createHash} from "node:crypto";
import {FieldPath, type Firestore, type Query} from
  "firebase-admin/firestore";
import {logger} from "firebase-functions";
import {
  evaluateCondition,
  type TravelLegEvent,
} from "./momentConditions";
import {
  loadAnchorFacts,
  loadTravelFacts,
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
  nominalDueAtMillis,
  planRun,
  planManualRun,
  replan,
  resolveFireDisposition,
} from "./momentPlanning";
import {
  buildTravelContext,
  haversineTravelMinutes,
  type TravelEstimateContext,
  type TravelEstimator,
} from "./momentTravel";
import type {
  AnchorFacts,
  MomentAction,
  MomentDefinition,
  MomentScope,
  RunRecord,
  TravelFacts,
} from "./momentModel";
import {scopeId} from "./momentModel";
import type {ProgramReminderOutcome}
  from "../programs/programReminderDelivery";

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
  /** Program-scoped template sends own a durable intent + shared-core
   *  dispatch — the runner never calls a provider on this path. */
  deliverProgramReminder: (params: {
    moment: MomentDefinition;
    run: RunRecord;
    facts: AnchorFacts;
    recipient: ResolvedRecipient;
    action: Extract<MomentAction, {kind: "sendTemplate"}>;
  }) => Promise<ProgramReminderOutcome>;
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
  /** Hotel→venue travel estimate in minutes for distance-aware leads.
   *  Defaults to the pure haversine guess; a Routes provider can replace
   *  it without engine changes. */
  estimateTravelMinutes?: TravelEstimator;
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

/** Durable pagination state for the armed-moment scan. */
export const MOMENT_SWEEP_STATE = "organizerMomentSweepState";

/** Per-pass fact caches shared across the moments on one page. */
interface SweepCaches {
  facts: Map<string, AnchorFacts | null>;
  travel: Map<string, TravelFacts>;
}

function scopeFactsKey(scope: MomentScope): string {
  return `${scope.kind}:${scopeId(scope)}`;
}

/**
 * Replans one anchored/scheduled moment against current facts — shared by
 * the sweep (which pages armed moments and shares fact caches across the
 * page) and by the lifecycle callables (which replan a single moment the
 * instant its arm state changes, so a fresh arm never waits for the
 * cursor to reach it). Returns the counts it applied.
 */
export async function replanMoment(
  db: Firestore,
  moment: MomentDefinition,
  now: number,
  options?: {
    estimateTravelMinutes?: TravelEstimator;
    caches?: SweepCaches;
  },
): Promise<{created: number; superseded: number; skipped: number;
  rescheduled: number}> {
  const counts = {created: 0, superseded: 0, skipped: 0, rescheduled: 0};
  if (moment.initiation.kind !== "anchored" &&
      moment.initiation.kind !== "scheduled") {
    return counts;
  }
  const caches = options?.caches ?? {facts: new Map(), travel: new Map()};
  const facts = await cachedFacts(db, caches, moment.scope);
  if (facts === null) return counts;
  const travel = await cachedTravel(db, caches,
    options?.estimateTravelMinutes ?? haversineTravelMinutes,
    moment, facts);

  const existing = await db.collection(MOMENT_RUNS_COLLECTION)
    .where("momentId", "==", moment.momentId)
    .get();
  const runs = existing.docs.map((doc) => runFromDocument(doc.data()));
  const nominal = planRun(moment, facts, now);
  const recipients = travel && nominal.kind === "planned" ?
    (await resolveMomentRecipients(db, moment, nominal.run,
      travel)).recipients : null;
  const travelLeadMinutes = recipients ? recipients.reduce((max,
    recipient) => Math.max(max, recipient.travelLeadMinutes ?? 0), 0) :
    undefined;
  const preview = planRun(moment, facts, now,
    {travel, travelLeadMinutes});
  if (preview.kind === "planned") {
    // Earlier run IDs may encode a mutable travel wake. They cannot be
    // mapped to a nominal occurrence after lead or setting changes; this
    // remains true when travelTimeLead has since been switched off.
    const legacy = runs.filter((run) =>
      run.anchorRevision === preview.run.anchorRevision &&
      run.runId !== preview.run.runId &&
      run.occurrenceVersion !== 2 &&
      run.travelPlanHash === undefined);
    if (legacy.length > 0) {
      let held = false;
      for (const run of legacy.filter((entry) =>
        entry.status === "planned")) {
        await db.collection(MOMENT_RUNS_COLLECTION).doc(run.runId)
          .update({status: "failed",
            reason: "legacyOccurrenceUnresolved"});
        held = true;
      }
      const nominalRun = runs.find((run) =>
        run.runId === preview.run.runId);
      if (nominalRun?.status === "planned") {
        await db.collection(MOMENT_RUNS_COLLECTION)
          .doc(nominalRun.runId).update({status: "failed",
            reason: "legacyOccurrenceUnresolved"});
        held = true;
      } else if (!nominalRun) {
        await db.collection(MOMENT_RUNS_COLLECTION)
          .doc(preview.run.runId).set({...preview.run,
            status: "failed", reason: "legacyOccurrenceUnresolved"});
        held = true;
      }
      if (held) {
        logger.warn("Moment occurrence requires legacy reconciliation", {
          reason: "legacyOccurrenceUnresolved",
          momentId: moment.momentId,
          nominalRunId: preview.run.runId,
          legacyRunIds: legacy.map((run) => run.runId),
        });
        counts.skipped += 1;
      }
      return counts;
    }
  }
  const travelPlanHash = recipients ?
    hashTravelPlan(recipients) : undefined;
  const plan = replan(moment, facts, runs, now,
    {travel, travelLeadMinutes, travelPlanHash});
  for (const runId of plan.supersede) {
    await db.collection(MOMENT_RUNS_COLLECTION).doc(runId)
      .update({status: "superseded"});
    counts.superseded += 1;
  }
  if (plan.create !== null) {
    // Create-only: a deterministic run id may already exist as a
    // completed (dispatched/skipped/superseded) journal entry and must
    // never be resurrected into a second fire.
    const runRef =
      db.collection(MOMENT_RUNS_COLLECTION).doc(plan.create.runId);
    if (!(await runRef.get()).exists) {
      await runRef.set({...plan.create});
      counts.created += 1;
    }
  }
  for (const change of plan.reschedule) {
    await db.collection(MOMENT_RUNS_COLLECTION).doc(change.runId)
      .update({dueAtMillis: change.dueAtMillis,
        plannedWakeAtMillis: change.plannedWakeAtMillis,
        travelPlanHash: change.travelPlanHash});
    counts.rescheduled += 1;
  }
  return counts;
}

/**
 * Inline replan for a program's armed moments after an anchor-bearing
 * write (program/function times, deadline, status). Bounded — the sweep
 * converges anything past the cap. Best-effort callers only.
 */
export async function replanProgramMoments(
  db: Firestore,
  programId: string,
  now: number,
  options?: {estimateTravelMinutes?: TravelEstimator},
): Promise<{replanned: number; capped: boolean}> {
  // (scopeKind, scopeId, status) composite index carries the lookup, so
  // the cap bounds armed moments directly rather than a mixed page.
  const armed = await db.collection(MOMENTS_COLLECTION)
    .where("scopeKind", "==", "program")
    .where("scopeId", "==", programId)
    .where("status", "==", "armed")
    .limit(200).get();
  const caches: SweepCaches = {facts: new Map(), travel: new Map()};
  let replanned = 0;
  for (const doc of armed.docs) {
    const moment = momentFromDocument(doc.data());
    if (moment === null) continue;
    await replanMoment(db, moment, now, {
      estimateTravelMinutes: options?.estimateTravelMinutes, caches});
    replanned += 1;
  }
  return {replanned, capped: armed.size === 200};
}

async function cachedFacts(
  db: Firestore,
  caches: SweepCaches,
  scope: MomentScope,
): Promise<AnchorFacts | null> {
  const key = scopeFactsKey(scope);
  if (!caches.facts.has(key)) {
    caches.facts.set(key, await loadAnchorFacts(db, scope));
  }
  return caches.facts.get(key) ?? null;
}

/**
 * Travel geography loads once per program and only when an armed moment
 * actually asks for distance-aware leads.
 */
async function cachedTravel(
  db: Firestore,
  caches: SweepCaches,
  estimator: TravelEstimator,
  moment: MomentDefinition,
  facts: AnchorFacts,
): Promise<TravelEstimateContext | null> {
  if (moment.scope.kind !== "program" ||
      moment.audience.kind !== "functionGuests" ||
      moment.audience.travelTimeLead !== true) {
    return null;
  }
  if (facts.travel === undefined) {
    const programId = moment.scope.programId;
    if (!caches.travel.has(programId)) {
      caches.travel.set(programId, await loadTravelFacts(db, programId));
    }
    facts.travel = caches.travel.get(programId)!;
  }
  return buildTravelContext(moment, facts, estimator);
}

/**
 * Pages armed moments with a durable cursor, replans them against current
 * anchor facts (superseding stale runs when a function's time moved), and
 * fires whatever is due. Each moment is handled independently — one bad
 * document cannot stall the sweep, and the cursor keeps discovery bounded
 * no matter how many armed moments exist.
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

  // Pass 1: one page of armed moments resuming at the durable cursor. A
  // full page advances it; a short page wraps to the start so the next
  // sweep covers the front of the range again.
  const sweepRef = db.collection(MOMENT_SWEEP_STATE).doc("armed");
  const state = (await sweepRef.get()).data() as
    {afterMomentId?: string | null} | undefined;
  const afterId = typeof state?.afterMomentId === "string" ?
    state.afterMomentId : null;
  let armedQuery: Query = db.collection(MOMENTS_COLLECTION)
    .where("status", "==", "armed")
    .orderBy(FieldPath.documentId());
  if (afterId !== null) armedQuery = armedQuery.startAfter(afterId);
  const momentsSnap = await armedQuery.limit(MOMENT_SWEEP_LIMIT).get();
  await sweepRef.set({
    sweepId: "armed",
    afterMomentId: momentsSnap.size === MOMENT_SWEEP_LIMIT ?
      momentsSnap.docs[momentsSnap.docs.length - 1].id : null,
    updatedAtMillis: now,
  }, {merge: true});

  const caches: SweepCaches = {facts: new Map(), travel: new Map()};
  const estimator = deps.estimateTravelMinutes ?? haversineTravelMinutes;
  const moments: MomentDefinition[] = [];
  for (const doc of momentsSnap.docs) {
    const moment = momentFromDocument(doc.data());
    if (moment === null) continue;
    moments.push(moment);
    const counts = await replanMoment(db, moment, now,
      {estimateTravelMinutes: estimator, caches});
    summary.runsCreated += counts.created;
    summary.runsSuperseded += counts.superseded;
    summary.runsSkipped += counts.skipped;
    if (counts.created + counts.superseded + counts.rescheduled > 0) {
      summary.momentsReplanned += 1;
    }
  }

  // Pass 2: fire due planned runs in order through the composite
  // (status, dueAtMillis) index — no full-collection read.
  const dueSnap = await db.collection(MOMENT_RUNS_COLLECTION)
    .where("status", "==", "planned")
    .where("dueAtMillis", "<=", now)
    .orderBy("dueAtMillis")
    .limit(MAX_DUE_RUNS_PER_SWEEP)
    .get();
  const due = dueSnap.docs.map((doc) => runFromDocument(doc.data()));
  const byId = new Map(moments.map((moment) => [moment.momentId, moment]));
  for (const run of due) {
    const moment = byId.get(run.momentId) ??
      await loadMoment(db, run.momentId);
    if (moment === null) {
      await markRun(db, run, "skipped", {reason: "missingMoment"});
      summary.runsSkipped += 1;
      continue;
    }
    const facts = await cachedFacts(db, caches, moment.scope);
    if (facts === null) {
      await markRun(db, run, "skipped", {reason: "missingScopeFacts"});
      summary.runsSkipped += 1;
      continue;
    }
    const outcome = await dispatchRun(db, deps, moment, run, facts, now,
      await cachedTravel(db, caches, estimator, moment, facts));
    if (outcome === "deferred") summary.runsDeferred += 1;
    else if (outcome === "fired") summary.runsFired += 1;
    else summary.runsSkipped += 1;
  }
  return summary;
}

function hashTravelPlan(recipients: ReadonlyArray<ResolvedRecipient>): string {
  const schedule = recipients.map((recipient) => [
    recipient.recipientKey, recipient.travelLeadMinutes ?? 0,
  ]).sort((a, b) => String(a[0]).localeCompare(String(b[0])));
  return createHash("sha256").update(JSON.stringify(schedule)).digest("hex");
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
  travel?: TravelEstimateContext | null,
): Promise<DispatchOutcome> {
  const disposition = resolveFireDisposition(run, moment, facts, now);
  if (disposition !== "dispatch") {
    await markRun(db, run, "skipped", {reason: disposition});
    return "skipped";
  }
  const quietEnd = await deps.quietEndMillis(moment.scope, now);
  if (quietEnd !== null) {
    // A deferral that would land past expiry never fires — record the
    // honest terminal state instead of parking the run.
    if (run.expiresAtMillis !== undefined &&
        quietEnd > run.expiresAtMillis) {
      await markRun(db, run, "skipped", {reason: "expired"});
      return "skipped";
    }
    await db.collection(MOMENT_RUNS_COLLECTION).doc(run.runId)
      .update({dueAtMillis: quietEnd});
    return "deferred";
  }
  const dailyCap = await deps.dailyCapFor(moment.scope);
  const quietHours = await deps.quietHoursFor(moment.scope);
  const localMinute = await deps.localMinuteOfDay(moment.scope, now);
  const dayKey = await deps.localDayKey(moment.scope, now);

  const resolution = await resolveMomentRecipients(
    db, moment, run, travel);
  const decisions: PolicyDecision[] = [];
  const byRecipient = new Map<string, ResolvedRecipient>();
  for (const recipient of resolution.recipients) {
    byRecipient.set(recipient.recipientKey, recipient);
  }
  // Distance-aware leads: the run woke early enough for the farthest
  // guest; nearer recipients wait for their own due. Deferred recipients
  // write no send row, so the re-fire below is still idempotent.
  const nominalDue = travel ? nominalDueAtMillis(moment, run, facts) : 0;
  let pendingTravelDue: number | null = null;
  for (const recipient of resolution.recipients) {
    const sendRef = db.collection(MOMENT_SENDS_COLLECTION)
      .doc(`${run.runId}_${recipient.recipientKey}`);
    const prior = await sendRef.get();
    if (prior.exists) {
      // Idempotent across sweep retries and replan races.
      decisions.push({kind: "send"});
      continue;
    }
    if (travel) {
      const due = nominalDue -
        (recipient.travelLeadMinutes ?? 0) * 60_000;
      if (due > now) {
        decisions.push({kind: "defer", reason: "travelLead"});
        pendingTravelDue = pendingTravelDue === null ?
          due : Math.min(pendingTravelDue, due);
        continue;
      }
    }
    const consent = await deps.loadConsentFacts(recipient, moment);
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
    const outcome = await deliver(deps, moment, run, facts, recipient);
    if (outcome.kind === "retry") {
      // Durable-delivery withholding (revoked consent mid-claim, expired
      // permit, provider ambiguity under arbitration) re-fires the run;
      // the recipient is never journaled "sent".
      decisions.push({kind: "defer", reason: "delivery"});
      continue;
    }
    if (outcome.kind === "suppressed") {
      decisions.push({kind: "suppress", reason: outcome.reason});
    }
    await sendRef.set({
      momentId: moment.momentId,
      recipientKey: recipient.recipientKey,
      decision: outcome.kind === "suppressed" ? "suppressed" : "sent",
      ...(outcome.kind === "suppressed" ? {reason: outcome.reason} : {}),
      dayKey,
      createdAtMillis: now,
      // staffAttention sends double as the attention-projection source:
      // the durable journal carries every field the organizer Today list
      // needs without a second write path.
      ...(moment.action.kind === "staffAttention" ? {
        runId: run.runId,
        actionKind: "staffAttention",
        organizerId: facts.scope.organizerId ?? null,
        scopeKind: moment.scope.kind,
        scopeId: scopeId(moment.scope),
        duty: moment.action.duty,
        severity: moment.action.severity,
        title: moment.action.titleTemplate,
      } : {}),
    });
  }
  if (decisions.some((d) => d.kind === "defer")) {
    // Travel-deferred recipients wake the run at their own due, not a flat
    // minute later; a quiet-hours defer still wins when both apply.
    const quietRetry = await deps.quietEndMillis(moment.scope, now);
    const candidates = [quietRetry, pendingTravelDue]
      .filter((v): v is number => v !== null);
    const retry = candidates.length > 0 ?
      Math.min(...candidates) : now + 60_000;
    if (run.expiresAtMillis !== undefined && retry > run.expiresAtMillis) {
      // Withheld/deferred recipients outlive the send window: the run
      // expires; the durable delivery records stay reconcilable on their
      // own evidence trail.
      await markRun(db, run, "skipped", {reason: "expired"});
      return "skipped";
    }
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

type DeliverOutcome = ProgramReminderOutcome;

async function deliver(
  deps: MomentRunnerDeps,
  moment: MomentDefinition,
  run: RunRecord,
  facts: AnchorFacts,
  recipient: ResolvedRecipient,
): Promise<DeliverOutcome> {
  const action: MomentAction = moment.action;
  if (action.kind === "sendTemplate" &&
      recipient.endpoint.kind === "phone") {
    // Program-scoped template sends produce a durable intent and dispatch
    // through the shared delivery core; the worker owns provider I/O and
    // unknown-outcome reconciliation. Every phone-endpoint producer is
    // program-scoped (guest:/household: keys) — validation rejects other
    // sendTemplate configurations at authoring time.
    if (moment.scope.kind === "program" &&
        (recipient.recipientKey.startsWith("guest:") ||
         recipient.recipientKey.startsWith("household:"))) {
      return deps.deliverProgramReminder({moment, run, facts, recipient,
        action});
    }
    // Stored data predating the authoring invariant fails closed for
    // review; the retired direct provider path is never a fallback.
    return {kind: "suppressed", reason: "hostReview"};
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
    return {kind: "sent"};
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
    return {kind: "sent"};
  }
  // No durable route exists for this action×endpoint pair; suppress for
  // host review rather than aborting the run's remaining recipients.
  return {kind: "suppressed", reason: "hostReview"};
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
