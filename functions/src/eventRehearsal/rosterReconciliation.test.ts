import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import type {EventRehearsalDocument as Session} from
  "../shared/generated/firestoreAdminTypes";
import {validateControlEventRehearsalCallablePayload} from
  "../shared/generated/validators/controlEventRehearsalInput";
import {buildRehearsalActors} from "./engine";
import {buildPracticeRosterSource, practiceRosterReview,
  preparePracticeRosterReconciliation} from "./rosterReconciliation";

const virtualNow = Timestamp.fromMillis(12_000);
const roster = buildRehearsalActors("session-1", 6, 13,
  Timestamp.fromMillis(0));

function session(scenarioId: Session["scenarioId"] = "smoothRun"): Session {
  return {
    scenarioId,
    status: "running",
    setupRevision: 2,
    virtualNow,
    rosterReconciliation: buildPracticeRosterSource(
      "session-1", 2, scenarioId, roster),
  } as Session;
}

test("practice roster source accounts for every successful source row", () => {
  const review = practiceRosterReview(session());
  assert.equal(review.sourceRevision, 2);
  assert.equal(review.status, "pending");
  assert.equal(review.importedCount, 6);
  assert.equal(review.duplicateCount, 0);
  assert.equal(review.ambiguousCount, 0);
  assert.equal(review.failedCount, 0);
  assert.equal(review.rows.length, 6);
  assert.deepEqual(review.rows.map((row) => row.actorId),
    roster.map((actor) => actor.actorId));
});

test("scenario sources retain unresolved duplicate, failed and ambiguous rows",
  () => {
    const capacity = practiceRosterReview(session("rosterAndCapacity"));
    assert.equal(capacity.importedCount, 6);
    assert.equal(capacity.duplicateCount, 1);
    assert.equal(capacity.failedCount, 1);
    assert.equal(capacity.rows.length, 8);

    const claim = practiceRosterReview(session("walkInAndAmbiguousClaim"));
    assert.equal(claim.importedCount, 6);
    assert.equal(claim.ambiguousCount, 1);
    assert.equal(claim.rows.at(-1)?.actorId, null);
  });

test("reconciliation fences the exact source and preserves unresolved rows",
  () => {
    const current = session("rosterAndCapacity");
    const source = current.rosterReconciliation!;
    const result = preparePracticeRosterReconciliation(current, {
      sourceId: source.sourceId,
      sourceRevision: source.sourceRevision,
    }, "host-1", "roster_0001");
    assert.equal(result.replayed, false);
    assert.equal(result.state.status, "reconciled");
    assert.equal(result.state.reconciliationRevision, 1);
    assert.equal(result.state.reconciledBy, "host-1");
    assert.equal(result.state.reconciledAt?.toMillis(), 12_000);
    assert.deepEqual(result.state.rows, source.rows);

    const review = practiceRosterReview({
      ...current,
      rosterReconciliation: result.state,
    });
    assert.equal(review.duplicateCount, 1);
    assert.equal(review.failedCount, 1);
  });

test("reconciliation rejects stale, legacy and completed sources", () => {
  const current = session();
  const source = current.rosterReconciliation!;
  assert.throws(() => preparePracticeRosterReconciliation(current, {
    sourceId: source.sourceId,
    sourceRevision: 1,
  }, "host-1", "roster_0001"), isCode("aborted"));
  assert.throws(() => practiceRosterReview({
    ...current,
    rosterReconciliation: undefined,
  }), isCode("failed-precondition"));
  assert.throws(() => preparePracticeRosterReconciliation({
    ...current,
    status: "complete",
  }, {
    sourceId: source.sourceId,
    sourceRevision: source.sourceRevision,
  }, "host-1", "roster_0001"), isCode("failed-precondition"));
});

test("setup generation rebuilds the same source identity at a new revision",
  () => {
    const first = buildPracticeRosterSource(
      "session-1", 2, "smoothRun", roster);
    const reset = buildPracticeRosterSource(
      "session-1", 3, "smoothRun", roster);
    assert.equal(reset.sourceId, first.sourceId);
    assert.equal(reset.sourceRevision, 3);
    assert.equal(reset.status, "pending");
    assert.equal(reset.reconciliationRevision, 0);
  });

test("control callable accepts only its correlated roster command", () => {
  const source = session().rosterReconciliation!;
  const payload = {
    sessionId: "session-1",
    expectedRevision: 4,
    expectedSetupRevision: 2,
    clientActionId: "roster_0001",
    action: "roster",
    roster: {
      sourceId: source.sourceId,
      sourceRevision: source.sourceRevision,
    },
  };
  assert.equal(validateControlEventRehearsalCallablePayload(payload), true);
  assert.equal(validateControlEventRehearsalCallablePayload({
    ...payload,
    roster: undefined,
  }), false);
  assert.equal(validateControlEventRehearsalCallablePayload({
    ...payload,
    practiceOperatorId: "practice-staff:lead",
  }), false);
  assert.equal(validateControlEventRehearsalCallablePayload({
    ...payload,
    allocation: {kind: "propose"},
  }), false);
});

function isCode(code: HttpsError["code"]) {
  return (error: unknown) => error instanceof HttpsError &&
    error.code === code;
}
