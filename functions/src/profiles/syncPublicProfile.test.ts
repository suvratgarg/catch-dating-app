/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {
  syncAuthoredReviewReviewerProfile,
  syncHostedClubHostProfile,
  syncUserProfileProjectionsHandler,
} from "./syncPublicProfile";
import {defaultProfilePromptIds} from "../shared/generated/schemaRegistry";

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
  filters: Array<{field: string; operator: string; value: unknown}>
) {
  return {
    doc: (docId: string) =>
      new FakeDocRef(firestore, `${collectionPath}/${docId}`),
    where: (field: string, operator: string, value: unknown) => {
      assert.ok(["==", "array-contains"].includes(operator));
      return queryRef(
        firestore,
        collectionPath,
        [...filters, {field, operator, value}]
      );
    },
    get: async () => {
      const docs = Object.entries((firestore as never as {
        docs: Record<string, FakeData | undefined>;
      }).docs)
        .filter(([path]) => path.startsWith(`${collectionPath}/`))
        .filter(([, data]) => data !== undefined)
        .filter(([, data]) =>
          filters.every((filter) => {
            const fieldValue = data?.[filter.field];
            if (filter.operator === "==") return fieldValue === filter.value;
            return Array.isArray(fieldValue) &&
              fieldValue.includes(filter.value);
          })
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
    phoneNumber: "+919900000001",
    countryCode: "+91",
    profilePrompts: defaultProfilePromptIds.map((promptId) => ({
      promptId,
      prompt: `Prompt ${promptId}`,
      answer: `Answer ${promptId}`,
    })),
    photoPrompts: [],
    gender: "woman",
    interestedInGenders: ["man"],
    photoUrls: [
      "https://example.test/full-1.jpg",
      "https://example.test/full-2.jpg",
    ],
    photoThumbnailUrls: [
      "https://example.test/thumb-1.jpg",
      "https://example.test/thumb-2.jpg",
    ],
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
      "clubs/club-1": {
        hostUserId: "host-1",
        hostName: "Old Name",
        hostAvatarUrl: "https://old.test/avatar.jpg",
        memberCount: 3,
      },
      "clubs/club-2": {
        hostUserId: "other-host",
        hostName: "Other Host",
        memberCount: 4,
      },
      "reviews/event-1~host-1": {
        reviewerUserId: "host-1",
        reviewerName: "Old Reviewer",
        rating: 5,
      },
      "reviews/event-1~other-host": {
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
    assert.deepEqual(firestore.get("clubs/club-1"), {
      hostUserId: "host-1",
      hostName: "Asha Updated",
      hostAvatarUrl: "https://example.test/new-thumb.jpg",
      hostProfiles: [{
        uid: "host-1",
        displayName: "Asha Updated",
        avatarUrl: "https://example.test/new-thumb.jpg",
        role: "owner",
      }],
      memberCount: 3,
    });
    assert.equal(
      firestore.get("clubs/club-2")?.hostName,
      "Other Host"
    );
    assert.equal(
      firestore.get("reviews/event-1~host-1")?.reviewerName,
      "Asha Updated"
    );
    assert.equal(
      firestore.get("reviews/event-1~other-host")?.reviewerName,
      "Other Reviewer"
    );
  }
);

test("syncUserProfileProjectionsHandler deletes profiles below social-ready",
  async () => {
    const firestore = new FakeFirestore({
      "publicProfiles/host-1": {name: "Old Public"},
    });

    await syncUserProfileProjectionsHandler(
      "host-1",
      completeUser({
        profileComplete: false,
        photoUrls: ["https://example.test/full-1.jpg"],
        photoThumbnailUrls: ["https://example.test/thumb-1.jpg"],
      }) as never,
      {firestore: () => firestore as never}
    );

    assert.equal(firestore.get("publicProfiles/host-1"), undefined);
  }
);

test("syncHostedClubHostProfile updates every club hosted by the user",
  async () => {
    const firestore = new FakeFirestore({
      "clubs/club-1": {hostUserId: "host-1", hostName: "Old 1"},
      "clubs/club-2": {hostUserId: "host-1", hostName: "Old 2"},
      "clubs/club-3": {hostUserId: "host-2", hostName: "Other"},
    });

    await syncHostedClubHostProfile(
      "host-1",
      {hostName: "New Host", hostAvatarUrl: null},
      {firestore: () => firestore as never}
    );

    assert.equal(firestore.get("clubs/club-1")?.hostName, "New Host");
    assert.equal(firestore.get("clubs/club-2")?.hostName, "New Host");
    assert.equal(firestore.get("clubs/club-3")?.hostName, "Other");
  }
);

test("syncAuthoredReviewReviewerProfile updates every review by the user",
  async () => {
    const firestore = new FakeFirestore({
      "reviews/event-1~reviewer-1": {
        reviewerUserId: "reviewer-1",
        reviewerName: "Old 1",
      },
      "reviews/event-2~reviewer-1": {
        reviewerUserId: "reviewer-1",
        reviewerName: "Old 2",
      },
      "reviews/event-1~reviewer-2": {
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
      firestore.get("reviews/event-1~reviewer-1")?.reviewerName,
      "New Reviewer"
    );
    assert.equal(
      firestore.get("reviews/event-2~reviewer-1")?.reviewerName,
      "New Reviewer"
    );
    assert.equal(
      firestore.get("reviews/event-1~reviewer-2")?.reviewerName,
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
