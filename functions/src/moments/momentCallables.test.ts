import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {
  armOrganizerMoment,
  listOrganizerMoments,
  pauseOrganizerMoment,
  requireMomentManageAuthority,
  resumeOrganizerMoment,
  runOrganizerMoment,
  upsertOrganizerMoment,
  type MomentCallablesDeps,
} from "./momentCallables";
import {MOMENTS_COLLECTION} from "./momentDocuments";

const ts = (millis: number) => admin.firestore.Timestamp.fromMillis(millis);
const NOW = 1_000_000;

const programScope = {kind: "program" as const, programId: "prog"};

const validPayload = {
  scope: programScope,
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
};

function makeDeps(db: FakeFirestore, authorized = true) {
  const calls: string[] = [];
  const deps: MomentCallablesDeps = {
    firestore: () => db as never,
    nowMillis: () => NOW,
    authorizeManage: async (_db, _scope, actorUid) => {
      calls.push(actorUid);
      if (!authorized) {
        throw new Error("denied");
      }
    },
  };
  return {deps, calls};
}

test("upsert creates a draft; list returns it scoped", async () => {
  const db = new FakeFirestore({});
  const {deps, calls} = makeDeps(db);
  const created = await upsertOrganizerMoment(deps, {
    actorUid: "mgr", payload: {...validPayload},
  });
  assert.equal(created.moment.status, "draft");
  assert.equal(created.moment.approval, null);
  assert.equal(calls.length, 1);
  const doc = await db.doc(
    `${MOMENTS_COLLECTION}/${created.moment.momentId}`).get();
  assert.equal((doc.data() as Record<string, unknown>).scopeId, "prog");
  const list = await listOrganizerMoments(deps, {
    actorUid: "mgr", scope: programScope,
  });
  assert.equal(list.moments.length, 1);
  const other = await listOrganizerMoments(deps, {
    actorUid: "mgr", scope: {kind: "program", programId: "other"},
  });
  assert.equal(other.moments.length, 0);
});

test("invalid axis combination is rejected at upsert", async () => {
  const db = new FakeFirestore({});
  const {deps} = makeDeps(db);
  await assert.rejects(
    upsertOrganizerMoment(deps, {
      actorUid: "mgr",
      payload: {...validPayload, initiation: {kind: "manual"},
        sense: "individual"},
    }),
    /manualRequiresAudienceSense/);
});

test("arm records approval once; re-arm is rejected", async () => {
  const db = new FakeFirestore({});
  const {deps} = makeDeps(db);
  const created = await upsertOrganizerMoment(deps, {
    actorUid: "mgr", payload: {...validPayload},
  });
  const armed = await armOrganizerMoment(deps, {
    actorUid: "mgr", scope: programScope,
    momentId: created.moment.momentId,
  });
  assert.equal(armed.moment.status, "armed");
  assert.deepEqual(armed.moment.approval, {
    approvedByUid: "mgr", approvedAtMillis: NOW,
  });
  await assert.rejects(
    armOrganizerMoment(deps, {
      actorUid: "mgr", scope: programScope,
      momentId: created.moment.momentId,
    }),
    /notArmable/);
});

test("editing an armed moment drops it back to draft", async () => {
  const db = new FakeFirestore({});
  const {deps} = makeDeps(db);
  const created = await upsertOrganizerMoment(deps, {
    actorUid: "mgr", payload: {...validPayload},
  });
  const armed = await armOrganizerMoment(deps, {
    actorUid: "mgr", scope: programScope,
    momentId: created.moment.momentId,
  });
  const revised = await upsertOrganizerMoment(deps, {
    actorUid: "mgr",
    payload: {...validPayload, momentId: armed.moment.momentId,
      name: "Renamed"},
  });
  assert.equal(revised.moment.status, "draft");
  assert.equal(revised.moment.approval, null);
  assert.equal(revised.moment.name, "Renamed");
  assert.equal(revised.moment.revision, 3);
});

test("scope is immutable and pause/resume preserve approval", async () => {
  const db = new FakeFirestore({});
  const {deps} = makeDeps(db);
  const created = await upsertOrganizerMoment(deps, {
    actorUid: "mgr", payload: {...validPayload},
  });
  await assert.rejects(
    upsertOrganizerMoment(deps, {
      actorUid: "mgr",
      payload: {...validPayload, momentId: created.moment.momentId,
        scope: {kind: "program", programId: "other"}},
    }),
    /scope cannot change/);
  await armOrganizerMoment(deps, {
    actorUid: "mgr", scope: programScope,
    momentId: created.moment.momentId,
  });
  const paused = await pauseOrganizerMoment(deps, {
    actorUid: "mgr", scope: programScope,
    momentId: created.moment.momentId,
  });
  assert.equal(paused.moment.status, "paused");
  const resumed = await resumeOrganizerMoment(deps, {
    actorUid: "mgr", scope: programScope,
    momentId: created.moment.momentId,
  });
  assert.equal(resumed.moment.status, "armed");
  assert.equal(resumed.moment.approval?.approvedByUid, "mgr");
});

test("runOrganizerMoment requires armed + requestKey, fires once",
  async () => {
    const db = new FakeFirestore({});
    db.setDoc("organizerPrograms/prog", {
      organizerId: "org-1", status: "active", capabilities: ["messaging"],
      startsAt: ts(0), endsAt: ts(9_000_000),
    });
    const {deps} = makeDeps(db);
    const created = await upsertOrganizerMoment(deps, {
      actorUid: "mgr",
      payload: {
        scope: programScope, name: "Send now",
        initiation: {kind: "manual"}, sense: "audience",
        audience: {kind: "households", rsvpPendingOnly: false},
        action: {kind: "sendTemplate", connectionId: "conn1",
          templateId: "tpl", variables: {}},
      },
    });
    const runner = {
      firestore: () => db as never,
      nowMillis: () => NOW,
      quietEndMillis: () => null,
      localDayKey: () => "d", localMinuteOfDay: () => 720,
      quietHoursFor: () => null, dailyCapFor: () => 0,
      pushCopyFor: async () => ({title: "t", body: "b"}),
      sendTemplateToPhone: async () => {},
      sendPushToUid: async () => {}, writeStaffAttention: async () => {},
      loadConsentFacts: async () => ({}),
    };
    await assert.rejects(
      runOrganizerMoment(deps, runner, {
        actorUid: "mgr", scope: programScope,
        momentId: created.moment.momentId, requestKey: "r1",
      }),
      /armed/);
    await armOrganizerMoment(deps, {
      actorUid: "mgr", scope: programScope,
      momentId: created.moment.momentId,
    });
    const run = await runOrganizerMoment(deps, runner, {
      actorUid: "mgr", scope: programScope,
      momentId: created.moment.momentId, requestKey: "r1",
    });
    assert.ok(run.runId.length > 0);
    const retry = await runOrganizerMoment(deps, runner, {
      actorUid: "mgr", scope: programScope,
      momentId: created.moment.momentId, requestKey: "r1",
    });
    assert.equal(retry.runId, run.runId);
    await assert.rejects(
      runOrganizerMoment(deps, runner, {
        actorUid: "mgr", scope: programScope,
        momentId: created.moment.momentId, requestKey: "",
      }),
      /requestKey/);
  });

test("default authority: manager, communications staff; others denied",
  async () => {
    const grantExpiry = Date.now() + 3_600_000;
    const db = new FakeFirestore({
      "organizers/org-1": {
        hostUserId: "mgr", ownerUserId: "mgr", hostUserIds: ["mgr"],
        hostProfiles: [],
      },
      "organizerPrograms/prog": {
        organizerId: "org-1", status: "active",
      },
      "programStaffGrants/prog__comms": {
        programId: "prog", organizerId: "org-1", uid: "comms",
        status: "active", expiresAt: ts(grantExpiry),
        duties: [{
          duty: "communications", expiresAtMillis: grantExpiry,
          pickupPointIds: [], hotelIds: [],
        }],
      },
    });
    await requireMomentManageAuthority(
      db as never, programScope, "mgr");
    await requireMomentManageAuthority(
      db as never, programScope, "comms");
    await assert.rejects(
      requireMomentManageAuthority(db as never, programScope, "random"),
      /does not have active program access/);
    await assert.rejects(
      requireMomentManageAuthority(db as never,
        {kind: "event", eventId: "evt"}, "mgr"),
      /EventDocument/);
  });
