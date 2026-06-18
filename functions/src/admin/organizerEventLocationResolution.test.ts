import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest} from "firebase-functions/v2/https";
import {
  adminResolveOrganizerEventLocationHandler,
  resolutionIdForCandidate,
} from "./organizerEventLocationResolution";

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
    sourceLocationReviewed: true,
    coordinatesReviewed: true,
    placeIdentityReviewed: true,
    importSafetyReviewed: true,
  };
}

function resolutionPayload(overrides: FakeData = {}) {
  return {
    candidateId: "2026-06-17-afterfly-luma-events:pxgmph3b",
    location: {
      name: "Nehru Stadium",
      address: "Nehru Stadium, Indore, Madhya Pradesh",
      placeId: "ChIJ-afterfly-indore",
      latitude: 22.7196,
      longitude: 75.8577,
      notes: "Matched to source listing and map result.",
    },
    checklist: completeChecklist(),
    note: "Manual location QA complete.",
    ...overrides,
  };
}

function assertHttpsCode(error: unknown, code: string): boolean {
  assert.equal((error as {code?: string}).code, code);
  return true;
}

test("adminResolveOrganizerEventLocationHandler records a resolution",
  async () => {
    const h = harness();

    const result = await adminResolveOrganizerEventLocationHandler(
      callableRequest("admin-1", resolutionPayload(), {support: true}),
      h.deps
    );

    assert.deepEqual(result, {
      candidateId: "2026-06-17-afterfly-luma-events:pxgmph3b",
      resolutionId: "loc-2026-06-17-afterfly-luma-events-pxgmph3b",
      resolutionStatus: "resolved",
      decisionPath:
        "organizerEventLocationResolutionDecisions/" +
        "loc-2026-06-17-afterfly-luma-events-pxgmph3b",
      location: {
        name: "Nehru Stadium",
        address: "Nehru Stadium, Indore, Madhya Pradesh",
        placeId: "ChIJ-afterfly-indore",
        latitude: 22.7196,
        longitude: 75.8577,
        notes: "Matched to source listing and map result.",
      },
    });
    assert.deepEqual(
      h.firestore.get(
        "organizerEventLocationResolutionDecisions/" +
          "loc-2026-06-17-afterfly-luma-events-pxgmph3b"
      ),
      {
        schemaVersion: 1,
        resolutionId: "loc-2026-06-17-afterfly-luma-events-pxgmph3b",
        candidateId: "2026-06-17-afterfly-luma-events:pxgmph3b",
        location: {
          name: "Nehru Stadium",
          address: "Nehru Stadium, Indore, Madhya Pradesh",
          placeId: "ChIJ-afterfly-indore",
          latitude: 22.7196,
          longitude: 75.8577,
          notes: "Matched to source listing and map result.",
        },
        checklist: completeChecklist(),
        note: "Manual location QA complete.",
        reviewedByUid: "admin-1",
        reviewedAt: "SERVER_TIMESTAMP",
        updatedAt: "SERVER_TIMESTAMP",
        resolutionStatus: "resolved",
      }
    );
    assert.equal(h.firestore.auditLogs().length, 1);
  });

test("adminResolveOrganizerEventLocationHandler rejects incomplete checks",
  async () => {
    const h = harness();

    await assert.rejects(
      () => adminResolveOrganizerEventLocationHandler(
        callableRequest("admin-1", resolutionPayload({
          checklist: {
            ...completeChecklist(),
            coordinatesReviewed: false,
          },
        }), {support: true}),
        h.deps
      ),
      (error) => assertHttpsCode(error, "failed-precondition")
    );
  });

test("adminResolveOrganizerEventLocationHandler requires exact coordinates",
  async () => {
    const h = harness();

    await assert.rejects(
      () => adminResolveOrganizerEventLocationHandler(
        callableRequest("admin-1", resolutionPayload({
          location: {
            name: "Nehru Stadium",
            latitude: null,
            longitude: 75.8577,
          },
        }), {support: true}),
        h.deps
      ),
      (error) => assertHttpsCode(error, "failed-precondition")
    );
  });

test("adminResolveOrganizerEventLocationHandler blocks viewer-only admins",
  async () => {
    const h = harness();

    await assert.rejects(
      () => adminResolveOrganizerEventLocationHandler(
        callableRequest(
          "admin-1",
          resolutionPayload(),
          {analyticsViewer: true}
        ),
        h.deps
      ),
      (error) => assertHttpsCode(error, "permission-denied")
    );
  });

test("adminResolveOrganizerEventLocationHandler rate limits explicitly",
  async () => {
    const h = harness();
    const rateLimitCalls: string[] = [];

    await adminResolveOrganizerEventLocationHandler(
      callableRequest("admin-1", resolutionPayload(), {support: true}),
      {
        ...h.deps,
        checkRateLimit: async (_db, uid, action) => {
          rateLimitCalls.push(`${uid}:${action}`);
        },
      }
    );

    assert.deepEqual(rateLimitCalls, [
      "admin-1:adminResolveOrganizerEventLocation",
    ]);
  });

test("resolutionIdForCandidate bounds long external candidate ids", () => {
  const resolutionId = resolutionIdForCandidate(`batch:${"x".repeat(300)}`);

  assert.equal(resolutionId.startsWith("loc-batch-x"), true);
  assert.equal(resolutionId.length <= 150, true);
});
