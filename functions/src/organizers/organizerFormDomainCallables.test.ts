import {strict as assert} from "node:assert";
import {describe, it} from "node:test";
import type {firestore} from "firebase-admin";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {manageOrganizerFormDomainHandler, parseDomainRequest} from
  "./organizerFormDomainCallables";

describe("organizer form domain management input", () => {
  it("accepts exact action-specific fields", () => {
    assert.deepEqual(parseDomainRequest({action: "reserve",
      hostname: "apply.client.example", organizerId: "organizer-a",
      formId: "form-a"}), {action: "reserve",
      hostname: "apply.client.example", organizerId: "organizer-a",
      formId: "form-a"});
    assert.deepEqual(parseDomainRequest({action: "verify",
      hostname: "apply.client.example", organizerId: "organizer-a"}),
    {action: "verify", hostname: "apply.client.example",
      organizerId: "organizer-a"});
  });

  it("rejects client-supplied hosting or certificate authority", () => {
    for (const request of [
      {action: "reserve", hostname: "apply.client.example",
        organizerId: "organizer-a", formId: "form-a",
        expectedCname: "attacker.example"},
      {action: "certificateReady", hostname: "apply.client.example",
        organizerId: "organizer-a"},
      {action: "verify", hostname: "app.catchdates.com",
        organizerId: "organizer-a"},
      {action: "revoke", hostname: "apply.client.example",
        organizerId: "organizer-a", formId: "form-a"},
    ]) assert.throws(() => parseDomainRequest(request));
  });

  it("denies outsiders before lookup or DNS", async () => {
    let touched = false;
    const request = {auth: {uid: "outsider"}, data: {
      action: "verify", hostname: "apply.client.example",
      organizerId: "organizer-a",
    }} as CallableRequest<unknown>;
    await assert.rejects(manageOrganizerFormDomainHandler(request, {
      firestore: () => ({} as firestore.Firestore),
      checkLimit: async () => undefined,
      assertManager: async () => {
        throw new HttpsError("permission-denied", "Denied");
      },
      loadProbe: async () => {
        touched = true;
        return null;
      },
      target: () => "custom.catchdates.com", now: () => 1,
    }), {code: "permission-denied"});
    assert.equal(touched, false);
  });

  it("denies a manager of another organizer before DNS", async () => {
    let touched = false;
    const request = {auth: {uid: "manager-b"}, data: {
      action: "verify", hostname: "apply.client.example",
      organizerId: "organizer-b",
    }} as CallableRequest<unknown>;
    const db = {collection: () => ({doc: () => ({get: async () => ({
      data: () => ({hostname: "apply.client.example",
        organizerId: "organizer-a", formId: "form-a",
        publicFormId: "ABCDEFGHIJKLMNOPQRST",
        ownershipChallenge: "catch-verification=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
        expectedCname: "custom.catchdates.com", status: "pending",
        certificateStatus: "pending", verifiedAtMillis: null,
        generation: 1, reservedAtMillis: 1,
        pendingExpiresAtMillis: 48 * 60 * 60 * 1000}),
    })})})} as unknown as firestore.Firestore;
    await assert.rejects(manageOrganizerFormDomainHandler(request, {
      firestore: () => db, checkLimit: async () => undefined,
      assertManager: async () => undefined,
      loadProbe: async () => {
        touched = true;
        return null;
      },
      target: () => "custom.catchdates.com", now: () => 1,
    }), {code: "failed-precondition"});
    assert.equal(touched, false);
  });
});
