/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {
  syncAuthoredReviewReviewerProfile,
  syncHostedRunClubHostProfile,
  syncUserProfileProjectionsHandler,
} from "./syncPublicProfile";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}

  async set(data: FakeData, options?: {merge: boolean}) {
    this.firestore.set(this.path, data, options);
  }

  async delete() {
    this.firestore.delete(this.path);
  }
}

class FakeBatch {
  private readonly writes: Array<() => void> = [];

  set(ref: FakeDocRef, data: FakeData, options: {merge: boolean}) {
    this.writes.push(() => ref.firestore.set(ref.path, data, options));
  }

  async commit() {
    for (const write of this.writes) write();
  }
}

class FakeFirestore {
  constructor(private readonly docs: Record<string, FakeData | undefined>) {}

  collection(collectionPath: string) {
    return queryRef(this, collectionPath, []);
  }

  batch() {
    return new FakeBatch();
  }

  get(path: string): FakeData | undefined {
    const data = this.docs[path];
    return data === undefined ? undefined : structuredClone(data);
  }

  set(path: string, data: FakeData, options?: {merge: boolean}) {
    const current = this.docs[path] ?? {};
    this.docs[path] = options?.merge ? {...current, ...data} : data;
  }

  delete(path: string) {
    delete this.docs[path];
  }
}

function queryRef(
  firestore: FakeFirestore,
  collectionPath: string,
  filters: Array<{field: string; value: unknown}>
) {
  return {
    doc: (docId: string) =>
      new FakeDocRef(firestore, `${collectionPath}/${docId}`),
    where: (field: string, operator: string, value: unknown) => {
      assert.equal(operator, "==");
      return queryRef(firestore, collectionPath, [...filters, {field, value}]);
    },
    get: async () => {
      const docs = Object.entries((firestore as never as {
        docs: Record<string, FakeData | undefined>;
      }).docs)
        .filter(([path]) => path.startsWith(`${collectionPath}/`))
        .filter(([, data]) => data !== undefined)
        .filter(([, data]) =>
          filters.every((filter) => data?.[filter.field] === filter.value)
        )
        .map(([path, data]) => ({
          ref: new FakeDocRef(firestore, path),
          data: () => structuredClone(data),
        }));
      return {empty: docs.length === 0, docs};
    },
  };
}

function timestamp(date: Date) {
  return {toDate: () => date};
}

function completeUser(overrides: FakeData = {}): FakeData {
  return {
    profileComplete: true,
    name: "Asha Runner",
    firstName: "Asha",
    displayName: "Asha Host",
    dateOfBirth: timestamp(new Date("1996-01-01T00:00:00.000Z")),
    bio: "Morning runner",
    gender: "woman",
    photoUrls: ["https://example.test/full.jpg"],
    photoThumbnailUrls: ["https://example.test/thumb.jpg"],
    paceMinSecsPerKm: 300,
    paceMaxSecsPerKm: 420,
    preferredDistances: [],
    runningReasons: [],
    ...overrides,
  };
}

test("syncUserProfileProjectionsHandler syncs public profile and clubs",
  async () => {
    const firestore = new FakeFirestore({
      "runClubs/club-1": {
        hostUserId: "host-1",
        hostName: "Old Name",
        hostAvatarUrl: "https://old.test/avatar.jpg",
        memberCount: 3,
      },
      "runClubs/club-2": {
        hostUserId: "other-host",
        hostName: "Other Host",
        memberCount: 4,
      },
      "reviews/run-1~host-1": {
        reviewerUserId: "host-1",
        reviewerName: "Old Reviewer",
        rating: 5,
      },
      "reviews/run-1~other-host": {
        reviewerUserId: "other-host",
        reviewerName: "Other Reviewer",
        rating: 4,
      },
    });

    await syncUserProfileProjectionsHandler(
      "host-1",
      completeUser({
        displayName: "Asha Updated",
        photoThumbnailUrls: ["https://example.test/new-thumb.jpg"],
      }) as never,
      {firestore: () => firestore as never}
    );

    assert.equal(
      firestore.get("publicProfiles/host-1")?.name,
      "Asha Updated"
    );
    assert.deepEqual(firestore.get("runClubs/club-1"), {
      hostUserId: "host-1",
      hostName: "Asha Updated",
      hostAvatarUrl: "https://example.test/new-thumb.jpg",
      memberCount: 3,
    });
    assert.equal(
      firestore.get("runClubs/club-2")?.hostName,
      "Other Host"
    );
    assert.equal(
      firestore.get("reviews/run-1~host-1")?.reviewerName,
      "Asha Updated"
    );
    assert.equal(
      firestore.get("reviews/run-1~other-host")?.reviewerName,
      "Other Reviewer"
    );
  }
);

test("syncHostedRunClubHostProfile updates every club hosted by the user",
  async () => {
    const firestore = new FakeFirestore({
      "runClubs/club-1": {hostUserId: "host-1", hostName: "Old 1"},
      "runClubs/club-2": {hostUserId: "host-1", hostName: "Old 2"},
      "runClubs/club-3": {hostUserId: "host-2", hostName: "Other"},
    });

    await syncHostedRunClubHostProfile(
      "host-1",
      {hostName: "New Host", hostAvatarUrl: null},
      {firestore: () => firestore as never}
    );

    assert.equal(firestore.get("runClubs/club-1")?.hostName, "New Host");
    assert.equal(firestore.get("runClubs/club-2")?.hostName, "New Host");
    assert.equal(firestore.get("runClubs/club-3")?.hostName, "Other");
  }
);

test("syncAuthoredReviewReviewerProfile updates every review by the user",
  async () => {
    const firestore = new FakeFirestore({
      "reviews/run-1~reviewer-1": {
        reviewerUserId: "reviewer-1",
        reviewerName: "Old 1",
      },
      "reviews/run-2~reviewer-1": {
        reviewerUserId: "reviewer-1",
        reviewerName: "Old 2",
      },
      "reviews/run-1~reviewer-2": {
        reviewerUserId: "reviewer-2",
        reviewerName: "Other",
      },
    });

    await syncAuthoredReviewReviewerProfile(
      "reviewer-1",
      {reviewerName: "New Reviewer"},
      {firestore: () => firestore as never}
    );

    assert.equal(
      firestore.get("reviews/run-1~reviewer-1")?.reviewerName,
      "New Reviewer"
    );
    assert.equal(
      firestore.get("reviews/run-2~reviewer-1")?.reviewerName,
      "New Reviewer"
    );
    assert.equal(
      firestore.get("reviews/run-1~reviewer-2")?.reviewerName,
      "Other"
    );
  }
);

test("syncUserProfileProjectionsHandler deletes public profile on user delete",
  async () => {
    const firestore = new FakeFirestore({
      "publicProfiles/host-1": {name: "Asha"},
    });

    await syncUserProfileProjectionsHandler(
      "host-1",
      undefined,
      {firestore: () => firestore as never}
    );

    assert.equal(firestore.get("publicProfiles/host-1"), undefined);
  }
);
