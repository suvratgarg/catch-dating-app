import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import type {EventRehearsalDocument as Session} from
  "../shared/generated/firestoreAdminTypes";
import type {ControlEventRehearsalCallablePayload as Control} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import type {SubmitEventRehearsalGuestActionCallablePayload as GuestAction} from
  "../shared/generated/submitEventRehearsalGuestActionCallablePayload";
import {validateControlEventRehearsalCallablePayload} from
  "../shared/generated/validators/controlEventRehearsalInput";
import {validateSubmitEventRehearsalGuestActionCallablePayload} from
  "../shared/generated/validators/submitEventRehearsalGuestActionInput";
import {buildRehearsalActors} from "./engine";
import {applyPracticeRequiredDataSubmission,
  practiceRequiredDataReview, preparePracticeRequiredDataRequest} from
  "./requiredData";

type HostCommand = NonNullable<Control["requiredData"]>;
type Submission = NonNullable<GuestAction["requiredData"]>;

const minute = 60_000;

function session(now = 10 * minute): Session {
  return {
    status: "running",
    setupRevision: 0,
    virtualStartedAt: Timestamp.fromMillis(0),
    virtualNow: Timestamp.fromMillis(now),
    setup: {durationMinutes: 120, moduleIds: ["arrival", "pods"]},
  } as Session;
}

function actor() {
  return buildRehearsalActors("session-1", 2, 11,
    Timestamp.fromMillis(0))[0]!;
}

function request(s: Session, fields = ["paceBand", "teamName"] as const):
HostCommand {
  const a = actor();
  const review = practiceRequiredDataReview(s, a);
  return {attendeeId: a.actorId, fieldIds: [...fields],
    expiresAt: 30 * minute,
    expectedProfileRevision: review.profileRevision,
    expectedRequestRevision: review.requestRevision,
    expectedSourceHash: review.sourceHash};
}

function submission(review: ReturnType<typeof practiceRequiredDataReview>,
  fieldIds: Submission["fieldIds"]): Submission {
  return {fieldIds, expectedProfileRevision: review.profileRevision,
    expectedRequestRevision: review.requestRevision,
    expectedSourceHash: review.sourceHash};
}

test("practice required-data review exposes no profile values", () => {
  const review = practiceRequiredDataReview(session(), actor());
  assert.equal(review.sourceHash.length, 64);
  assert.equal(review.profileRevision, 0);
  assert.equal(review.requestRevision, 0);
  assert.deepEqual(review.completedFieldIds, ["displayName"]);
  assert.equal(review.availableFieldIds.length, 10);
  assert.equal(review.request, null);
  assert.equal("runtimeProfile" in review, false);
});

test("Host requests only current missing synthetic fields", () => {
  const s = session();
  const a = actor();
  const next = preparePracticeRequiredDataRequest(s, a, request(s));
  const review = practiceRequiredDataReview(s, next);
  assert.equal(review.requestRevision, 1);
  assert.deepEqual(review.request, {
    revision: 1,
    fieldIds: ["paceBand", "teamName"],
    completedFieldIds: [],
    status: "pending",
    requestedAt: 10 * minute,
    expiresAt: 30 * minute,
    completedAt: null,
  });

  const current = practiceRequiredDataReview(s, a);
  assert.throws(() => preparePracticeRequiredDataRequest(s, a, {
    ...request(s), fieldIds: ["displayName"],
    expectedSourceHash: current.sourceHash,
  }), isCode("failed-precondition"));
  assert.throws(() => preparePracticeRequiredDataRequest(s, a, {
    ...request(s), expectedSourceHash: "0".repeat(64),
  }), isCode("aborted"));
});

test("guest practice submissions can complete a request in parts", () => {
  const s = session();
  const requested = preparePracticeRequiredDataRequest(s, actor(), request(s));
  const firstReview = practiceRequiredDataReview(s, requested);
  const partial = applyPracticeRequiredDataSubmission(s, requested,
    submission(firstReview, ["paceBand"]));
  const partialReview = practiceRequiredDataReview(s, partial);
  assert.equal(partialReview.profileRevision, 1);
  assert.deepEqual(partialReview.completedFieldIds,
    ["displayName", "paceBand"]);
  assert.equal(partialReview.request?.status, "pending");
  assert.deepEqual(partialReview.request?.completedFieldIds, ["paceBand"]);

  assert.throws(() => applyPracticeRequiredDataSubmission(s, partial,
    submission(firstReview, ["teamName"])), isCode("aborted"));
  const complete = applyPracticeRequiredDataSubmission(s, partial,
    submission(partialReview, ["teamName"]));
  const completeReview = practiceRequiredDataReview(s, complete);
  assert.equal(completeReview.profileRevision, 2);
  assert.equal(completeReview.request?.status, "completed");
  assert.equal(completeReview.request?.completedAt, 10 * minute);
});

test("virtual event time expires practice requests", () => {
  const started = preparePracticeRequiredDataRequest(session(), actor(),
    request(session()));
  const expiredSession = session(31 * minute);
  const review = practiceRequiredDataReview(expiredSession, started);
  assert.equal(review.request?.status, "expired");
  assert.throws(() => applyPracticeRequiredDataSubmission(expiredSession,
    started, submission(review, ["paceBand"])),
  isCode("failed-precondition"));
});

test("callable schemas correlate Host and guest required-data payloads", () => {
  const s = session();
  const command = request(s);
  assert.equal(validateControlEventRehearsalCallablePayload({
    sessionId: "session-1", expectedRevision: 2,
    expectedSetupRevision: 0, clientActionId: "request_0001",
    action: "requiredData", requiredData: command,
  }), true);
  assert.equal(validateControlEventRehearsalCallablePayload({
    sessionId: "session-1", expectedRevision: 2,
    expectedSetupRevision: 0, clientActionId: "request_0001",
    action: "requiredData",
  }), false);
  const review = practiceRequiredDataReview(s,
    preparePracticeRequiredDataRequest(s, actor(), command));
  const guest = {publicRehearsalId: "public_rehearsal_1234",
    slotToken: "slot_token_1234567890", clientActionId: "profile_0001",
    action: "submitRequiredData", requiredData: submission(review,
      ["paceBand"])};
  assert.equal(validateSubmitEventRehearsalGuestActionCallablePayload(guest),
    true);
  assert.equal(validateSubmitEventRehearsalGuestActionCallablePayload(
    {...guest, requiredData: undefined}), false);
});

function isCode(code: HttpsError["code"]) {
  return (error: unknown) => error instanceof HttpsError &&
    error.code === code;
}
