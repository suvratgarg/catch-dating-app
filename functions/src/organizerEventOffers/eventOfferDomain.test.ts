import assert from "node:assert/strict";
import test from "node:test";
import {
  applyEventOfferAction, CurrentOfferContext, EventOffer,
  eventOfferId, OfferAction, OfferDomainError,
} from "./eventOfferDomain";

const now = 1_800_000_000_000;
const paymentHash = "a".repeat(64);
const context: CurrentOfferContext = {
  organizerId: "organizer-1", eventId: "saturday-1",
  contactId: "contact-1", applicationId: "application-1",
  applicationTargetKind: "event", applicationTargetId: "saturday-1",
  actorUid: "manager-1",
  actorAuthorized: true, applicationApproved: true,
  sourceCurrent: true, contactCurrent: true, eventCurrent: true,
  eventStartsAtMillis: now + 3_600_000,
  currentPaymentHash: paymentHash, currentPaymentRevision: 1,
  paymentSnapshot: {eventPaymentRevision: 1,
    eventPaymentHash: paymentHash, expectedAmountMinor: 1000,
    currency: "INR", paymentInstructions: null, messageTemplate: null,
    reusablePaymentPageUrl: null, collectionMode: "personalRequest",
    personalPaymentLink: "https://pay.example.com/organizer/saturday",
    expiresAtMillis: now + 600_000},
};
const terms = {expiresAtMillis: now + 600_000,
  organizerPaymentLink: "https://pay.example.com/organizer/saturday"};

function create(overrides: Partial<CurrentOfferContext> = {}) {
  const selected = {...context, ...overrides};
  return applyEventOfferAction({current: null, context: selected,
    action: {kind: "createDraft", requestId: "request-create",
      expectedRevision: 0, terms}, nowMillis: now});
}

function act(current: EventOffer, action: OfferAction, at = now + 1,
  selected = context) {
  const adjusted = action.kind === "reissueDraft" ? {...selected,
    paymentSnapshot: {...selected.paymentSnapshot!,
      expiresAtMillis: action.terms.expiresAtMillis,
      personalPaymentLink: action.terms.organizerPaymentLink}} : selected;
  return applyEventOfferAction({current, context: adjusted,
    action, nowMillis: at});
}

function assertCode(fn: () => unknown, code: OfferDomainError["code"]): void {
  assert.throws(fn, (error: unknown) =>
    error instanceof OfferDomainError && error.code === code);
}

test("contact-event identity spans applications and separates events", () => {
  const saturday = create().offer;
  assert.equal(saturday.offerId, eventOfferId(context));
  assert.equal(saturday.status, "draft");
  assert.equal(saturday.generation, 1);
  assert.notEqual(saturday.offerId, create({eventId: "sunday-1",
    applicationTargetId: "sunday-1"}).offer.offerId);
  assertCode(() => applyEventOfferAction({current: saturday,
    context: {...context, applicationId: "application-2"},
    action: {kind: "createDraft", requestId: "another-application",
      expectedRevision: 0, terms}, nowMillis: now}), "conflict");
});

test("current manager, source, contact and event are required", () => {
  for (const denied of [
    {actorAuthorized: false}, {applicationApproved: false},
    {sourceCurrent: false}, {contactCurrent: false},
    {eventCurrent: false}, {applicationTargetId: "another-event"},
    {applicationTargetKind: "campaign" as const},
  ]) {
    assertCode(() => create(denied), "denied");
  }
  assert.equal(create({applicationTargetKind: "organizer",
    applicationTargetId: null}).offer.eventId, context.eventId);
  assertCode(() => create({eventStartsAtMillis: now}), "conflict");
});

test("draft terms are time-bounded and reuse public HTTPS policy", () => {
  for (const link of ["http://pay.example.com", "https://localhost/pay",
    "https://127.0.0.1/pay", "https://user:pass@pay.example.com/pay",
    "https://pay.example.com:8443/pay", "https://pay.example.com/pay#token"]) {
    assertCode(() => applyEventOfferAction({current: null, context,
      action: {kind: "createDraft", requestId: "bad-link",
        expectedRevision: 0, terms: {...terms, organizerPaymentLink: link}},
      nowMillis: now}), "invalid");
  }
  for (const expiry of [now, context.eventStartsAtMillis + 1]) {
    assertCode(() => applyEventOfferAction({current: null, context,
      action: {kind: "createDraft", requestId: "bad-expiry",
        expectedRevision: 0, terms: {...terms, expiresAtMillis: expiry}},
      nowMillis: now}), "invalid");
  }
});

test("an earlier event start invalidates old draft terms", () => {
  const draft = create().offer;
  assertCode(() => act(draft, {kind: "offer",
    requestId: "rescheduled-offer", expectedRevision: 1,
    expectedGeneration: 1}, now + 1,
  {...context, eventStartsAtMillis: now + 300_000}), "invalid");
});

test("evidence is not payment; only a manager attests receipt", () => {
  const draft = create().offer;
  assert.equal(draft.manualPayment.status, "none");
  const offered = act(draft, {kind: "offer", requestId: "offer-first",
    expectedRevision: draft.revision,
    expectedGeneration: draft.generation}).offer;
  assert.equal(offered.status, "offered");
  assertCode(() => act(draft, {kind: "recordEvidence",
    requestId: "too-early", expectedRevision: draft.revision,
    expectedGeneration: draft.generation,
    evidenceReference: "bank-ref-123"}), "conflict");
  const evidence = act(offered, {kind: "recordEvidence",
    requestId: "evidence-first", expectedRevision: offered.revision,
    expectedGeneration: offered.generation,
    evidenceReference: "  bank-ref-123  "}).offer;
  assert.equal(evidence.manualPayment.status, "evidenceSubmitted");
  assert.equal(evidence.manualPayment.evidenceReference, "bank-ref-123");
  assert.equal(evidence.manualPayment.reviewedByUid, null);
  assert.equal("paidAt" in evidence, false);
  assert.equal("attendeeId" in evidence, false);
  assertCode(() => act(offered, {kind: "reconcileEvidence",
    requestId: "no-evidence", expectedRevision: offered.revision,
    expectedGeneration: offered.generation,
    decision: "hostAttestedReceived", reviewNote: "Bank receipt checked",
    bankReceiptChecked: true}), "conflict");
  const reviewed = act(evidence, {kind: "reconcileEvidence",
    requestId: "review-first", expectedRevision: evidence.revision,
    expectedGeneration: evidence.generation,
    decision: "hostAttestedReceived", reviewNote: "Bank receipt checked",
    bankReceiptChecked: true}).offer;
  assert.equal(reviewed.manualPayment.status, "hostAttestedReceived");
  assert.equal(reviewed.manualPayment.reviewedByUid, "manager-1");
  assert.equal(reviewed.status, "offered");
  assert.equal("providerPaymentId" in reviewed.manualPayment, false);
});

test("receipt replay returns current state after later changes", () => {
  const created = create();
  const action = {kind: "offer" as const, requestId: "offer-once",
    expectedRevision: 1, expectedGeneration: 1};
  const offered = act(created.offer, action);
  const withdrawn = act(offered.offer, {kind: "withdraw",
    requestId: "withdraw-once", expectedRevision: 2,
    expectedGeneration: 1});
  const replay = applyEventOfferAction({current: withdrawn.offer,
    context, action, priorReceipt: offered.receipt, nowMillis: now + 3});
  assert.equal(replay.replayed, true);
  assert.equal(replay.offer.status, "withdrawn",
    "replay cannot revive a superseded offer");
  assertCode(() => applyEventOfferAction({current: withdrawn.offer,
    context, action: {...action, kind: "withdraw"},
    priorReceipt: offered.receipt, nowMillis: now + 3}), "conflict");
  assertCode(() => act(withdrawn.offer, action), "conflict");
});

test("revision/generation fence simultaneous writes and closed offers", () => {
  const draft = create().offer;
  const offerAction = {kind: "offer" as const, requestId: "first-writer",
    expectedRevision: 1, expectedGeneration: 1};
  const first = act(draft, offerAction).offer;
  assertCode(() => act(first, {...offerAction,
    requestId: "second-writer"}), "conflict");
  assertCode(() => act(first, {kind: "expire", requestId: "early-expire",
    expectedRevision: 2, expectedGeneration: 1}), "conflict");
  const expired = act(first, {kind: "expire", requestId: "due-expire",
    expectedRevision: 2, expectedGeneration: 1}, terms.expiresAtMillis).offer;
  const reissued = act(expired, {kind: "reissueDraft",
    requestId: "new-generation", expectedRevision: 3,
    expectedGeneration: 1, terms: {...terms,
      expiresAtMillis: now + 1_200_000}}, now + 800_000).offer;
  assert.equal(reissued.generation, 2);
  assert.equal(reissued.revision, 4);
  assert.equal(reissued.manualPayment.status, "none");
  assertCode(() => act(reissued, {kind: "offer", requestId: "old-generation",
    expectedRevision: 4, expectedGeneration: 1}, now + 800_001), "conflict");
  assertCode(() => act(reissued, {kind: "expire", requestId: "old-expiry",
    expectedRevision: 3, expectedGeneration: 1}, now + 800_001), "conflict");
});

test("source replacement requires an explicit new generation", () => {
  const draft = create().offer;
  const replacement = {...context, applicationId: "application-2"};
  assertCode(() => act(draft, {kind: "offer",
    requestId: "changed-source", expectedRevision: 1,
    expectedGeneration: 1}, now + 2, replacement), "conflict");
  const offered = act(draft, {kind: "offer",
    requestId: "offer-original", expectedRevision: 1,
    expectedGeneration: 1}).offer;
  const withdrawn = act(offered, {kind: "withdraw",
    requestId: "close-original", expectedRevision: 2,
    expectedGeneration: 1}).offer;
  const reissued = act(withdrawn, {kind: "reissueDraft",
    requestId: "from-new-application", expectedRevision: 3,
    expectedGeneration: 1, terms}, now + 2, replacement).offer;
  assert.equal(reissued.applicationId, "application-2");
  assert.equal(reissued.generation, 2);
});

test("closure and payment review survive start and revoked source", () => {
  const offered = act(create().offer, {kind: "offer",
    requestId: "late-offer", expectedRevision: 1,
    expectedGeneration: 1}).offer;
  const closedContext = {...context, sourceCurrent: false,
    applicationApproved: false, eventCurrent: false};
  const expired = act(offered, {kind: "expire",
    requestId: "late-expire", expectedRevision: 2,
    expectedGeneration: 1}, context.eventStartsAtMillis + 1,
  closedContext).offer;
  assert.equal(expired.status, "expired");
  const evidence = act(expired, {kind: "recordEvidence",
    requestId: "late-evidence", expectedRevision: 3,
    expectedGeneration: 1, evidenceReference: "late-bank-reference"},
  context.eventStartsAtMillis + 2, closedContext).offer;
  const attested = act(evidence, {kind: "reconcileEvidence",
    requestId: "late-review", expectedRevision: 4,
    expectedGeneration: 1, decision: "hostAttestedReceived",
    reviewNote: "Statement checked", bankReceiptChecked: true},
  context.eventStartsAtMillis + 3, closedContext).offer;
  assert.equal(attested.status, "expired");
  assert.equal(attested.manualPayment.status, "hostAttestedReceived");
  assert.equal(attested.manualPayment.reviewedByUid, context.actorUid);
  assertCode(() => act(attested, {kind: "recordEvidence",
    requestId: "replace-evidence", expectedRevision: 5,
    expectedGeneration: 1, evidenceReference: "another-reference"},
  context.eventStartsAtMillis + 4, closedContext), "conflict");
  assertCode(() => act(attested, {kind: "reissueDraft",
    requestId: "erase-evidence", expectedRevision: 5,
    expectedGeneration: 1, terms}, context.eventStartsAtMillis + 4),
  "conflict");
  assertCode(() => act(attested, {kind: "reconcileEvidence",
    requestId: "outsider-review", expectedRevision: 5,
    expectedGeneration: 1, decision: "rejected",
    reviewNote: "No matching bank credit", bankReceiptChecked: false},
  context.eventStartsAtMillis + 4,
  {...closedContext, actorAuthorized: false}), "denied");
});

test("draft closure rejects evidence; later evidence bars reissue", () => {
  const draft = create().offer;
  const withdrawnDraft = act(draft, {kind: "withdraw",
    requestId: "withdraw-draft", expectedRevision: 1,
    expectedGeneration: 1}).offer;
  assertCode(() => act(withdrawnDraft, {kind: "recordEvidence",
    requestId: "draft-reference", expectedRevision: 2,
    expectedGeneration: 1, evidenceReference: "bank-reference"}), "conflict");

  const offered = act(draft, {kind: "offer", requestId: "offer-for-evidence",
    expectedRevision: 1, expectedGeneration: 1}).offer;
  const evidence = act(offered, {kind: "recordEvidence",
    requestId: "early-evidence", expectedRevision: 2,
    expectedGeneration: 1, evidenceReference: "bank-reference"}).offer;
  const closed = act(evidence, {kind: "withdraw",
    requestId: "withdraw-with-evidence", expectedRevision: 3,
    expectedGeneration: 1}).offer;
  assertCode(() => act(closed, {kind: "reissueDraft",
    requestId: "reissue-with-evidence", expectedRevision: 4,
    expectedGeneration: 1, terms}, now + 2), "conflict");
  assert.equal(closed.manualPayment.evidenceReference, "bank-reference");
  assert.equal(offered.offeredAtMillis, now + 1);
  assert.equal(draft.offeredAtMillis, null);
});

test("receipt hash uses semantic fields, not property order", () => {
  const created = create();
  const sameAction = {expectedRevision: 0, terms: {...terms},
    requestId: "request-create", kind: "createDraft" as const};
  const replay = applyEventOfferAction({current: created.offer,
    context, action: sameAction, nowMillis: now + 1,
    priorReceipt: created.receipt});
  assert.equal(replay.replayed, true);
  assert.equal(replay.offer.revision, 1);
});
