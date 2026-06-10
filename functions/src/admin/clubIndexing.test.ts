/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest} from "firebase-functions/v2/https";
import {adminSetClubIndexStatusHandler} from "./clubIndexing";

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
    return this.value === undefined ? undefined : {...this.value};
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
    this.docs[path] = data;
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

  update(ref: FakeDocRef, patch: FakeData) {
    this.writes.push(() => {
      const current = this.firestore.get(ref.path);
      if (current === undefined) {
        throw new Error(`Missing doc for update: ${ref.path}`);
      }
      this.firestore.set(ref.path, applyPatch(current, patch));
    });
  }

  set(ref: FakeDocRef, patch: FakeData, options?: {merge?: boolean}) {
    this.writes.push(() => {
      const current = options?.merge ?
        this.firestore.get(ref.path) ?? {} :
        {};
      this.firestore.set(ref.path, applyPatch(current, patch));
    });
  }

  commit() {
    for (const write of this.writes) write();
  }
}

function applyPatch(current: FakeData, patch: FakeData): FakeData {
  const next = structuredClone(current);
  for (const [key, value] of Object.entries(patch)) {
    if (key.includes(".")) {
      setPath(next, key.split("."), value);
    } else {
      next[key] = value;
    }
  }
  return next;
}

function setPath(target: FakeData, path: string[], value: unknown) {
  let cursor: FakeData = target;
  for (let i = 0; i < path.length - 1; i += 1) {
    const segment = path[i];
    const child = cursor[segment];
    if (!child || typeof child !== "object") {
      cursor[segment] = {};
    }
    cursor = cursor[segment] as FakeData;
  }
  const finalSegment = path[path.length - 1];
  if (finalSegment) cursor[finalSegment] = value;
}

function harness(initialDocs: Record<string, FakeData | undefined>) {
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

function clubDoc(overrides: FakeData = {}): FakeData {
  return {
    name: "AFTER FLY",
    publicPage: {
      slug: "afterfly-run-club",
      citySlug: "indore",
      canonicalPath: "/organizers/indore/afterfly-run-club/",
      publishStatus: "qa",
      indexStatus: "noindex",
      robots: "noindex, follow",
      seoTitle: "AFTER FLY",
      seoDescription: "Indore organizer profile.",
      lastRenderedAt: null,
    },
    ...overrides,
  };
}

function completeChecklist() {
  return {
    sourceEvidenceVerified: true,
    mediaRightsVerified: true,
    cadenceVerified: true,
    ownerContactVerified: true,
  };
}

function assertHttpsCode(error: unknown, code: string): boolean {
  assert.equal((error as {code?: string}).code, code);
  return true;
}

test("adminSetClubIndexStatusHandler marks a page index-ready", async () => {
  const h = harness({
    "clubs/afterfly-run-club-indore": clubDoc(),
  });

  const result = await adminSetClubIndexStatusHandler(
    callableRequest("admin-1", {
      clubId: "afterfly-run-club-indore",
      indexStatus: "indexReady",
      checklist: completeChecklist(),
      reviewNote: "Sources, cadence, media rights, and owner contact checked.",
    }, {support: true}),
    h.deps
  );

  assert.deepEqual(result, {
    clubId: "afterfly-run-club-indore",
    indexStatus: "indexReady",
    publishStatus: "published",
    robots: "index, follow",
  });
  assert.deepEqual(
    h.firestore.get("clubs/afterfly-run-club-indore")?.publicPage,
    {
      slug: "afterfly-run-club",
      citySlug: "indore",
      canonicalPath: "/organizers/indore/afterfly-run-club/",
      publishStatus: "published",
      indexStatus: "indexReady",
      robots: "index, follow",
      seoTitle: "AFTER FLY",
      seoDescription: "Indore organizer profile.",
      lastRenderedAt: null,
      indexReview: {
        reviewedAt: "SERVER_TIMESTAMP",
        reviewedByUid: "admin-1",
        indexStatus: "indexReady",
        checklist: completeChecklist(),
        reviewNote:
          "Sources, cadence, media rights, and owner contact checked.",
      },
    }
  );
  assert.equal(h.firestore.auditLogs().length, 1);
});

test("adminSetClubIndexStatusHandler rejects incomplete index checklist",
  async () => {
    const h = harness({
      "clubs/afterfly-run-club-indore": clubDoc(),
    });

    await assert.rejects(
      () => adminSetClubIndexStatusHandler(
        callableRequest("admin-1", {
          clubId: "afterfly-run-club-indore",
          indexStatus: "indexReady",
          checklist: {
            ...completeChecklist(),
            mediaRightsVerified: false,
          },
        }, {support: true}),
        h.deps
      ),
      (error) => assertHttpsCode(error, "failed-precondition")
    );
  }
);

test("adminSetClubIndexStatusHandler blocks viewer-only admins", async () => {
  const h = harness({
    "clubs/afterfly-run-club-indore": clubDoc(),
  });

  await assert.rejects(
    () => adminSetClubIndexStatusHandler(
      callableRequest("admin-1", {
        clubId: "afterfly-run-club-indore",
        indexStatus: "noindex",
        checklist: completeChecklist(),
      }, {analyticsViewer: true}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "permission-denied")
  );
});
