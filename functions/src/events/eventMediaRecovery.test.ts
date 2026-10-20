import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp, FieldValue} from "firebase-admin/firestore";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {receiptFor} from "./progressiveSetup/service";
import {
  eventMediaFingerprint,
  updateEventMediaRecovery,
} from "./eventMediaRecovery";

function fixture() {
  const store = new FakeFirestore({
    "organizers/org-1": {
      hostUserId: "host-1",
      status: "active",
      archived: false,
    },
    "events/event-1": {
      organizerId: "org-1",
      status: "active",
      photoUrl: null,
      eventPhotos: [],
      name: "Saved event",
      capacityLimit: 20,
    },
    "organizerEventScheduleLocks/untouched": {eventId: "event-1"},
  });
  const db = store as unknown as FirebaseFirestore.Firestore;
  const photos = [0, 1].map((position) => ({
    id: `photo-000${position}`,
    position,
    url: `https://storage.test/photo-000${position}`,
    storagePath: `events/event-1/media/photo-000${position}/original.jpg`,
    thumbnailUrl: null,
    thumbnailStoragePath: null,
    createdAt: Timestamp.fromMillis(1000),
    updatedAt: Timestamp.fromMillis(1000),
  }));
  const fields = {photoUrl: photos[0].url, eventPhotos: photos};
  const identity = {
    organizerId: "org-1",
    requestId: "request-0001",
    expectedMediaHash: eventMediaFingerprint(store.getDoc("events/event-1")!),
  };
  const params = {
    db,
    actorUid: "host-1",
    eventId: "event-1",
    identity,
    fields,
    serverTimestamp: () => FieldValue.serverTimestamp(),
  };
  return {
    store,
    db,
    photos,
    fields,
    identity,
    params,
    run: () => updateEventMediaRecovery(params),
  };
}

test("media and receipt commit without schedule edits", async () => {
  const h = fixture();
  const result = await h.run();
  assert.equal(result.updated, true);
  assert.equal(result.receipt.eventId, "event-1");
  const saved = h.store.getDoc("events/event-1")!;
  assert.equal(saved.name, "Saved event");
  assert.equal(saved.capacityLimit, 20);
  assert.equal(saved.photoUrl, h.photos[0].url);
  assert.deepEqual(saved.eventPhotos, h.photos);
  assert.deepEqual(h.store.getDoc("organizerEventScheduleLocks/untouched"), {
    eventId: "event-1",
  });
  const receipt = h.store.getDoc(
    receiptFor(h.db, "host-1", "org-1", "request-0001").path
  )!;
  assert.equal(receipt.operation, "media");
  assert.equal(receipt.mediaPayloadHash, result.receipt.payloadHash);
  assert.equal(receipt.appliedRevision, undefined);
});

test("lost acknowledgement replays before newer media", async () => {
  const h = fixture();
  const committed = await h.run();
  h.store.updateDoc("events/event-1", {
    photoUrl: "https://storage.test/newer",
    eventPhotos: [
      {...h.photos[0], id: "newer-photo", url: "https://storage.test/newer"},
    ],
  });
  const newer = h.store.getDoc("events/event-1");
  assert.deepEqual(await h.run(), committed);
  assert.deepEqual(h.store.getDoc("events/event-1"), newer);
});

test("concurrent same requests share their receipt", async () => {
  const h = fixture();
  const [a, b] = await Promise.all([h.run(), h.run()]);
  assert.deepEqual(a, b);
  assert.equal(
    [...h.store.docs.keys()].filter((p) =>
      p.startsWith("eventSetupReceipts/")
    ).length,
    1
  );
  assert.deepEqual(h.store.getDoc("events/event-1")!.eventPhotos, h.photos);
});

test("competing commands preserve the reviewed gallery", async () => {
  const h = fixture();
  const results = await Promise.allSettled([
    h.run(),
    updateEventMediaRecovery({
      ...h.params,
      identity: {...h.identity, requestId: "request-0002"},
    }),
  ]);
  assert.equal(results.filter((r) => r.status === "fulfilled").length, 1);
  const failure = results.find(
    (r) => r.status === "rejected"
  ) as PromiseRejectedResult;
  assert.equal(failure.reason.code, "aborted");
});

test("transaction retries respect concurrent media edits", async () => {
  const h = fixture();
  let changed = false;
  h.store.beforeCommit = async () => {
    if (changed) return;
    changed = true;
    h.store.updateDoc("events/event-1", {
      photoUrl: "https://storage.test/newer",
      eventPhotos: [{...h.photos[0], url: "https://storage.test/newer"}],
    });
  };
  await assert.rejects(h.run(), {code: "aborted"});
  assert.equal(
    h.store.getDoc("events/event-1")!.photoUrl,
    "https://storage.test/newer"
  );
  assert.equal(
    [...h.store.docs.keys()].some((p) => p.startsWith("eventSetupReceipts/")),
    false
  );
});

for (const change of ["url", "timestamp"] as const) {
  test(`same ID conflicts on changed ${change}`, async () => {
    const h = fixture();
    await h.run();
    const before = h.store.getDoc("events/event-1");
    const photos = h.photos.map((photo) => ({
      ...photo,
      ...(change === "url" ?
        {url: `${photo.url}-changed`} :
        {updatedAt: Timestamp.fromMillis(2000)}),
    }));
    await assert.rejects(
      updateEventMediaRecovery({
        ...h.params,
        fields: {photoUrl: photos[0].url, eventPhotos: photos},
      }),
      {code: "already-exists"}
    );
    assert.deepEqual(h.store.getDoc("events/event-1"), before);
  });
}

for (const change of ["deleted", "removed-manager", "archived"] as const) {
  test(`committed replay rechecks ${change} authority`, async () => {
    const h = fixture();
    await h.run();
    if (change === "deleted") h.store.setDoc("deletedUsers/host-1", {});
    if (change === "removed-manager") {
      h.store.updateDoc("organizers/org-1", {hostUserId: "other"});
    }
    if (change === "archived") {
      h.store.updateDoc("organizers/org-1", {archived: true});
    }
    await assert.rejects(h.run(), {
      code:
        change === "removed-manager" ?
          "permission-denied" :
          "failed-precondition",
    });
  });
}

test("receipt creation failure rolls back its gallery mutation", async () => {
  const h = fixture();
  const create = h.store.createDoc.bind(h.store);
  h.store.createDoc = (path, data) => {
    if (path.startsWith("eventSetupReceipts/")) {
      throw new Error("commit failed");
    }
    create(path, data);
  };
  await assert.rejects(h.run(), /commit failed/);
  assert.deepEqual(h.store.getDoc("events/event-1")!.eventPhotos, []);
  assert.equal(h.store.transactionCommits, 0);
});

for (const patch of [
  {status: "cancelled"},
  {setupRevision: 1},
  {publicationState: "private"},
]) {
  test(`lifecycle fence: ${JSON.stringify(patch)}`, async () => {
    const h = fixture();
    h.store.updateDoc("events/event-1", patch);
    await assert.rejects(h.run(), {code: "failed-precondition"});
  });
}

test("later cancellation permits receipt reconciliation", async () => {
  const h = fixture();
  const result = await h.run();
  h.store.updateDoc("events/event-1", {status: "cancelled"});
  assert.deepEqual(await h.run(), result);
  assert.equal(h.store.getDoc("events/event-1")!.status, "cancelled");
});

test("invalid media never reaches a write", async () => {
  const h = fixture();
  for (const fields of [
    {...h.fields, name: "overwrite"},
    {...h.fields, startTimeMillis: 123},
    {photoUrl: null, eventPhotos: []},
    {...h.fields, photoUrl: "https://storage.test/wrong-cover"},
    {
      ...h.fields,
      eventPhotos: [
        {
          ...h.photos[0],
          storagePath: "events/other/media/photo-0000/original.jpg",
        },
      ],
    },
    {...h.fields, eventPhotos: [{...h.photos[0], position: 2}]},
    {...h.fields, eventPhotos: [h.photos[0], {...h.photos[0], position: 1}]},
    {
      ...h.fields,
      eventPhotos: [{...h.photos[0], moderation: {status: "approved"}}],
    },
    {
      ...h.fields,
      eventPhotos: [
        {...h.photos[0], thumbnailUrl: "https://storage.test/foreign"},
      ],
    },
    {
      ...h.fields,
      eventPhotos: [{...h.photos[0], url: "http://storage.test/plain"}],
    },
  ]) {
    await assert.rejects(updateEventMediaRecovery({...h.params, fields}), {
      code: "invalid-argument",
    });
  }
  assert.equal(h.store.transactionCommits, 0);
});

test("metadata byte bound preserves gallery semantics", async () => {
  const h = fixture();
  const photos = Array.from({length: 50}, (_, position) => ({
    ...h.photos[0],
    id: `photo-${String(position).padStart(8, "0")}`,
    position,
    url: `https://storage.test/${"a".repeat(1900)}`,
    storagePath: "events/event-1/media/" +
      `photo-${String(position).padStart(8, "0")}/original.jpg`,
  }));
  await assert.rejects(
    updateEventMediaRecovery({
      ...h.params,
      fields: {photoUrl: photos[0].url, eventPhotos: photos},
    }),
    {code: "invalid-argument"}
  );
  assert.equal(h.store.transactionCommits, 0);
});
