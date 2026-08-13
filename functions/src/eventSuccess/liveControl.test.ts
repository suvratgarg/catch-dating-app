import assert from "node:assert/strict";
import test from "node:test";
import {readFileSync} from "node:fs";
import {join} from "node:path";
import {HttpsError} from "firebase-functions/v2/https";
import {
  LivePlanState,
  publishedAssignmentThroughRound,
  resolveEventSuccessLiveAction,
  resolveRotationPublish,
} from "./liveControl";
import {configuredPreparationAttempts} from "./rotationDraftTrigger";

const baseState = (overrides: Partial<LivePlanState> = {}): LivePlanState => ({
  activeStepIndex: 0,
  liveControlRevision: 4,
  publishedRotationRoundIndex: -1,
  publishedRevealRoundIndex: -1,
  status: "live",
  revealStatus: "idle",
  activeRevealRoundIndex: 0,
  revealStartedAtMillis: null,
  revealCountdownSeconds: 10,
  ...overrides,
});

test("publish is idempotent after a rotation round is committed", () => {
  const first = resolveRotationPublish(
    {liveControlRevision: 4, publishedRotationRoundIndex: -1},
    {
      eventId: "event-1",
      expectedRevision: 4,
      roundIndex: 0,
      confirmed: true,
    }
  );
  assert.deepEqual(first, {
    replayed: false,
    revision: 5,
    publishedRotationRoundIndex: 0,
  });

  const replay = resolveRotationPublish(
    {
      liveControlRevision: first.revision,
      publishedRotationRoundIndex: first.publishedRotationRoundIndex,
    },
    {
      eventId: "event-1",
      expectedRevision: 4,
      roundIndex: 0,
      confirmed: true,
    }
  );
  assert.deepEqual(replay, {
    replayed: true,
    revision: 5,
    publishedRotationRoundIndex: 0,
  });
});

test("rotation publish exposes no future precomputed slots", () => {
  const published = publishedAssignmentThroughRound({
    eventId: "event-1",
    moduleId: "guided_rotations",
    rotationSlots: [
      {roundIndex: 0, peerUid: "user-2", whyCodes: ["fresh_peer"]},
      {roundIndex: 1, peerUid: "user-3", whyCodes: ["fresh_peer"]},
    ],
    sitOutSlots: [{roundIndex: 2, whyCodes: ["sit_out"]}],
  }, 0);

  assert.deepEqual(published.peerUids, ["user-2"]);
  assert.deepEqual(
    (published.rotationSlots as Array<Record<string, unknown>>)
      .map((slot) => slot.roundIndex),
    [0]
  );
  assert.deepEqual(published.sitOutSlots, []);
});

test("beat transition module has no synchronous generator dependency", () => {
  const source = readFileSync(
    join(process.cwd(), "src/eventSuccess/liveControl.ts"),
    "utf8"
  );
  assert.doesNotMatch(source, /generateEventSuccessRotations/);
  assert.doesNotMatch(source, /prepareEventSuccessRotationDraft/);
});

test("published reveal cannot be reverted after countdown expiry", () => {
  const state = baseState({
    revealStatus: "countingDown",
    activeRevealRoundIndex: 0,
    revealStartedAtMillis: 1_000,
  });

  assert.throws(
    () => resolveEventSuccessLiveAction(
      state,
      {
        eventId: "event-1",
        expectedRevision: 4,
        action: "cancelRevealCountdown",
      },
      11_000
    ),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "failed-precondition" &&
      error.message.includes("cannot be reverted")
  );
});

test("reveal publication requires explicit confirmation", () => {
  assert.throws(
    () => resolveEventSuccessLiveAction(
      baseState(),
      {
        eventId: "event-1",
        expectedRevision: 4,
        action: "publishReveal",
        roundIndex: 0,
        confirmed: false,
      },
      1_000
    ),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "failed-precondition" &&
      error.message.includes("explicit confirmation")
  );
});

test("live writer rejects a stale revision fence", () => {
  assert.throws(
    () => resolveEventSuccessLiveAction(
      baseState(),
      {
        eventId: "event-1",
        expectedRevision: 3,
        action: "setActiveStep",
        activeStepIndex: 1,
      },
      1_000
    ),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "aborted"
  );
});

test("draft preparation retry ceiling is deployment configurable", () => {
  assert.equal(configuredPreparationAttempts(undefined), 3);
  assert.equal(configuredPreparationAttempts("6"), 6);
  assert.equal(configuredPreparationAttempts("0"), 3);
  assert.equal(configuredPreparationAttempts("6-retries"), 3);
  assert.equal(configuredPreparationAttempts("not-a-number"), 3);
});
