import assert from "node:assert/strict";
import test from "node:test";
import {
  applyClubHostProfileRepairPlan,
  buildClubHostProfileRepairPlan,
} from "./recompute_club_host_profiles.mjs";

const projection = {
  publicDisplayName: (user) =>
    user.displayName?.trim() || user.firstName?.trim() || "Runner",
  publicAvatarUrl: (user) => user.photoThumbnailUrls?.[0] ??
    user.photoUrls?.[0] ?? null,
};

test("buildClubHostProfileRepairPlan finds stale host projections",
  async () => {
    const firestore = fakeFirestore({
      users: {
        "host-1": {
          displayName: "New Host",
          photoThumbnailUrls: ["https://example.com/new-thumb.jpg"],
          photoUrls: ["https://example.com/new-full.jpg"],
        },
        "host-2": {
          firstName: "Second",
          photoUrls: ["https://example.com/second.jpg"],
        },
      },
      clubs: {
        "club-1": {
          hostUserId: "host-1",
          hostName: "Old Host",
          hostAvatarUrl: "https://example.com/old.jpg",
        },
        "club-2": {
          hostUserId: "host-2",
          hostName: "Second",
          hostAvatarUrl: "https://example.com/second.jpg",
        },
        "club-3": {
          hostUserId: "missing",
          hostName: "Missing",
        },
      },
    });

    const plan = await buildClubHostProfileRepairPlan(
      firestore,
      projection
    );

    assert.deepEqual(plan.summary.repairs, [
      {
        path: "clubs/club-1",
        clubId: "club-1",
        hostUserId: "host-1",
        current: {
          hostName: "Old Host",
          hostAvatarUrl: "https://example.com/old.jpg",
        },
        expected: {
          hostName: "New Host",
          hostAvatarUrl: "https://example.com/new-thumb.jpg",
        },
      },
    ]);
    assert.deepEqual(plan.summary.warnings, [
      "clubs/club-3 references missing users/missing.",
    ]);
  }
);

test("applyClubHostProfileRepairPlan writes only planned host fields",
  async () => {
    const firestore = fakeFirestore({
      users: {},
      clubs: {
        "club-1": {hostName: "Old", area: "Bandra"},
        "club-2": {hostName: "Stable"},
      },
    });

    await applyClubHostProfileRepairPlan(firestore, {
      repairs: [
        {
          path: "clubs/club-1",
          expected: {
            hostName: "New",
            hostAvatarUrl: "https://example.com/new.jpg",
          },
        },
      ],
    });

    assert.deepEqual(firestore.data.clubs["club-1"], {
      hostName: "New",
      hostAvatarUrl: "https://example.com/new.jpg",
      area: "Bandra",
    });
    assert.equal(firestore.data.clubs["club-2"].hostName, "Stable");
  }
);

function fakeFirestore(initialData) {
  const data = structuredClone(initialData);
  return {
    data,
    collection: (collectionName) => ({
      get: async () => ({
        size: Object.keys(data[collectionName] ?? {}).length,
        docs: Object.entries(data[collectionName] ?? {}).map(([id, value]) =>
          docSnapshot(collectionName, id, value)
        ),
      }),
    }),
    doc: (documentPath) => ({
      path: documentPath,
      update: (patch) => {
        const [collectionName, docId] = documentPath.split("/");
        data[collectionName][docId] = {
          ...data[collectionName][docId],
          ...patch,
        };
      },
    }),
    batch: () => {
      const writes = [];
      return {
        update: (ref, patch) => writes.push(() => ref.update(patch)),
        commit: async () => {
          for (const write of writes) write();
        },
      };
    },
  };
}

function docSnapshot(collectionName, id, value) {
  return {
    id,
    ref: {path: `${collectionName}/${id}`},
    data: () => ({...value}),
  };
}
