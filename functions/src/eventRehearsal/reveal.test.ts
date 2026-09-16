import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import type {EventRehearsalDocument as Session} from
  "../shared/generated/firestoreAdminTypes";
import type {ControlEventRehearsalCallablePayload as Control} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import {validateControlEventRehearsalCallablePayload} from
  "../shared/generated/validators/controlEventRehearsalInput";
import {practiceRevealReview, preparePracticeReveal,
  settlePracticeReveal} from "./reveal";

type Command = NonNullable<Control["reveal"]>;

function session(now = 1_000): Session {
  return {status: "running", virtualNow: Timestamp.fromMillis(now)} as Session;
}

function command(
  action: Command["action"],
  expectedLiveRevision = 0,
  decisionId = `decision:${action}`
): Command {
  return {action, expectedLiveRevision, decisionId};
}

test("practice reveal review begins idle", () => {
  assert.deepEqual(practiceRevealReview(session()), {
    revision: 0,
    status: "idle",
    publishedRound: -1,
    pendingRound: null,
    startedAt: null,
    countdownSeconds: 10,
  });
});

test("virtual countdown publishes the next practice round", () => {
  const started = preparePracticeReveal(session(), command("startCountdown"));
  assert.equal(started.state.pendingRound, 0);
  assert.equal(started.state.revision, 1);
  const waiting = {...session(10_999), revealControl: started.state};
  assert.equal(practiceRevealReview(waiting).status, "countingDown");
  const elapsed = {...session(11_000), revealControl: started.state};
  assert.deepEqual(practiceRevealReview(elapsed), {
    revision: 1,
    status: "revealed",
    publishedRound: 0,
    pendingRound: null,
    startedAt: null,
    countdownSeconds: 10,
  });
  assert.equal(settlePracticeReveal(elapsed).publishedRound, 0);
});

test("Host can cancel a pending reveal or publish directly", () => {
  const started = preparePracticeReveal(session(), command("startCountdown"));
  const cancelled = preparePracticeReveal(
    {...session(), revealControl: started.state},
    command("cancelPending", 1)
  );
  assert.equal(cancelled.state.status, "idle");
  const published = preparePracticeReveal(
    {...session(), revealControl: cancelled.state},
    command("publish", 2)
  );
  assert.equal(published.publishedNow, true);
  assert.equal(published.state.publishedRound, 0);
  assert.equal(published.state.revision, 3);
});

test("practice reveal commands fence stale and conflicting decisions", () => {
  const started = preparePracticeReveal(session(), command("startCountdown"));
  assert.throws(() => preparePracticeReveal(
    {...session(), revealControl: started.state},
    command("cancelPending", 0)
  ), isCode("aborted"));
  const replay = preparePracticeReveal(
    {...session(), revealControl: started.state},
    command("startCountdown", 1)
  );
  assert.equal(replay.replayed, true);
  assert.throws(() => preparePracticeReveal(
    {...session(), revealControl: started.state},
    command("cancelPending", 1, "decision:startCountdown")
  ), isCode("aborted"));
});

test("publish acknowledges a reveal completed by virtual time", () => {
  const started = preparePracticeReveal(session(), command("startCountdown"));
  const result = preparePracticeReveal(
    {...session(11_000), revealControl: started.state},
    command("publish", 1)
  );
  assert.equal(result.replayed, true);
  assert.equal(result.publishedNow, true);
  assert.equal(result.state.publishedRound, 0);
  assert.equal(result.state.revision, 1);
});

test("control callable accepts only a correlated reveal command", () => {
  const payload = {sessionId: "session-1", expectedRevision: 2,
    expectedSetupRevision: 0, clientActionId: "reveal_0001",
    action: "reveal", reveal: command("startCountdown")};
  assert.equal(validateControlEventRehearsalCallablePayload(payload), true);
  assert.equal(validateControlEventRehearsalCallablePayload(
    {...payload, reveal: undefined}), false);
  assert.equal(validateControlEventRehearsalCallablePayload(
    {...payload, practiceOperatorId: "practice-staff:lead"}), false);
});

function isCode(code: HttpsError["code"]) {
  return (error: unknown) => error instanceof HttpsError &&
    error.code === code;
}
