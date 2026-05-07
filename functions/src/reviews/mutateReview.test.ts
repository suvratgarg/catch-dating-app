/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {
  createRunReviewHandler,
  deleteRunReviewHandler,
  updateRunReviewHandler,
} from "./mutateReview";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}
}

class FakeSnapshot {
  constructor(private readonly value: FakeData | undefined) {}

  get exists(): boolean {
    return this.value !== undefined;
  }

  data(): FakeData | undefined {
    return this.value === undefined ? undefined : {...this.value};
  }
}

class FakeCollectionRef {
  constructor(
    private readonly firestore: FakeFirestore,
    private path: string
  ) {}

  doc(docId: string) {
    return new FakeDocRef(this.firestore, `${this.path}/${docId}`);
  }
}

class FakeFirestore {
  constructor(private readonly docs: Record<string, FakeData | undefined>) {}

  collection(collectionPath: string) {
    return new FakeCollectionRef(this, collectionPath);
  }

  async runTransaction<T>(
    callback: (tx: FakeTransaction) => Promise<T>
  ): Promise<T> {
    const tx = new FakeTransaction(this);
    const result = await callback(tx);
    tx.commit();
    return result;
  }

  get(path: string): FakeData | undefined {
    const data = this.docs[path];
    return data === undefined ? undefined : {...data};
  }

  set(path: string, data: FakeData | undefined) {
    this.docs[path] = data;
  }
}

class FakeTransaction {
  private readonly writes: Array<() => void> = [];

  constructor(private readonly firestore: FakeFirestore) {}

  async get(ref: FakeDocRef) {
    return new FakeSnapshot(this.firestore.get(ref.path));
  }

  create(ref: FakeDocRef, data: FakeData) {
    this.writes.push(() => {
      if (this.firestore.get(ref.path) !== undefined) {
        throw new Error(`Existing doc for create: ${ref.path}`);
      }
      this.firestore.set(ref.path, data);
    });
  }

  update(ref: FakeDocRef, patch: FakeData) {
    this.writes.push(() => {
      const current = this.firestore.get(ref.path);
      if (current === undefined) {
        throw new Error(`Missing doc for update: ${ref.path}`);
      }
      this.firestore.set(ref.path, {...current, ...patch});
    });
  }

  delete(ref: FakeDocRef) {
    this.writes.push(() => this.firestore.set(ref.path, undefined));
  }

  commit() {
    for (const write of this.writes) write();
  }
}

function harness(initialDocs: Record<string, FakeData | undefined>) {
  const firestore = new FakeFirestore(initialDocs);
  const rateLimitCalls: string[] = [];
  return {
    firestore,
    rateLimitCalls,
    deps: {
      firestore: () =>
        firestore as unknown as FirebaseFirestore.Firestore,
      serverTimestamp: () => ({kind: "serverTimestamp"} as unknown) as
        FirebaseFirestore.FieldValue,
      checkRateLimit: async (
        _db: FirebaseFirestore.Firestore,
        uid: string,
        action: string
      ) => {
        rateLimitCalls.push(`${uid}:${action}`);
      },
    },
  };
}

function request(
  uid: string | null,
  data: Record<string, unknown>
): CallableRequest<unknown> {
  return {
    auth: uid ? {uid, token: {}} as CallableRequest["auth"] : undefined,
    data,
    rawRequest: {} as CallableRequest["rawRequest"],
  } as CallableRequest<unknown>;
}

function assertHttpsCode(error: unknown, code: string): boolean {
  return error instanceof HttpsError && error.code === code;
}

function baseDocs(overrides: Record<string, FakeData | undefined> = {}) {
  return {
    "users/runner-1": {
      name: "Runner One",
      firstName: "Runner",
      displayName: "Runner",
    },
    "runs/run-1": {runClubId: "club-1"},
    "runParticipations/run-1_runner-1": {
      runId: "run-1",
      runClubId: "club-1",
      uid: "runner-1",
      status: "attended",
    },
    ...overrides,
  };
}

test("createRunReviewHandler writes attended runner review", async () => {
  const h = harness(baseDocs());

  const result = await createRunReviewHandler(
    request("runner-1", {
      runClubId: "club-1",
      runId: "run-1",
      rating: 5,
      comment: "  Great run.  ",
    }),
    h.deps
  );

  assert.deepEqual(result, {reviewId: "run-1~runner-1"});
  assert.deepEqual(h.rateLimitCalls, ["runner-1:createRunReview"]);
  const review = h.firestore.get("reviews/run-1~runner-1");
  assert.equal(review?.reviewerName, "Runner");
  assert.equal(review?.comment, "Great run.");
});

test("createRunReviewHandler rejects non-attendees", async () => {
  const h = harness(baseDocs({
    "runParticipations/run-1_runner-1": {
      runId: "run-1",
      runClubId: "club-1",
      uid: "runner-1",
      status: "signedUp",
    },
  }));

  await assert.rejects(
    () => createRunReviewHandler(
      request("runner-1", {
        runClubId: "club-1",
        runId: "run-1",
        rating: 5,
        comment: "Great.",
      }),
      h.deps
    ),
    (error) => assertHttpsCode(error, "failed-precondition")
  );
});

test("updateRunReviewHandler updates only author reviews", async () => {
  const h = harness(baseDocs({
    "reviews/run-1~runner-1": {
      runClubId: "club-1",
      runId: "run-1",
      reviewerUserId: "runner-1",
      reviewerName: "Runner",
      rating: 3,
      comment: "Old.",
    },
  }));

  const result = await updateRunReviewHandler(
    request("runner-1", {
      reviewId: "run-1~runner-1",
      rating: 4,
      comment: "Better.",
    }),
    h.deps
  );

  assert.deepEqual(result, {updated: true});
  assert.deepEqual(h.rateLimitCalls, ["runner-1:updateRunReview"]);
  const review = h.firestore.get("reviews/run-1~runner-1");
  assert.equal(review?.rating, 4);
  assert.equal(review?.comment, "Better.");
});

test("deleteRunReviewHandler deletes only author reviews", async () => {
  const h = harness(baseDocs({
    "reviews/run-1~runner-1": {
      runClubId: "club-1",
      runId: "run-1",
      reviewerUserId: "runner-1",
      reviewerName: "Runner",
      rating: 3,
      comment: "Old.",
    },
  }));

  const result = await deleteRunReviewHandler(
    request("runner-1", {reviewId: "run-1~runner-1"}),
    h.deps
  );

  assert.deepEqual(result, {deleted: true});
  assert.deepEqual(h.rateLimitCalls, ["runner-1:deleteRunReview"]);
  assert.equal(h.firestore.get("reviews/run-1~runner-1"), undefined);
});
