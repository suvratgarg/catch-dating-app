import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {SeatAuthorityError} from "../events/seatAuthority/seatAuthority";
import {SeatIdentityAuthorityError} from "../events/seatIdentityAuthority";
import {OfferDomainError} from "../organizerEventOffers/eventOfferDomain";
import {AdmissionPolicyError} from "./admissionPolicy";
import {commitOrganizerFormAdmissionHandler as handle,
  FormAdmissionCallableDependencies} from "./callable";

const payload = {organizerId: "org", eventId: "event", responseId: "response",
  contactId: "contact", offerId: "offer", expectedOfferRevision: 2,
  expectedOfferGeneration: 1, expectedLedgerRevision: 3,
  requestId: "request-123"};
const request = (data: unknown = payload, uid = "manager") => ({data,
  ...(uid ? {auth: {uid, token: {}}} : {})}) as CallableRequest<unknown>;
const code = (expected: string) => (error: unknown) =>
  error instanceof HttpsError && error.code === expected;
const receipt = {receiptId: "receipt", organizerId: "org", eventId: "event",
  responseId: "response", contactId: "contact", offerId: "offer",
  attendeeId: "attendee", canonicalSeatKey: "canonical",
  requestId: "request-123",
  requestHash: "a".repeat(64), resultingLedgerRevision: 4,
  admittedAtMillis: 1800000000000, seatAlreadyOccupied: false, replayed: false};

function fixture() {
  const calls: string[] = [];
  const db = {} as FirebaseFirestore.Firestore;
  const deps: FormAdmissionCallableDependencies = {
    firestore: () => {
      calls.push("database"); return db;
    },
    checkRateLimit: async (actual, uid, action) => {
      assert.equal(actual, db);
      assert.equal(uid, "manager");
      assert.equal(action, "commitOrganizerFormAdmission");
      calls.push("rate");
    },
    commit: async (input) => {
      assert.equal(input.db, db);
      assert.equal(input.actorUid, "manager");
      assert.deepEqual(input.payload, payload);
      calls.push("commit");
      return receipt;
    },
  };
  return {deps, calls};
}

test("admission requires authentication and exact input before database access",
  async () => {
    const {deps, calls} = fixture();
    await assert.rejects(handle(request(payload, ""), deps),
      code("unauthenticated"));
    for (const patch of [{actorUid: "other"}, {managerAuthorized: true},
      {providerPaid: true}, {seatAlreadyOccupied: true},
      {expectedLedgerRevision: 0}]) {
      await assert.rejects(handle(request({...payload, ...patch}), deps),
        code("invalid-argument"));
    }
    assert.deepEqual(calls, []);
  });

test("admission rate limit precedes the atomic service", async () => {
  const {deps, calls} = fixture();
  assert.deepEqual(await handle(request(), deps), receipt);
  assert.deepEqual(calls, ["database", "rate", "commit"]);
  deps.checkRateLimit = async () => {
    throw new HttpsError("resource-exhausted", "Slow down.");
  };
  await assert.rejects(handle(request(), deps), code("resource-exhausted"));
  assert.equal(calls.filter((call) => call === "commit").length, 1);
});

test("admission maps stale, denied and missing seat authority to typed errors",
  async () => {
    const {deps} = fixture();
    for (const [error, expected] of [
      [new AdmissionPolicyError("denied", "Manager revoked"),
        "permission-denied"],
      [new AdmissionPolicyError("stale", "Offer changed"),
        "failed-precondition"],
      [new SeatAuthorityError("unavailable", "Ledger unreconciled"),
        "failed-precondition"],
      [new SeatIdentityAuthorityError("unavailable", "Ambiguous identity"),
        "failed-precondition"],
      [new OfferDomainError("conflict", "Malformed offer"),
        "failed-precondition"],
    ] as const) {
      deps.commit = async () => {
        throw error;
      };
      await assert.rejects(handle(request(), deps), code(expected));
    }
  });

test("admission validates receipts and preserves replay", async () => {
  const {deps} = fixture();
  deps.commit = async () => ({...receipt, replayed: true});
  assert.equal((await handle(request(), deps)).replayed, true);
  deps.commit = async () => ({...receipt, secret: "must not escape"});
  await assert.rejects(handle(request(), deps), code("internal"));
});
