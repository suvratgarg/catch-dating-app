import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {EventRehearsalDocument} from
  "../shared/generated/firestoreAdminTypes";
import {
  applyRehearsalBehavior,
  applyRehearsalGuestAction,
  buildRehearsalActors,
  cuesBetween,
  eventRehearsalActionDocumentId,
  momentForStep,
  resolveRehearsalControl,
} from "./engine";

const now = admin.firestore.Timestamp.fromMillis(
  Date.parse("2026-08-19T10:00:00.000Z")
);

function session(
  overrides: Partial<EventRehearsalDocument> = {}
): EventRehearsalDocument {
  return {
    organizerId: "organizer-1",
    clubId: "organizer-1",
    ownerUid: "host-1",
    sourceEventId: null,
    sourceEventRevision: null,
    publicRehearsalId: "abcdefghijklmnopqrstuvwx",
    viewerTokenHash: "a".repeat(64),
    scenarioId: "lateAndNoShow",
    seed: 42,
    actorCount: 12,
    actionCount: 0,
    status: "ready",
    setup: {
      title: "Practice",
      locationName: "Studio",
      durationMinutes: 120,
      hostGoal: "Learn",
      attendeePrompt: "Say hello",
      moduleIds: ["arrival", "firstHello"],
    },
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
      now.toMillis() + 86400000
    ),
    completedAt: null,
    ...overrides,
  };
}

test("synthetic actors are deterministic and contain no user identifiers",
  () => {
    const first = buildRehearsalActors("session-1", 12, 42, now);
    const second = buildRehearsalActors("session-1", 12, 42, now);
    assert.deepEqual(first, second);
    assert.equal(new Set(first.map((actor) => actor.actorId)).size, 12);
    assert.ok(first.every((actor) => actor.sessionId === "session-1"));
    assert.ok(first.every((actor) => !("uid" in actor)));
  });

test("lifecycle freezes setup semantics and advances a virtual clock", () => {
  const started = resolveRehearsalControl(session(), "start");
  assert.deepEqual(started, {
    status: "running",
    activeStepIndex: 1,
    virtualNowMillis: now.toMillis(),
  });
  const advanced = resolveRehearsalControl(
    session({status: "running", activeStepIndex: 3}),
    "advanceClock",
    15
  );
  assert.equal(advanced.virtualNowMillis, now.toMillis() + 15 * 60000);
  assert.equal(advanced.activeStepIndex, 3);
  assert.throws(() => resolveRehearsalControl(
    session({status: "complete"}),
    "start"
  ));
});

test("scenario cues are emitted only when their minute is crossed", () => {
  assert.deepEqual(
    cuesBetween(
      "lateAndNoShow",
      now.toMillis(),
      now.toMillis() + 9 * 60000,
      now.toMillis() + 16 * 60000
    ),
    [
      {atMinute: 10, behavior: "arriveLate", actorIndex: 2},
      {atMinute: 15, behavior: "markNoShow", actorIndex: 5},
    ]
  );
});

test("behavior simulation retains privacy and safety state", () => {
  const actor = buildRehearsalActors("session-1", 2, 7, now)[0];
  assert.ok(actor);
  const optedOut = applyRehearsalBehavior(actor, "optOut", [], now);
  const keptApart = applyRehearsalBehavior(
    optedOut,
    "keepApart",
    ["actor-01", "actor-02"],
    now
  );
  assert.equal(keptApart.optedOut, true);
  assert.deepEqual(keptApart.keepApartActorIds, ["actor-02"]);
});

test("guest actions mutate only the synthetic actor", () => {
  const actor = buildRehearsalActors("session-1", 2, 7, now)[0];
  assert.ok(actor);
  const checkedIn = applyRehearsalGuestAction(actor, "checkIn", now);
  const prompted = applyRehearsalGuestAction(
    checkedIn,
    "completePrompt",
    now
  );
  assert.equal(prompted.status, "present");
  assert.equal(prompted.promptCompleted, true);
  assert.equal(momentForStep(99), "complete");
});

test("duplicate client delivery resolves to one stable receipt", () => {
  const first = eventRehearsalActionDocumentId(
    "session-1",
    "host",
    "client-42"
  );
  const retry = eventRehearsalActionDocumentId(
    "session-1",
    "host",
    "client-42"
  );
  const next = eventRehearsalActionDocumentId(
    "session-1",
    "host",
    "client-43"
  );
  const guest = eventRehearsalActionDocumentId(
    "session-1",
    "guest-slot-1",
    "client-42"
  );
  assert.equal(first, retry);
  assert.notEqual(first, next);
  assert.notEqual(first, guest);
});
