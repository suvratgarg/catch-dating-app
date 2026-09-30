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
    householdDedupe: true, travelTimeLead: false,
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
    pushCopyFor: async () => ({title: "Soon", body: "Soon"}),
    // Program-scope template sends route through the durable delivery
    // core; the stub records the same observable send the provider seam
    // used to, so routing assertions stay valid.
    deliverProgramReminder: async (p) => {
      sent.push({
        e164: p.recipient.endpoint.kind === "phone" ?
          p.recipient.endpoint.e164 : "",
        runId: p.run.runId,
        recipientKey: p.recipient.recipientKey,
      });
      return {kind: "sent"};
    },
    deliverAutomationMessage: async () =>
      ({kind: "suppressed" as const, reason: "hostReview" as const}),
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

test("fresh non-travel scheduled and anchored edits replan normally",
  async () => {
    for (const initiation of [
      {kind: "scheduled" as const, atMillis: 10_000_000},
      {kind: "anchored" as const, anchorKind: "functionStart" as const,
        anchorId: "sangeet", offsetMinutes: -15},
    ]) {
      const db = new FakeFirestore({});
      seedTravelProgram(db);
      const firstMoment: MomentDefinition = {...travelReminder,
        audience: {kind: "functionGuests", functionId: "sangeet",
          rsvp: ["attending"], householdDedupe: true,
          travelTimeLead: false},
        initiation};
      writeMoment(db, firstMoment);
      const {deps} = makeDeps(db, 0);
      await runMomentSweep(deps);
      const firstDue = initiation.kind === "scheduled" ?
        10_000_000 : 9_100_000;
      const oldId = `m_travel_${initiation.kind === "scheduled" ?
        0 : 7}_${firstDue}`;
      const oldRun = (await (deps.firestore() as never as FakeFirestore)
        .doc(`${MOMENT_RUNS_COLLECTION}/${oldId}`).get())
        .data() as Record<string, unknown>;
      assert.equal(oldRun.occurrenceVersion, 2);
      const changedInitiation = initiation.kind === "scheduled" ?
        {kind: "scheduled" as const, atMillis: 11_000_000} :
        {...initiation, offsetMinutes: -10};
      writeMoment(db, {...firstMoment, initiation: changedInitiation,
        revision: 2});
      const changed = await runMomentSweep(deps);
      assert.equal(changed.runsSuperseded, 1);
      assert.equal(changed.runsCreated, 1);
      const newDue = initiation.kind === "scheduled" ?
        11_000_000 : 9_400_000;
      const newId = `m_travel_${initiation.kind === "scheduled" ?
        0 : 7}_${newDue}`;
      const nextRun = (await (deps.firestore() as never as FakeFirestore)
        .doc(`${MOMENT_RUNS_COLLECTION}/${newId}`).get())
        .data() as Record<string, unknown>;
      assert.equal(nextRun.status, "planned");
      assert.equal(nextRun.occurrenceVersion, 2);
    }
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

function seedTravelProgram(db: FakeFirestore): void {
  db.setDoc("organizerPrograms/prog", {
    organizerId: "org-1", kind: "wedding", title: "Mehta × Rao",
    timezone: "Asia/Kolkata",
    startsAt: ts(5_000_000), endsAt: ts(20_000_000),
    status: "active", capabilities: ["messaging"],
    createdBy: "mgr", createdAt: ts(0), updatedAt: ts(0), revision: 3,
  });
  db.setDoc("programFunctions/sangeet", {
    programId: "prog", organizerId: "org-1", status: "scheduled",
    startsAt: ts(10_000_000), endsAt: ts(12_000_000), revision: 7,
    venueLocation: {name: "Lawn", latitude: 0, longitude: 0},
  });
  db.setDoc("programHotels/hotelFar", {
    programId: "prog", organizerId: "org-1", name: "Far",
    latitude: 10, longitude: 10, active: true, revision: 1,
  });
  db.setDoc("programHotels/hotelNear", {
    programId: "prog", organizerId: "org-1", name: "Near",
    latitude: 1, longitude: 1, active: true, revision: 1,
  });
  for (const [id, hotelId] of [["groupFar", "hotelFar"],
    ["groupNear", "hotelNear"]] as const) {
    db.setDoc(`programGuestGroups/${id}`, {
      programId: "prog", organizerId: "org-1", label: id,
      dimension: "side", sortOrder: 0, memberCount: 1, hotelId,
      createdAt: ts(0), updatedAt: ts(0), revision: 1,
    });
  }
  for (const [guestId, groupId, phone] of [
    ["gFar", "groupFar", "+9100F"],
    ["gNear", "groupNear", "+9100N"],
  ] as const) {
    db.setDoc(`programGuests/${guestId}`, {
      programId: "prog", organizerId: "org-1", displayName: guestId,
      householdId: null, phoneE164: phone, groupIds: [groupId],
      invitationStatus: "invited", rsvpStatus: "attending",
      source: "import", revision: 1,
    });
    db.setDoc(`programFunctionGuests/fg_${guestId}`, {
      programId: "prog", organizerId: "org-1", functionId: "sangeet",
      guestId, invited: true, rsvpStatus: "attending",
      attendanceStatus: "expected", partySize: 1, revision: 1,
    });
  }
}

const travelReminder: MomentDefinition = {
  ...sangeetReminder,
  momentId: "m_travel",
  initiation: {
    kind: "anchored", anchorKind: "functionStart", anchorId: "sangeet",
    offsetMinutes: 0,
  },
  audience: {
    kind: "functionGuests", functionId: "sangeet", rsvp: ["attending"],
    householdDedupe: true, travelTimeLead: true,
  },
};

test("travelTimeLead wakes early for the far guest and staggers the rest",
  async () => {
    const db = new FakeFirestore({});
    seedTravelProgram(db);
    writeMoment(db, travelReminder);
    // Deterministic leads: far hotel 30m, near hotel 5m. The run's wake
    // time is nominal (10_000_000) minus the cohort max.
    const estimator = (origin: {latitude: number}) =>
      origin.latitude === 10 ? 30 : 5;
    const first = makeDeps(db, 8_200_000);
    const deps: MomentRunnerDeps = {
      ...first.deps, estimateTravelMinutes: estimator};
    const summary = await runMomentSweep(deps);
    assert.equal(summary.runsCreated, 1);
    assert.equal(summary.runsDeferred, 1);
    assert.equal(summary.runsFired, 0);
    // Only the far guest was due; the near guest's send row is unwritten.
    assert.deepEqual(first.sent.map((s) => s.e164), ["+9100F"]);
    const dbView = deps.firestore() as never as FakeFirestore;
    const runDoc = await dbView
      .doc(`${MOMENT_RUNS_COLLECTION}/m_travel_7_10000000`).get();
    const run = runDoc.data() as Record<string, unknown>;
    assert.equal(run.status, "planned");
    // Re-due at the near guest's own due — not a flat minute later.
    assert.equal(run.dueAtMillis, 9_700_000);
    // Unchanged travel planning must not reset the recipient deferral to
    // the far guest's original 8.2m wake on every sweep.
    await runMomentSweep({...deps, nowMillis: () => 8_800_000});
    assert.equal((await dbView
      .doc(`${MOMENT_RUNS_COLLECTION}/m_travel_7_10000000`).get())
      .data()?.dueAtMillis, 9_700_000);
    db.setDoc("programHotels/unrelated", {
      programId: "prog", organizerId: "org-1", name: "Other",
      latitude: 50, longitude: 50, active: true, revision: 1,
    });
    db.setDoc("programGuestGroups/unrelated", {
      programId: "prog", organizerId: "org-1", label: "Other",
      dimension: "side", sortOrder: 0, memberCount: 0,
      hotelId: "unrelated", createdAt: ts(0), updatedAt: ts(0),
      revision: 1,
    });
    const unrelatedEstimator = (origin: {latitude: number}) =>
      origin.latitude === 50 ? 80 : estimator(origin);
    await runMomentSweep({...deps, nowMillis: () => 8_800_000,
      estimateTravelMinutes: unrelatedEstimator});
    assert.equal((await dbView
      .doc(`${MOMENT_RUNS_COLLECTION}/m_travel_7_10000000`).get())
      .data()?.dueAtMillis, 9_700_000);
    assert.equal(first.sent.length, 1);
    const sends1 = await dbView.collection(MOMENT_SENDS_COLLECTION).get();
    assert.equal(sends1.docs.length, 1);
    // At the near guest's due the same run fires again — replan keeps it,
    // the far guest's journal row prevents a resend, and the run closes.
    const second = await runMomentSweep({...deps,
      nowMillis: () => 9_700_000,
      estimateTravelMinutes: unrelatedEstimator});
    assert.equal(second.runsFired, 1);
    assert.deepEqual(first.sent.map((s) => s.e164).sort(),
      ["+9100F", "+9100N"]);
    const done = await dbView
      .doc(`${MOMENT_RUNS_COLLECTION}/m_travel_7_10000000`).get();
    assert.equal(
      (done.data() as Record<string, unknown>).status, "dispatched");
    const sends2 = await dbView.collection(MOMENT_SENDS_COLLECTION).get();
    assert.equal(sends2.docs.length, 2);
  });

for (const changedFarLead of [20, 40]) {
  test(`partial travel send survives far lead changing to ${changedFarLead}m`,
    async () => {
      const db = new FakeFirestore({});
      seedTravelProgram(db);
      writeMoment(db, travelReminder);
      const {deps, sent} = makeDeps(db, 8_200_000);
      const firstEstimator = (origin: {latitude: number}) =>
        origin.latitude === 10 ? 30 : 5;
      await runMomentSweep({...deps, estimateTravelMinutes: firstEstimator});
      assert.deepEqual(sent.map((row) => row.e164), ["+9100F"]);

      const changedEstimator = (origin: {latitude: number}) =>
        origin.latitude === 10 ? changedFarLead : 5;
      const changed = {...deps, nowMillis: () => 8_800_000,
        estimateTravelMinutes: changedEstimator};
      await runMomentSweep(changed);
      const dbView = deps.firestore() as never as FakeFirestore;
      const run = await dbView
        .doc(`${MOMENT_RUNS_COLLECTION}/m_travel_7_10000000`).get();
      assert.equal((run.data() as Record<string, unknown>).dueAtMillis,
        9_700_000);
      assert.deepEqual(sent.map((row) => row.e164), ["+9100F"]);
      await runMomentSweep({...changed, nowMillis: () => 9_700_000});
      await runMomentSweep({...changed, nowMillis: () => 9_700_000});
      assert.deepEqual(sent.map((row) => row.e164).sort(),
        ["+9100F", "+9100N"]);
      const sends = await dbView.collection(MOMENT_SENDS_COLLECTION).get();
      assert.equal(sends.docs.length, 2);
    });
}

test("non-max lead change advances only its pending recipient", async () => {
  const db = new FakeFirestore({});
  seedTravelProgram(db);
  writeMoment(db, travelReminder);
  const {deps, sent} = makeDeps(db, 8_200_000);
  await runMomentSweep({...deps, estimateTravelMinutes: (origin) =>
    origin.latitude === 10 ? 30 : 5});
  const dbView = deps.firestore() as never as FakeFirestore;
  const runRef = dbView
    .doc(`${MOMENT_RUNS_COLLECTION}/m_travel_7_10000000`);
  const oldHash = (await runRef.get()).data()?.travelPlanHash;
  const changed = {...deps, nowMillis: () => 8_800_000,
    estimateTravelMinutes: (origin: {latitude: number}) =>
      origin.latitude === 10 ? 30 : 20};
  await runMomentSweep(changed);
  assert.deepEqual(sent.map((row) => row.e164).sort(),
    ["+9100F", "+9100N"]);
  const run = (await runRef.get()).data() as Record<string, unknown>;
  assert.equal(run.status, "dispatched");
  assert.notEqual(run.travelPlanHash, oldHash);
  // A later unrelated hotel/group edit cannot resurrect the settled run.
  db.setDoc("programHotels/hotelUnrelated", {
    programId: "prog", organizerId: "org-1", name: "Unrelated",
    latitude: 50, longitude: 50, active: true, revision: 1,
  });
  db.setDoc("programGuestGroups/groupUnrelated", {
    programId: "prog", organizerId: "org-1", label: "Other",
    dimension: "side", sortOrder: 0, memberCount: 0,
    hotelId: "hotelUnrelated", createdAt: ts(0), updatedAt: ts(0),
    revision: 1,
  });
  await runMomentSweep({...changed, nowMillis: () => 8_900_000});
  assert.equal(sent.length, 2);
});

test("legacy wake-based run requires visible reconciliation", async () => {
  const db = new FakeFirestore({});
  seedTravelProgram(db);
  writeMoment(db, travelReminder);
  db.setDoc(`${MOMENT_RUNS_COLLECTION}/m_travel_7_8200000`, {
    runId: "m_travel_7_8200000", momentId: "m_travel",
    dueAtMillis: 9_700_000, anchorRevision: 7, status: "planned",
  });
  db.setDoc(`${MOMENT_SENDS_COLLECTION}/m_travel_7_8200000_guest:gFar`, {
    momentId: "m_travel", recipientKey: "guest:gFar",
    decision: "sent", dayKey: "day-1", createdAtMillis: 8_200_000,
  });
  const {deps, sent} = makeDeps(db, 8_800_000);
  const summary = await runMomentSweep({...deps,
    estimateTravelMinutes: (origin) => origin.latitude === 10 ? 20 : 5});
  assert.equal(summary.runsSkipped, 1);
  assert.equal(sent.length, 0);
  const dbView = deps.firestore() as never as FakeFirestore;
  for (const id of ["m_travel_7_8200000", "m_travel_7_10000000"]) {
    const row = (await dbView.doc(`${MOMENT_RUNS_COLLECTION}/${id}`)
      .get()).data() as Record<string, unknown>;
    assert.equal(row.status, "failed");
    assert.equal(row.reason, "legacyOccurrenceUnresolved");
  }
  const sends = await dbView.collection(MOMENT_SENDS_COLLECTION).get();
  assert.equal(sends.docs.length, 1);
  await runMomentSweep({...deps, nowMillis: () => 9_700_000,
    estimateTravelMinutes: (origin) => origin.latitude === 10 ? 20 : 5});
  assert.equal(sent.length, 0);
});

test("settled legacy receipts do not become a second travel run", async () => {
  const db = new FakeFirestore({});
  seedTravelProgram(db);
  writeMoment(db, travelReminder);
  db.setDoc(`${MOMENT_RUNS_COLLECTION}/m_travel_7_8200000`, {
    runId: "m_travel_7_8200000", momentId: "m_travel",
    dueAtMillis: 9_700_000, anchorRevision: 7,
    status: "dispatched", recipients: 2, sent: 2,
  });
  const {deps, sent} = makeDeps(db, 8_800_000);
  await runMomentSweep({...deps,
    estimateTravelMinutes: (origin) => origin.latitude === 10 ? 20 : 5});
  assert.equal(sent.length, 0);
  const failed = (await (deps.firestore() as never as FakeFirestore)
    .doc(`${MOMENT_RUNS_COLLECTION}/m_travel_7_10000000`).get())
    .data() as Record<string, unknown>;
  assert.equal(failed.status, "failed");
  assert.equal(failed.reason, "legacyOccurrenceUnresolved");
  const original = (await (deps.firestore() as never as FakeFirestore)
    .doc(`${MOMENT_RUNS_COLLECTION}/m_travel_7_8200000`).get())
    .data() as Record<string, unknown>;
  assert.equal(original.status, "dispatched");
});

for (const travelTimeLead of [true, false]) {
  test(`mixed legacy IDs hold nominal run with lead ${travelTimeLead}`,
    async () => {
      const db = new FakeFirestore({});
      seedTravelProgram(db);
      writeMoment(db, {...travelReminder, audience: {
        kind: "functionGuests", functionId: "sangeet",
        rsvp: ["attending"], householdDedupe: true, travelTimeLead,
      }});
      db.setDoc(`${MOMENT_RUNS_COLLECTION}/m_travel_7_8200000`, {
        runId: "m_travel_7_8200000", momentId: "m_travel",
        dueAtMillis: 9_700_000, anchorRevision: 7,
        status: "superseded",
      });
      db.setDoc(`${MOMENT_RUNS_COLLECTION}/m_travel_7_10000000`, {
        runId: "m_travel_7_10000000", momentId: "m_travel",
        dueAtMillis: 8_800_000, anchorRevision: 7,
        status: "planned",
      });
      db.setDoc(`${MOMENT_SENDS_COLLECTION}/m_travel_7_8200000_guest:gFar`, {
        momentId: "m_travel", recipientKey: "guest:gFar",
        decision: "sent", dayKey: "day-1", createdAtMillis: 8_200_000,
      });
      const {deps, sent} = makeDeps(db, 8_800_000);
      await runMomentSweep({...deps,
        estimateTravelMinutes: (origin) =>
          origin.latitude === 10 ? 20 : 5});
      assert.equal(sent.length, 0);
      const nominal = (await (deps.firestore() as never as FakeFirestore)
        .doc(`${MOMENT_RUNS_COLLECTION}/m_travel_7_10000000`).get())
        .data() as Record<string, unknown>;
      assert.equal(nominal.status, "failed");
      assert.equal(nominal.reason, "legacyOccurrenceUnresolved");
      const sends = await (deps.firestore() as never as FakeFirestore)
        .collection(MOMENT_SENDS_COLLECTION).get();
      assert.equal(sends.docs.length, 1);
    });
}

test("scheduled legacy receipts with revision zero hold nominal sender",
  async () => {
    const db = new FakeFirestore({});
    seedTravelProgram(db);
    writeMoment(db, {...travelReminder,
      initiation: {kind: "scheduled", atMillis: 10_000_000}});
    db.setDoc(`${MOMENT_RUNS_COLLECTION}/m_travel_0_8200000`, {
      runId: "m_travel_0_8200000", momentId: "m_travel",
      dueAtMillis: 10_000_000, anchorRevision: 0,
      status: "superseded",
    });
    db.setDoc(`${MOMENT_RUNS_COLLECTION}/m_travel_0_10000000`, {
      runId: "m_travel_0_10000000", momentId: "m_travel",
      dueAtMillis: 10_000_000, anchorRevision: 0,
      status: "planned",
    });
    db.setDoc(`${MOMENT_SENDS_COLLECTION}/m_travel_0_8200000_guest:gFar`, {
      momentId: "m_travel", recipientKey: "guest:gFar",
      decision: "sent", dayKey: "day-1", createdAtMillis: 8_200_000,
    });
    const {deps, sent} = makeDeps(db, 10_000_000);
    await runMomentSweep({...deps, estimateTravelMinutes: () => 0});
    assert.equal(sent.length, 0);
    const nominal = (await (deps.firestore() as never as FakeFirestore)
      .doc(`${MOMENT_RUNS_COLLECTION}/m_travel_0_10000000`).get())
      .data() as Record<string, unknown>;
    assert.equal(nominal.status, "failed");
    assert.equal(nominal.reason, "legacyOccurrenceUnresolved");
  });

test("legacy guard preserves an already terminal nominal run", async () => {
  const db = new FakeFirestore({});
  seedTravelProgram(db);
  writeMoment(db, {...travelReminder,
    initiation: {kind: "scheduled", atMillis: 10_000_000}});
  db.setDoc(`${MOMENT_RUNS_COLLECTION}/m_travel_0_8200000`, {
    runId: "m_travel_0_8200000", momentId: "m_travel",
    dueAtMillis: 8_200_000, anchorRevision: 0,
    status: "dispatched",
  });
  db.setDoc(`${MOMENT_RUNS_COLLECTION}/m_travel_0_10000000`, {
    runId: "m_travel_0_10000000", momentId: "m_travel",
    dueAtMillis: 10_000_000, anchorRevision: 0,
    status: "dispatched",
  });
  const {deps, sent} = makeDeps(db, 10_000_000);
  await runMomentSweep({...deps, estimateTravelMinutes: () => 0});
  assert.equal(sent.length, 0);
  const nominal = (await (deps.firestore() as never as FakeFirestore)
    .doc(`${MOMENT_RUNS_COLLECTION}/m_travel_0_10000000`).get())
    .data() as Record<string, unknown>;
  assert.equal(nominal.status, "dispatched");
});

test("flag-off moments keep the single wake time", async () => {
  const db = new FakeFirestore({});
  seedTravelProgram(db);
  writeMoment(db, {
    ...travelReminder,
    momentId: "m_plain",
    initiation: {
      kind: "anchored", anchorKind: "functionStart", anchorId: "sangeet",
      offsetMinutes: -15,
    },
    audience: {
      kind: "functionGuests", functionId: "sangeet", rsvp: ["attending"],
      householdDedupe: true, travelTimeLead: false,
    },
  });
  // nominal = 10_000_000 - 900_000 = 9_100_000; no lead, both fire at once.
  const {deps, sent} = makeDeps(db, 9_100_000);
  const summary = await runMomentSweep({...deps,
    estimateTravelMinutes: () => 30});
  assert.equal(summary.runsCreated, 1);
  assert.equal(summary.runsFired, 1);
  assert.equal(sent.length, 2);
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

test("staffAttention sends journal the attention-projection fields",
  async () => {
    const db = new FakeFirestore({});
    seedProgram(db);
    db.setDoc("programStaffGrants/gr1", {
      programId: "prog", organizerId: "org-1", uid: "staff-1",
      status: "active",
      duties: [{duty: "door", functionIds: ["sangeet"]}],
      revision: 1,
    });
    writeMoment(db, {
      ...sangeetReminder,
      momentId: "m_attention",
      audience: {kind: "staffDuty", duty: "door", scopeIds: ["sangeet"]},
      action: {
        kind: "staffAttention", duty: "door", severity: "urgent",
        titleTemplate: "Door staffing gap",
      },
    });
    const base = makeDeps(db, 1_100_000);
    const notified: string[] = [];
    const deps: MomentRunnerDeps = {...base.deps,
      writeStaffAttention: async (p) => {
        notified.push(p.uid);
      }};
    const summary = await runMomentSweep(deps);
    assert.equal(summary.runsFired, 1);
    assert.deepEqual(notified, ["staff-1"]);
    const sends = await (deps.firestore() as never as FakeFirestore)
      .collection(MOMENT_SENDS_COLLECTION).get();
    const rows = sends.docs.map((d) =>
      (d as {data(): Record<string, unknown>}).data());
    assert.equal(rows.length, 1);
    assert.equal(rows[0].decision, "sent");
    assert.equal(rows[0].actionKind, "staffAttention");
    assert.equal(rows[0].organizerId, "org-1");
    assert.equal(rows[0].scopeKind, "program");
    assert.equal(rows[0].scopeId, "prog");
    assert.equal(rows[0].runId, "m_attention_7_1100000");
    assert.equal(rows[0].duty, "door");
    assert.equal(rows[0].severity, "urgent");
    assert.equal(rows[0].title, "Door staffing gap");
  });

// --- Long-horizon scheduling ------------------------------------------------

test("sweep pages armed moments on a durable cursor", async () => {
  const db = new FakeFirestore({});
  seedProgram(db);
  for (let index = 0; index < 505; index += 1) {
    writeMoment(db, {...sangeetReminder,
      momentId: `m_${String(index).padStart(4, "0")}`,
      initiation: {kind: "scheduled", atMillis: 999_000_000}});
  }
  const {deps} = makeDeps(db, 0);
  const dbView = deps.firestore() as never as FakeFirestore;
  const first = await runMomentSweep(deps);
  assert.equal(first.runsCreated, 500);
  const cursor = (await dbView
    .doc("organizerMomentSweepState/armed").get())
    .data() as Record<string, unknown>;
  assert.equal(cursor.afterMomentId, "m_0499");
  // The next sweep resumes after the cursor and wraps on a short page.
  const second = await runMomentSweep(deps);
  assert.equal(second.runsCreated, 5);
  const wrapped = (await dbView
    .doc("organizerMomentSweepState/armed").get())
    .data() as Record<string, unknown>;
  assert.equal(wrapped.afterMomentId, null);
  // From the front again — deterministic run ids make re-planning free.
  const third = await runMomentSweep(deps);
  assert.equal(third.runsCreated, 0);
});

test("rsvpDeadline anchor plans off the stored program deadline", async () => {
  const db = new FakeFirestore({});
  seedProgram(db);
  db.updateDoc("organizerPrograms/prog", {rsvpDeadlineAt: ts(3_000_000)});
  writeMoment(db, {...sangeetReminder, momentId: "m_rsvp",
    initiation: {kind: "anchored", anchorKind: "rsvpDeadline",
      anchorId: null, offsetMinutes: -15}});
  const {deps} = makeDeps(db, 0);
  const summary = await runMomentSweep(deps);
  assert.equal(summary.runsCreated, 1);
  const run = (await (deps.firestore() as never as FakeFirestore)
    .doc(`${MOMENT_RUNS_COLLECTION}/m_rsvp_3_2100000`).get())
    .data() as Record<string, unknown>;
  assert.equal(run.dueAtMillis, 2_100_000);
  assert.equal(run.nominalDueAtMillis, 2_100_000);
  // A before-deadline nudge is pointless once the deadline has passed.
  assert.equal(run.expiresAtMillis, 3_000_000);
});

test("a deferral landing past expiry terminates the run honestly", async () => {
  const db = new FakeFirestore({});
  seedProgram(db);
  db.updateDoc("programHouseholds/hh1",
    {messagingConsent: {granted: true}});
  writeMoment(db, sangeetReminder);
  // The run is due at 1_100_000; quiet hours end at 2_500_000, past the
  // anchor-bound expiry at 2_000_000 — park nothing, expire it.
  const depsBase = makeDeps(db, 1_100_000);
  const deps: MomentRunnerDeps = {...depsBase.deps,
    quietEndMillis: () => 2_500_000};
  const summary = await runMomentSweep(deps);
  assert.equal(summary.runsDeferred, 0);
  assert.equal(summary.runsSkipped, 1);
  const run = await (deps.firestore() as never as FakeFirestore)
    .doc(`${MOMENT_RUNS_COLLECTION}/m_sangeet_7_1100000`).get();
  const data = run.data() as Record<string, unknown>;
  assert.equal(data.status, "skipped");
  assert.equal(data.reason, "expired");
  assert.equal(depsBase.sent.length, 0);
});

test("a quiet-hours deferral fires after wake, past planning grace",
  async () => {
    const db = new FakeFirestore({});
    seedProgram(db);
    db.updateDoc("programHouseholds/hh1",
      {messagingConsent: {granted: true}});
    writeMoment(db, sangeetReminder);
    const depsBase = makeDeps(db, 1_100_000);
    let quiet = true;
    const deps: MomentRunnerDeps = {...depsBase.deps,
      quietEndMillis: () => (quiet ? 1_340_000 : null)};
    await runMomentSweep(deps);
    assert.equal(depsBase.sent.length, 0);
    // At the deferred wake the nominal due is ~4 minutes past grace; the
    // run must keep its identity and fire — the reproduced defect swept
    // it into "dueInPast" instead.
    quiet = false;
    const later = await runMomentSweep({...deps, nowMillis: () => 1_340_000});
    assert.equal(later.runsFired, 1);
    assert.equal(depsBase.sent.length, 1);
    const run = await (deps.firestore() as never as FakeFirestore)
      .doc(`${MOMENT_RUNS_COLLECTION}/m_sangeet_7_1100000`).get();
    assert.equal(
      (run.data() as Record<string, unknown>).status, "dispatched");
  });

test("a guest joining mid-deferral is caught at fire time", async () => {
  const db = new FakeFirestore({});
  seedProgram(db);
  db.updateDoc("programHouseholds/hh1",
    {messagingConsent: {granted: true}});
  writeMoment(db, {...sangeetReminder, audience: {
    kind: "functionGuests", functionId: "sangeet", rsvp: ["attending"],
    householdDedupe: false, travelTimeLead: false,
  }});
  const depsBase = makeDeps(db, 1_100_000);
  let quiet = true;
  const deps: MomentRunnerDeps = {...depsBase.deps,
    quietEndMillis: () => (quiet ? 1_340_000 : null)};
  await runMomentSweep(deps);
  // Meera accepts while the run is parked — she gets this reminder when
  // it wakes; the audience is resolved at fire time, not plan time.
  db.setDoc("programGuests/g3", {
    programId: "prog", organizerId: "org-1", displayName: "Meera",
    householdId: null, phoneE164: "+910003",
    invitationStatus: "invited", rsvpStatus: "attending",
    source: "import", revision: 1,
  });
  db.setDoc("programFunctionGuests/fg3", {
    programId: "prog", organizerId: "org-1", functionId: "sangeet",
    guestId: "g3", invited: true, rsvpStatus: "attending",
    attendanceStatus: "expected", partySize: 1, revision: 1,
  });
  quiet = false;
  await runMomentSweep({...deps, nowMillis: () => 1_340_000});
  assert.deepEqual(depsBase.sent.map((s) => s.e164).sort(),
    ["+910001", "+910002", "+910003"]);
  // A guest arriving after the run closed is never replayed a completed
  // occurrence — there is no historical backlog for them.
  db.setDoc("programGuests/g4", {
    programId: "prog", organizerId: "org-1", displayName: "Late",
    householdId: null, phoneE164: "+910004",
    invitationStatus: "invited", rsvpStatus: "attending",
    source: "import", revision: 1,
  });
  db.setDoc("programFunctionGuests/fg4", {
    programId: "prog", organizerId: "org-1", functionId: "sangeet",
    guestId: "g4", invited: true, rsvpStatus: "attending",
    attendanceStatus: "expected", partySize: 1, revision: 1,
  });
  await runMomentSweep({...deps, nowMillis: () => 1_500_000});
  assert.equal(depsBase.sent.length, 3);
});

test("rsvpPendingOnly households drop out when the last member RSVPs",
  async () => {
    const db = new FakeFirestore({});
    seedProgram(db);
    // hh1 is consent-declined and fully answered; hhPending still owes a
    // reply — only the second qualifies while pendingOnly is set.
    db.setDoc("programGuests/gp", {
      programId: "prog", organizerId: "org-1", displayName: "P",
      householdId: "hhPending", phoneE164: "+9100P",
      invitationStatus: "invited", rsvpStatus: "pending",
      source: "import", revision: 1,
    });
    db.setDoc("programHouseholds/hhPending", {
      programId: "prog", organizerId: "org-1", label: "Pending",
      primaryPhoneE164: "+9100P", memberGuestIds: ["gp"], revision: 1,
    });
    writeMoment(db, {...sangeetReminder, momentId: "m_chase",
      audience: {kind: "households", rsvpPendingOnly: true}});
    const depsBase = makeDeps(db, 1_100_000);
    let quiet = true;
    const deps: MomentRunnerDeps = {...depsBase.deps,
      quietEndMillis: () => (quiet ? 1_340_000 : null)};
    await runMomentSweep(deps);
    // The last pending member answers during the deferral; the chase
    // reminder has nothing left to do when it wakes.
    db.updateDoc("programGuests/gp", {rsvpStatus: "attending"});
    quiet = false;
    const later = await runMomentSweep({...deps,
      nowMillis: () => 1_340_000});
    assert.equal(later.runsFired, 1);
    assert.equal(depsBase.sent.length, 0);
    const run = await (deps.firestore() as never as FakeFirestore)
      .doc(`${MOMENT_RUNS_COLLECTION}/m_chase_7_1100000`).get();
    const data = run.data() as Record<string, unknown>;
    assert.equal(data.status, "dispatched");
    assert.equal(data.recipients, 0);
  });
