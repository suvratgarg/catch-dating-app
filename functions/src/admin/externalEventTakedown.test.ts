import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest} from "firebase-functions/v2/https";
import {
  adminTakedownExternalEventHandler,
} from "./externalEventTakedown";

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

class FakeTransaction {
  constructor(private readonly firestore: FakeFirestore) {}

  async get(ref: FakeDocRef) {
    return new FakeSnapshot(this.firestore.get(ref.path));
  }

  create(ref: FakeDocRef, value: FakeData) {
    if (this.firestore.get(ref.path) !== undefined) {
      throw new Error("already exists");
    }
    this.firestore.set(ref.path, value);
  }

  set(ref: FakeDocRef, value: FakeData) {
    this.firestore.set(ref.path, value);
  }

  update(ref: FakeDocRef, value: FakeData) {
    const before = this.firestore.get(ref.path);
    if (!before) throw new Error("not found");
    this.firestore.set(ref.path, {...before, ...value});
  }
}

class FakeFirestore {
  private nextId = 0;

  constructor(private readonly docs: Record<string, FakeData | undefined>) {}

  collection(path: string) {
    return new FakeCollectionRef(this, path);
  }

  async runTransaction<T>(callback: (tx: FakeTransaction) => Promise<T>) {
    return callback(new FakeTransaction(this));
  }

  get(path: string): FakeData | undefined {
    const value = this.docs[path];
    return value === undefined ? undefined : structuredClone(value);
  }

  set(path: string, value: FakeData) {
    this.docs[path] = structuredClone(value);
  }

  autoId(): string {
    this.nextId += 1;
    return `audit-${this.nextId}`;
  }
}

function harness() {
  const firestore = new FakeFirestore({
    "externalEvents/external-1": {
      eventId: "external-1",
      publicationStatus: "public",
      status: "active",
      booking: {externalLinks: [{url: "https://example.com/event"}]},
    },
  });
  return {
    firestore,
    deps: {
      firestore: () =>
        firestore as unknown as FirebaseFirestore.Firestore,
      serverTimestamp: () => ({serverTimestamp: true}) as unknown as
        FirebaseFirestore.FieldValue,
      now: () => new Date("2026-06-25T08:30:00.000Z"),
      checkRateLimit: async () => undefined,
    },
  };
}

function request(executionMode: "dry_run" | "apply") {
  return {
    auth: {uid: "admin-1", token: {support: true}},
    data: {
      eventId: "external-1",
      executionMode,
      idempotencyKey: `external-1:takedown:${executionMode}`,
      reviewNote: "Official source no longer lists this event.",
      checklist: {
        sourceStatusReviewed: true,
        takedownAuthorityReviewed: true,
        downstreamVisibilityReviewed: true,
      },
    },
    rawRequest: {headers: {}},
  } as unknown as CallableRequest<unknown>;
}

test("adminTakedownExternalEventHandler dry-runs without changing visibility",
  async () => {
    const h = harness();

    const result = await adminTakedownExternalEventHandler(
      request("dry_run"),
      h.deps
    );

    assert.equal(result.outcome, "would_remove");
    assert.equal(result.writeApplied, false);
    assert.equal(
      h.firestore.get("externalEvents/external-1")?.publicationStatus,
      "public"
    );
    assert.ok(h.firestore.get(result.receiptPath));
  });

test("adminTakedownExternalEventHandler removes without deleting history",
  async () => {
    const h = harness();

    const first = await adminTakedownExternalEventHandler(
      request("apply"),
      h.deps
    );
    const second = await adminTakedownExternalEventHandler(
      request("apply"),
      h.deps
    );

    const event = h.firestore.get("externalEvents/external-1");
    assert.equal(event?.publicationStatus, "removed");
    assert.equal(event?.status, "cancelled");
    assert.equal(first.outcome, "removed");
    assert.equal(first.writeApplied, true);
    assert.equal(second.idempotent, true);
    assert.equal(first.receiptPath, second.receiptPath);
  });

