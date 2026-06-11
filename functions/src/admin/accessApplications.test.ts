import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {
  adminDecideAccessApplicationHandler,
  normalizeDecisionPayload,
} from "./accessApplications";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}
}

class FakeSnapshot {
  constructor(
    private readonly firestore: FakeFirestore,
    readonly path: string
  ) {}

  get exists(): boolean {
    return this.firestore.get(this.path) !== undefined;
  }

  data(): FakeData | undefined {
    const value = this.firestore.get(this.path);
    return value === undefined ? undefined : {...value};
  }
}

class FakeCollectionRef {
  constructor(
    private readonly firestore: FakeFirestore,
    private readonly path: string
  ) {}

  doc(docId?: string) {
    return new FakeDocRef(
      this.firestore,
      `${this.path}/${docId ?? this.firestore.autoId()}`
    );
  }
}

class FakeFirestore {
  private autoIdCounter = 0;

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

  autoId(): string {
    this.autoIdCounter += 1;
    return `auto-${this.autoIdCounter}`;
  }

  get(path: string): FakeData | undefined {
    const value = this.docs[path];
    return value === undefined ? undefined : {...value};
  }

  merge(path: string, patch: FakeData): void {
    this.docs[path] = {...(this.docs[path] ?? {}), ...patch};
  }

  adminAuditLogs(): FakeData[] {
    return Object.entries(this.docs)
      .filter(([path, value]) =>
        path.startsWith("adminAuditLogs/") && value !== undefined
      )
      .map(([, value]) => value as FakeData);
  }
}

class FakeTransaction {
  private readonly writes: Array<() => void> = [];

  constructor(private readonly firestore: FakeFirestore) {}

  async get(ref: FakeDocRef): Promise<FakeSnapshot> {
    return new FakeSnapshot(this.firestore, ref.path);
  }

  set(ref: FakeDocRef, data: FakeData, _options?: {merge: boolean}): void {
    void _options;
    this.writes.push(() => this.firestore.merge(ref.path, data));
  }

  commit(): void {
    for (const write of this.writes) write();
  }
}

test("normalizeDecisionPayload trims and validates decisions", () => {
  assert.deepEqual(
    normalizeDecisionPayload({
      applicationUid: " runner-1 ",
      decision: "approve",
      note: " welcome ",
      cohortId: " delhi-1 ",
    }),
    {
      applicationUid: "runner-1",
      decision: "approve",
      note: "welcome",
      cohortId: "delhi-1",
    }
  );
});

test("normalizeDecisionPayload rejects invalid decisions", () => {
  assert.throws(
    () => normalizeDecisionPayload({
      applicationUid: "runner-1",
      decision: "archive",
    }),
    (error) =>
      error instanceof HttpsError && error.code === "invalid-argument"
  );
});

test(
  "adminDecideAccessApplicationHandler approves pending applications",
  async () => {
    const firestore = new FakeFirestore({
      "accessApplications/runner-1": {
        status: "pending",
        city: "delhi",
      },
    });

    const result = await adminDecideAccessApplicationHandler(
      request({
        applicationUid: "runner-1",
        decision: "approve",
        note: "Strong founding cohort fit.",
        cohortId: "delhi-founders",
      }),
      deps(firestore)
    );

    assert.deepEqual(result, {
      applicationUid: "runner-1",
      decision: "approve",
      status: "approvedForProfile",
    });
    assert.equal(
      firestore.get("accessApplications/runner-1")?.status,
      "approvedForProfile"
    );
    assert.equal(
      firestore.get("accessApplications/runner-1")?.reviewerUid,
      "admin-1"
    );
    assert.equal(
      firestore.get("accessApplications/runner-1")?.cohortId,
      "delhi-founders"
    );
    assert.equal(firestore.adminAuditLogs().length, 1);
    assert.equal(
      firestore.adminAuditLogs()[0].action,
      "adminDecideAccessApplication"
    );
  }
);

test(
  "adminDecideAccessApplicationHandler denies pending applications",
  async () => {
    const firestore = new FakeFirestore({
      "accessApplications/runner-2": {status: "pending"},
    });

    const result = await adminDecideAccessApplicationHandler(
      request({applicationUid: "runner-2", decision: "deny"}),
      deps(firestore)
    );

    assert.deepEqual(result, {
      applicationUid: "runner-2",
      decision: "deny",
      status: "notSelectedYet",
    });
    assert.equal(
      firestore.get("accessApplications/runner-2")?.status,
      "notSelectedYet"
    );
  }
);

test(
  "adminDecideAccessApplicationHandler blocks viewer-only admins",
  async () => {
    const firestore = new FakeFirestore({
      "accessApplications/runner-3": {status: "pending"},
    });

    await assert.rejects(
      () => adminDecideAccessApplicationHandler(
        request(
          {applicationUid: "runner-3", decision: "approve"},
          {analyticsViewer: true}
        ),
        deps(firestore)
      ),
      (error) =>
        error instanceof HttpsError && error.code === "permission-denied"
    );
  }
);

test(
  "adminDecideAccessApplicationHandler rejects reviewed applications",
  async () => {
    const firestore = new FakeFirestore({
      "accessApplications/runner-4": {status: "approvedForProfile"},
    });

    await assert.rejects(
      () => adminDecideAccessApplicationHandler(
        request({applicationUid: "runner-4", decision: "deny"}),
        deps(firestore)
      ),
      (error) =>
        error instanceof HttpsError && error.code === "failed-precondition"
    );
  }
);

function request(
  data: Record<string, unknown>,
  token: Record<string, unknown> = {support: true}
): CallableRequest<unknown> {
  return {
    auth: {uid: "admin-1", token},
    data,
  } as unknown as CallableRequest<unknown>;
}

function deps(firestore: FakeFirestore) {
  return {
    firestore: () => firestore as unknown as FirebaseFirestore.Firestore,
    serverTimestamp: () =>
      "SERVER_TIMESTAMP" as unknown as FirebaseFirestore.FieldValue,
  };
}
