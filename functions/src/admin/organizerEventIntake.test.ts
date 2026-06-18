import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest} from "firebase-functions/v2/https";
import {
  adminDecideOrganizerEventCandidateHandler,
  decisionIdForCandidate,
} from "./organizerEventIntake";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  readonly id: string;

  constructor(readonly firestore: FakeFirestore, readonly path: string) {
    this.id = path.split("/").at(-1) ?? "";
  }
}

class FakeSnapshot {
  constructor(private readonly value: FakeData | undefined) {}

  get exists(): boolean {
    return this.value !== undefined;
  }

  data(): FakeData | undefined {
    return this.value === undefined ? undefined : structuredClone(this.value);
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
  private nextAutoId = 0;

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
    this.nextAutoId += 1;
    return `auto-${this.nextAutoId}`;
  }

  get(path: string): FakeData | undefined {
    const data = this.docs[path];
    return data === undefined ? undefined : structuredClone(data);
  }

  set(path: string, data: FakeData) {
    this.docs[path] = structuredClone(data);
  }

  auditLogs(): FakeData[] {
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
    return new FakeSnapshot(this.firestore.get(ref.path));
  }

  set(
    ref: FakeDocRef,
    data: FakeData,
    options?: {merge?: boolean}
  ) {
    this.writes.push(() => {
      if (options?.merge) {
        this.firestore.set(ref.path, {
          ...(this.firestore.get(ref.path) ?? {}),
          ...data,
        });
        return;
      }
      this.firestore.set(ref.path, data);
    });
  }

  commit() {
    for (const write of this.writes) write();
  }
}

function harness(initialDocs: Record<string, FakeData | undefined> = {}) {
  const firestore = new FakeFirestore(initialDocs);
  return {
    firestore,
    deps: {
      firestore: () =>
        firestore as unknown as FirebaseFirestore.Firestore,
      serverTimestamp: () =>
        "SERVER_TIMESTAMP" as unknown as FirebaseFirestore.FieldValue,
    },
  };
}

function callableRequest(
  uid: string | null,
  data: Record<string, unknown>,
  token: Record<string, unknown> = {}
): CallableRequest<unknown> {
  return {
    auth: uid ? {uid, token} as CallableRequest["auth"] : undefined,
    data,
    rawRequest: {headers: {}} as CallableRequest["rawRequest"],
  } as CallableRequest<unknown>;
}

function completeChecklist() {
  return {
    identityReviewed: true,
    sourceEventReviewed: true,
    timeReviewed: true,
    locationReviewed: true,
    dedupeReviewed: true,
    ownerSafeCopyReviewed: true,
    importPolicyAcknowledged: true,
  };
}

function incompleteChecklist() {
  return {
    ...completeChecklist(),
    dedupeReviewed: false,
  };
}

function approvalPayload(overrides: FakeData = {}) {
  return {
    candidateId: "2026-06-17-afterfly-luma-events:pxgmph3b",
    decision: "approve_for_import",
    checklist: completeChecklist(),
    note: "Manual event QA complete.",
    ...overrides,
  };
}

function assertHttpsCode(error: unknown, code: string): boolean {
  assert.equal((error as {code?: string}).code, code);
  return true;
}

test("adminDecideOrganizerEventCandidateHandler records an approval decision",
  async () => {
    const h = harness();

    const result = await adminDecideOrganizerEventCandidateHandler(
      callableRequest("admin-1", approvalPayload(), {support: true}),
      h.deps
    );

    assert.deepEqual(result, {
      candidateId: "2026-06-17-afterfly-luma-events:pxgmph3b",
      decisionId: "event-2026-06-17-afterfly-luma-events-pxgmph3b",
      decision: "approve_for_import",
      decisionStatus: "approved_for_import",
      decisionPath:
        "organizerEventCandidateReviewDecisions/" +
        "event-2026-06-17-afterfly-luma-events-pxgmph3b",
      importState: "blocked_by_policy",
    });
    assert.deepEqual(
      h.firestore.get(
        "organizerEventCandidateReviewDecisions/" +
          "event-2026-06-17-afterfly-luma-events-pxgmph3b"
      ),
      {
        schemaVersion: 1,
        decisionId: "event-2026-06-17-afterfly-luma-events-pxgmph3b",
        candidateId: "2026-06-17-afterfly-luma-events:pxgmph3b",
        decision: "approve_for_import",
        decisionStatus: "approved_for_import",
        checklist: completeChecklist(),
        note: "Manual event QA complete.",
        reviewedByUid: "admin-1",
        reviewedAt: "SERVER_TIMESTAMP",
        updatedAt: "SERVER_TIMESTAMP",
        importState: "blocked_by_policy",
      }
    );
    assert.equal(h.firestore.auditLogs().length, 1);
  });

test("adminDecideOrganizerEventCandidateHandler rejects incomplete approvals",
  async () => {
    const h = harness();

    await assert.rejects(
      () => adminDecideOrganizerEventCandidateHandler(
        callableRequest("admin-1", approvalPayload({
          checklist: incompleteChecklist(),
        }), {support: true}),
        h.deps
      ),
      (error) => assertHttpsCode(error, "failed-precondition")
    );
    assert.equal(
      h.firestore.get(
        "organizerEventCandidateReviewDecisions/" +
          "event-2026-06-17-afterfly-luma-events-pxgmph3b"
      ),
      undefined
    );
  });

test("adminDecideOrganizerEventCandidateHandler keeps holds non-importable",
  async () => {
    const h = harness();

    const result = await adminDecideOrganizerEventCandidateHandler(
      callableRequest("admin-1", approvalPayload({
        decision: "hold",
        checklist: incompleteChecklist(),
        note: "Need source time verification.",
      }), {support: true}),
      h.deps
    );

    assert.equal(result.decisionStatus, "held");
    assert.equal(result.importState, "not_importable");
  });

test("adminDecideOrganizerEventCandidateHandler blocks viewer-only admins",
  async () => {
    const h = harness();

    await assert.rejects(
      () => adminDecideOrganizerEventCandidateHandler(
        callableRequest("admin-1", approvalPayload(), {analyticsViewer: true}),
        h.deps
      ),
      (error) => assertHttpsCode(error, "permission-denied")
    );
  });

test("adminDecideOrganizerEventCandidateHandler rate limits explicitly",
  async () => {
    const h = harness();
    const rateLimitCalls: string[] = [];

    await adminDecideOrganizerEventCandidateHandler(
      callableRequest("admin-1", approvalPayload(), {support: true}),
      {
        ...h.deps,
        checkRateLimit: async (_db, uid, action) => {
          rateLimitCalls.push(`${uid}:${action}`);
        },
      }
    );

    assert.deepEqual(rateLimitCalls, [
      "admin-1:adminDecideOrganizerEventCandidate",
    ]);
  });

test("decisionIdForCandidate bounds long external candidate ids", () => {
  const decisionId = decisionIdForCandidate(`batch:${"x".repeat(300)}`);

  assert.equal(decisionId.startsWith("event-batch-x"), true);
  assert.equal(decisionId.length <= 150, true);
});
