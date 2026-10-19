import assert from "node:assert/strict";
import test from "node:test";
import type {CallableRequest} from "firebase-functions/v2/https";
import {followOrganizerHandler, unfollowOrganizerHandler} from "./follows";

type Data = Record<string, unknown>;
function fixture(profile: Data = {name: "Ada", phoneNumber: "+919876543210",
  profileComplete: false}) {
  const docs = new Map<string, Data>([
    ["organizers/host", {followerCount: 0}], ["users/guest", profile],
  ]);
  const db = {
    collection: (path: string) => ({doc: (id: string) => `${path}/${id}`}),
    runTransaction: async (run: (tx: unknown) => Promise<void>) => {
      const writes: Array<() => void> = [];
      const set = (path: string, patch: Data) => writes.push(() =>
        docs.set(path, {...docs.get(path), ...patch}));
      await run({get: async (path: string) => {
        assert.equal(writes.length, 0, "All reads precede writes");
        return {exists: docs.has(path), data: () => docs.get(path)};
      }, update: set, set});
      writes.forEach((write) => write());
    },
  };
  const deps = {firestore: () => db as unknown as FirebaseFirestore.Firestore};
  const request = {auth: {uid: "guest", token: {}},
    data: {organizerId: "host"}} as CallableRequest<unknown>;
  return {docs, deps, request};
}

test("minimal accounts follow idempotently", async () => {
  const {docs, deps, request} = fixture();
  assert.deepEqual(await followOrganizerHandler(request, deps),
    {following: true});
  await followOrganizerHandler(request, deps);
  assert.equal(docs.get("organizers/host")?.followerCount, 1);
  assert.equal(docs.get("organizerFollows/host_guest")?.status, "active");
  await unfollowOrganizerHandler(request, deps);
  await unfollowOrganizerHandler(request, deps);
  assert.equal(docs.get("organizers/host")?.followerCount, 0);
  await followOrganizerHandler(request, deps);
  assert.equal(docs.get("organizers/host")?.followerCount, 1);
});

for (const profile of [{name: "Ada"}, {phoneNumber: "+919876543210"},
  {name: "Ada", phoneNumber: "+919876543210", deleted: true}]) {
  test("incomplete or deleted identity cannot follow", async () => {
    const {docs, deps, request} = fixture(profile);
    await assert.rejects(followOrganizerHandler(request, deps),
      {code: "failed-precondition"});
    assert.equal(docs.get("organizers/host")?.followerCount, 0);
    assert.equal(docs.has("organizerFollows/host_guest"), false);
  });
}

test("tombstones and unauthenticated requests remain denied", async () => {
  const {docs, deps, request} = fixture();
  docs.set("deletedUsers/guest", {});
  await assert.rejects(followOrganizerHandler(request, deps),
    {code: "failed-precondition"});
  request.auth = undefined;
  await assert.rejects(followOrganizerHandler(request, deps),
    {code: "unauthenticated"});
});
