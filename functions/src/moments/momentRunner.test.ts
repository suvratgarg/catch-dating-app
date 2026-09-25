import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {
  ingestTravelLegEvent,
  runManualMoment,
  runMomentSweep,
  type MomentRunnerDeps,
} from "./momentRunner";
import {
  MOMENT_RUNS_COLLECTION,
  MOMENT_SENDS_COLLECTION,
  MOMENTS_COLLECTION,
} from "./momentDocuments";
import type {MomentDefinition} from "./momentModel";

const ts = (millis: number) => admin.firestore.Timestamp.fromMillis(millis);

function seedProgram(db: FakeFirestore): void {
  db.setDoc("organizerPrograms/prog", {
    organizerId: "org-1", kind: "wedding", title: "Mehta × Rao",
    timezone: "Asia/Kolkata",
    startsAt: ts(1_000_000), endsAt: ts(9_000_000),
    status: "active", capabilities: ["messaging"],
    createdBy: "mgr", createdAt: ts(0), updatedAt: ts(0), revision: 3,
  });
  db.setDoc("programFunctions/sangeet", {
    programId: "prog", organizerId: "org-1", status: "scheduled",
    startsAt: ts(2_000_000), endsAt: ts(2_400_000), revision: 7,
  });
  db.setDoc("programGuests/g1", {
    programId: "prog", organizerId: "org-1", displayName: "Raj",
    householdId: "hh1", phoneE164: "+910001",
    invitationStatus: "invited", rsvpStatus: "attending", source: "import",
    revision: 1,
  });
  db.setDoc("programGuests/g2", {
    programId: "prog", organizerId: "org-1", displayName: "Sunita",
    householdId: "hh1", phoneE164: "+910002",
    invitationStatus: "invited", rsvpStatus: "attending", source: "import",
    revision: 1,
  });
  db.setDoc("programFunctionGuests/fg1", {
    programId: "prog", organizerId: "org-1", functionId: "sangeet",
    guestId: "g1", invited: true, rsvpStatus: "attending",
    attendanceStatus: "expected", partySize: 1, revision: 1,
  });
  db.setDoc("programFunctionGuests/fg2", {
    programId: "prog", organizerId: "org-1", functionId: "sangeet",
    guestId: "g2", invited: true, rsvpStatus: "attending",
    attendanceStatus: "expected", partySize: 1, revision: 1,
  });
  db.setDoc("programHouseholds/hh1", {
    programId: "prog", organizerId: "org-1", label: "Sharma",
    primaryPhoneE164: "+910001", memberGuestIds: ["g1", "g2"],
    messagingConsent: {granted: false},
    revision: 1,
  });
}

const sangeetReminder: MomentDefinition = {
  momentId: "m_sangeet",
  scope: {kind: "program", programId: "prog"},
  name: "Sangeet starts soon",
  initiation: {
    kind: "anchored", anchorKind: "functionStart", anchorId: "sangeet",
    offsetMinutes: -15,
  },
  sense: "audience",
  audience: {
    kind: "functionGuests", functionId: "sangeet", rsvp: ["attending"],
    householdDedupe: true,
  },
  action: {
    kind: "sendTemplate", connectionId: "conn1", templateId: "tpl",
    variables: {},
  },
  status: "armed",
  approval: {approvedByUid: "mgr", approvedAtMillis: 1},
  origin: "organizer",
  revision: 1,
};

function makeDeps(db: FakeFirestore, now: number) {
  const sent: Array<{e164: string; runId: string; recipientKey: string}> = [];
  const deps: MomentRunnerDeps = {
    firestore: () => db as never,
    nowMillis: () => now,
    quietEndMillis: () => null,
    localDayKey: () => "day-1",
    localMinuteOfDay: () => 720,
    quietHoursFor: () => null,
    dailyCapFor: () => 0,
    pushCopyFor: () => ({title: "Soon", body: "Soon"}),
    sendTemplateToPhone: async (p) => {
      sent.push({e164: p.e164, runId: p.runId,
        recipientKey: p.recipientKey});
    },
    sendPushToUid: async () => {},
    writeStaffAttention: async () => {},
    loadConsentFacts: async (recipient) => {
      if (recipient.householdId === null) return {};
      const doc = await (db as never as FakeFirestore)
        .doc(`programHouseholds/${recipient.householdId}`).get();
      const consent = (doc.data() as Record<string, unknown> | undefined)
        ?.messagingConsent as {granted?: boolean} | undefined;
      return {householdConsentGranted: consent?.granted ?? null};
    },
  };
  return {deps, sent};
}

function writeMoment(db: FakeFirestore, moment: MomentDefinition): void {
  db.setDoc(`${MOMENTS_COLLECTION}/${moment.momentId}`, {...moment});
}

test("sweep plans, fires, dedupes by household, honors consent", async () => {
  const db = new FakeFirestore({});
  seedProgram(db);
  writeMoment(db, sangeetReminder);
  // dueAt = 2_000_000 - 900_000 = 1_100_000; sweep at exactly that time.
  const {deps, sent} = makeDeps(db, 1_100_000);
  const summary = await runMomentSweep(deps);
  assert.equal(summary.runsCreated, 1);
  assert.equal(summary.runsFired, 1);
  // Household dedupe picks one endpoint; explicit decline suppresses it.
  assert.equal(sent.length, 0);
  const sends = await (deps.firestore() as never as FakeFirestore)
    .collection(MOMENT_SENDS_COLLECTION).get();
  const rows = sends.docs.map((d) =>
    (d as {data(): Record<string, unknown>}).data());
  assert.equal(rows.length, 1);
  assert.equal(rows[0].decision, "suppressed");
  assert.equal(rows[0].reason, "noConsent");
  assert.equal(rows[0].recipientKey, "household:hh1");
  const run = await (deps.firestore() as never as FakeFirestore)
    .doc(`${MOMENT_RUNS_COLLECTION}/m_sangeet_7_1100000`).get();
  assert.equal(
    (run.data() as Record<string, unknown>).status, "dispatched");
});

test("moved function supersedes the planned run", async () => {
  const db = new FakeFirestore({});
  seedProgram(db);
  writeMoment(db, sangeetReminder);
  const {deps} = makeDeps(db, 0);
  await runMomentSweep(deps);
  // Move sangeet 60m later; replan supersedes and re-plans.
  db.updateDoc("programFunctions/sangeet",
    {startsAt: ts(5_600_000), endsAt: ts(6_000_000), revision: 8});
  const summary = await runMomentSweep({...deps,
    nowMillis: () => 0});
  assert.equal(summary.runsSuperseded, 1);
  assert.equal(summary.runsCreated, 1);
  const oldRun = await (deps.firestore() as never as FakeFirestore)
    .doc(`${MOMENT_RUNS_COLLECTION}/m_sangeet_7_1100000`).get();
  assert.equal(
    (oldRun.data() as Record<string, unknown>).status, "superseded");
  const newRun = await (deps.firestore() as never as FakeFirestore)
    .doc(`${MOMENT_RUNS_COLLECTION}/m_sangeet_8_4700000`).get();
  assert.equal(newRun.exists, true);
});

test("consenting household receives the template send", async () => {
  const db = new FakeFirestore({});
  seedProgram(db);
  db.updateDoc("programHouseholds/hh1",
    {messagingConsent: {granted: true}});
  writeMoment(db, sangeetReminder);
  const {deps, sent} = makeDeps(db, 1_100_000);
  await runMomentSweep(deps);
  assert.equal(sent.length, 1);
  assert.equal(sent[0].e164, "+910001");
  // A second sweep must not resend — the send record is the idempotency key.
  await runMomentSweep(deps);
  assert.equal(sent.length, 1);
});

test("quiet hours defer the run without sending", async () => {
  const db = new FakeFirestore({});
  seedProgram(db);
  db.updateDoc("programHouseholds/hh1",
    {messagingConsent: {granted: true}});
  writeMoment(db, sangeetReminder);
  const depsBase = makeDeps(db, 1_100_000);
  const deps: MomentRunnerDeps = {...depsBase.deps,
    quietHoursFor: () => ({startMinute: 1260, endMinute: 480}),
    localMinuteOfDay: () => 1330,
    quietEndMillis: () => 1_340_000,
  };
  const summary = await runMomentSweep(deps);
  assert.equal(summary.runsDeferred, 1);
  assert.equal(depsBase.sent.length, 0);
  const run = await (deps.firestore() as never as FakeFirestore)
    .doc(`${MOMENT_RUNS_COLLECTION}/m_sangeet_7_1100000`).get();
  const data = run.data() as Record<string, unknown>;
  assert.equal(data.status, "planned");
  assert.equal(data.dueAtMillis, 1_340_000);
});

test("triggered moments fire on travel-leg events and dedupe", async () => {
  const db = new FakeFirestore({});
  seedProgram(db);
  db.setDoc("programTravelLegs/leg-9", {
    programId: "prog", organizerId: "org-1", guestId: "g1",
    flightStatus: "cancelled", readiness: "expected", revision: 1,
  });
  writeMoment(db, {
    ...sangeetReminder,
    momentId: "m_flight",
    initiation: {
      kind: "triggered", triggerKind: "flightDisrupted", functionId: null,
    },
    audience: {kind: "subject"},
    sense: "individual",
  });
  const {deps, sent} = makeDeps(db, 2_100_000);
  const event = {
    kind: "travelLegFlightStatusChanged" as const,
    legId: "leg-9", programId: "prog",
    previousFlightStatus: "delayed", flightStatus: "cancelled",
    observedAtMillis: 2_100_000,
  };
  const first = await ingestTravelLegEvent(deps, event);
  assert.equal(first.firedRuns, 1);
  // Consent is explicit-declined in the seed: suppressed, not sent.
  assert.equal(sent.length, 0);
  // Re-ingesting the same fact must not fire twice.
  const again = await ingestTravelLegEvent(deps, event);
  assert.equal(again.firedRuns, 0);
});

test("manual moments fire once per request key", async () => {
  const db = new FakeFirestore({});
  seedProgram(db);
  db.updateDoc("programHouseholds/hh1",
    {messagingConsent: {granted: true}});
  writeMoment(db, {
    ...sangeetReminder,
    momentId: "m_manual",
    initiation: {kind: "manual"},
  });
  const {deps, sent} = makeDeps(db, 5_000);
  const first = await runManualMoment(deps, "m_manual", "req-1");
  assert.ok("runId" in first);
  assert.equal(sent.length, 1);
  const retry = await runManualMoment(deps, "m_manual", "req-1");
  assert.ok("runId" in retry);
  assert.equal(sent.length, 1);
  const second = await runManualMoment(deps, "m_manual", "req-2");
  assert.ok("runId" in second);
  assert.equal(sent.length, 2);
  assert.notEqual(
    "runId" in first && first.runId, "runId" in second && second.runId);
});
