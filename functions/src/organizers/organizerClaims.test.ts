import assert from "node:assert/strict";
import test from "node:test";
import type {CallableRequest} from "firebase-functions/v2/https";
import {adminDecideOrganizerClaimHandler} from "./organizerClaims";

type Data = Record<string, unknown>;
class Ref {
  constructor(readonly path: string) {}
  collection(name: string) {
    return {doc: (id: string) => new Ref(`${this.path}/${name}/${id}`)};
  }
}

function fixture(visibility: "hidden" | "discoverable" | undefined) {
  const publicPage = {publishStatus: "draft", indexStatus: "noindex",
    canonicalPath: "/organizers/example-host/", robots: "noindex, follow"};
  const docs = new Map<string, Data>([
    ["organizers/example-host", {name: "Example Host",
      ...(visibility ? {appVisibility: visibility} : {}), publicPage,
      ownership: {state: "unclaimed"},
      claim: {state: "claimPending", lastClaimRequestId: "claim-one"}}],
    ["organizerClaimRequests/claim-one", {requestId: "claim-one",
      organizerId: "example-host", requesterUid: "host-one",
      status: "pending"}],
    ["users/host-one", {name: "Example Owner", profileComplete: true}],
  ]);
  let id = 0;
  const db = {
    collection: (path: string) => ({doc: (key = `auto-${++id}`) =>
      new Ref(`${path}/${key}`)}),
    runTransaction: async <T>(run: (tx: unknown) => Promise<T>) => {
      const pending: Array<() => void> = [];
      const set = (ref: Ref, value: Data, options?: {merge?: boolean}) => {
        pending.push(() => docs.set(ref.path, structuredClone(options?.merge ?
          {...docs.get(ref.path), ...value} : value)));
      };
      const result = await run({
        get: async (ref: Ref) => {
          assert.equal(pending.length, 0,
            "Firestore reads must precede writes");
          return {exists: docs.has(ref.path), data: () =>
            structuredClone(docs.get(ref.path))};
        },
        set,
        update: (ref: Ref, value: Data) => set(ref, value, {merge: true}),
      });
      pending.forEach((write) => write());
      return result;
    },
  };
  const deps = {firestore: () => db as unknown as FirebaseFirestore.Firestore,
    serverTimestamp: () => ({kind: "serverTimestamp"}) as unknown as
      FirebaseFirestore.FieldValue};
  const request = {auth: {uid: "reviewer", token: {admin: true}},
    data: {requestId: "claim-one", decision: "approve"},
    rawRequest: {headers: {}}} as unknown as CallableRequest<unknown>;
  return {docs, deps, request, publicPage};
}

for (const visibility of ["hidden", "discoverable", undefined] as const) {
  test(`claim approval preserves ${visibility ?? "missing"} publication state`,
    async () => {
      const {docs, deps, request, publicPage} = fixture(visibility);
      const result = await adminDecideOrganizerClaimHandler(request, deps);
      assert.equal(result.status, "approved");
      const organizer = docs.get("organizers/example-host");
      assert.equal(organizer?.ownerUserId, "host-one");
      assert.equal((organizer?.ownership as Data).state, "claimed");
      assert.equal(organizer?.appVisibility, visibility);
      assert.deepEqual(organizer?.publicPage, publicPage);
      assert.equal([...docs.keys()].filter((path) =>
        path.startsWith("organizerTeamMemberships/")).length, 1);
      assert.equal([...docs.keys()].some((path) =>
        path.startsWith("publicRouteReservations/")), false);
    });
}

test("claim approval still requires an authorized reviewer", async () => {
  const {docs, deps, request} = fixture("hidden");
  request.auth = {uid: "host-one", token: {}} as CallableRequest["auth"];
  const before = structuredClone([...docs]);
  await assert.rejects(adminDecideOrganizerClaimHandler(request, deps),
    {code: "permission-denied"});
  assert.deepEqual([...docs], before);
});
