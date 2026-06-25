import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest} from "firebase-functions/v2/https";
import {
  adminGetClubDetailsHandler,
  adminListClubDetailsHandler,
  adminUpdateClubDetailsHandler,
} from "./clubDetails";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  readonly id: string;

  constructor(readonly firestore: FakeFirestore, readonly path: string) {
    this.id = path.split("/").at(-1) ?? "";
  }

  async get(): Promise<FakeSnapshot> {
    return new FakeSnapshot(this.firestore.get(this.path));
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

class FakeQueryDocumentSnapshot extends FakeSnapshot {
  readonly id: string;

  constructor(readonly path: string, value: FakeData) {
    super(value);
    this.id = path.split("/").at(-1) ?? "";
  }
}

class FakeQuerySnapshot {
  constructor(readonly docs: FakeQueryDocumentSnapshot[]) {}
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

  where(
    fieldPath: string,
    op: "==" | "in" | "array-contains-any",
    value: unknown
  ) {
    return new FakeQuery(this.firestore, this.path)
      .where(fieldPath, op, value);
  }

  limit(count: number) {
    return new FakeQuery(this.firestore, this.path).limit(count);
  }
}

class FakeQuery {
  private readonly filters: Array<{
    fieldPath: string;
    op: "==" | "in" | "array-contains-any";
    value: unknown;
  }> = [];
  private limitCount = 1000;

  constructor(
    private readonly firestore: FakeFirestore,
    private readonly path: string
  ) {}

  where(
    fieldPath: string,
    op: "==" | "in" | "array-contains-any",
    value: unknown
  ) {
    const next = new FakeQuery(this.firestore, this.path);
    next.filters.push(...this.filters, {fieldPath, op, value});
    next.limitCount = this.limitCount;
    return next;
  }

  limit(count: number) {
    const next = new FakeQuery(this.firestore, this.path);
    next.filters.push(...this.filters);
    next.limitCount = count;
    return next;
  }

  async get(): Promise<FakeQuerySnapshot> {
    return this.execute();
  }

  execute(): FakeQuerySnapshot {
    const prefix = `${this.path}/`;
    const docs = this.firestore.entries()
      .filter(([path, value]) =>
        path.startsWith(prefix) &&
        path.slice(prefix.length).split("/").length === 1 &&
        value !== undefined
      )
      .filter(([, value]) => this.matches(value as FakeData))
      .slice(0, this.limitCount)
      .map(([path, value]) =>
        new FakeQueryDocumentSnapshot(path, value as FakeData));
    return new FakeQuerySnapshot(docs);
  }

  private matches(value: FakeData): boolean {
    return this.filters.every((filter) => {
      const fieldValue = getPath(value, filter.fieldPath.split("."));
      if (filter.op === "array-contains-any") {
        assert.ok(Array.isArray(filter.value));
        if (!Array.isArray(fieldValue)) return false;
        return filter.value.some((item) => fieldValue.includes(item));
      }
      if (filter.op === "in") {
        assert.ok(Array.isArray(filter.value));
        return filter.value.includes(fieldValue);
      }
      return fieldValue === filter.value;
    });
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

  entries(): Array<[string, FakeData | undefined]> {
    return Object.entries(this.docs).map(([path, value]) => [
      path,
      value === undefined ? undefined : structuredClone(value),
    ]);
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

  async get(
    ref: FakeDocRef | FakeQuery
  ): Promise<FakeSnapshot | FakeQuerySnapshot> {
    if (ref instanceof FakeQuery) return ref.execute();
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

function getPath(target: FakeData, path: string[]): unknown {
  let cursor: unknown = target;
  for (const segment of path) {
    if (!cursor || typeof cursor !== "object") return undefined;
    cursor = (cursor as FakeData)[segment];
  }
  return cursor;
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
      now: () => new Date("2026-06-25T08:30:00.000Z"),
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
    description: "Movement and music community in Indore.",
    location: "indore",
    area: "Indore",
    tags: ["run club"],
    instagramHandle: "afterfly.in",
    phoneNumber: null,
    email: null,
    imageUrl: null,
    profileImageUrl: null,
    entityKind: "creatorCommunity",
    entitySubtypes: ["social run club"],
    displayCategory: "Run club",
    cityName: "Indore",
    regionName: "Madhya Pradesh",
    countryCode: "IN",
    countryName: "India",
    appVisibility: "hidden",
    ownership: {state: "programmatic"},
    claim: {state: "unclaimed"},
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
    provenance: {
      origin: "scraper",
      sourceConfidence: "high",
      verificationStatus: "sourceBacked",
      lastVerifiedAt: null,
    },
    publicProfile: {
      headline: "AFTER FLY in Indore",
      summary: "A public event source connects AFTER FLY to Indore.",
      sourceSummary: "Luma event page confirmed.",
      formats: ["Run and rave"],
      fitNotes: ["Social event format"],
      missingEvidence: ["Owner contact"],
      facts: [],
      eventEvidence: [],
    },
    adminSearch: {
      tokens: [
        "afterfly",
        "after",
        "run",
        "club",
        "indore",
        "afterfly-run-club",
      ],
      sortKey: "afterfly",
      updatedAt: "SERVER_TIMESTAMP",
      updatedBySource: "adminUpdateClubDetails",
    },
    ...overrides,
  };
}

function assertHttpsCode(error: unknown, code: string): boolean {
  assert.equal((error as {code?: string}).code, code);
  return true;
}

test("adminGetClubDetailsHandler returns a review-safe club snapshot",
  async () => {
    const h = harness({
      "clubs/afterfly-run-club-indore": clubDoc(),
    });

    const result = await adminGetClubDetailsHandler(
      callableRequest("admin-1", {
        clubId: " afterfly-run-club-indore ",
      }, {support: true}),
      h.deps
    );

    assert.equal(result.club.clubId, "afterfly-run-club-indore");
    assert.equal(result.club.name, "AFTER FLY");
    assert.equal(result.club.publicPage.indexStatus, "noindex");
    assert.equal(result.club.provenance.sourceConfidence, "high");
    assert.deepEqual(result.club.publicProfile.missingEvidence, [
      "Owner contact",
    ]);
  }
);

test("adminListClubDetailsHandler returns canonical organizer rows",
  async () => {
    const h = harness({
      "clubs/afterfly-run-club-indore": clubDoc(),
      "clubs/bandra-social-run": clubDoc({
        name: "Bandra Social Run",
        location: "mumbai",
        cityName: "Mumbai",
        publicPage: {
          slug: "bandra-social-run",
          citySlug: "mumbai",
          canonicalPath: "/organizers/mumbai/bandra-social-run/",
          publishStatus: "published",
          indexStatus: "indexReady",
          robots: "index, follow",
          seoTitle: "Bandra Social Run",
          seoDescription: "Mumbai organizer profile.",
          lastRenderedAt: null,
        },
        adminSearch: {
          tokens: ["bandra", "social", "run", "mumbai"],
          sortKey: "bandra",
          updatedAt: "SERVER_TIMESTAMP",
          updatedBySource: "adminUpdateClubDetails",
        },
      }),
      "publicRouteReservations/organizers__mumbai__bandra-social-run": {
        status: "active",
        targetPath: "clubs/bandra-social-run",
        routePath: "/organizers/mumbai/bandra-social-run/",
      },
    });

    const result = await adminListClubDetailsHandler(
      callableRequest("admin-1", {
        citySlug: "mumbai",
        query: "bandra",
        limit: 10,
      }, {support: true}),
      h.deps
    );

    assert.equal(result.rows.length, 1);
    assert.equal(result.rows[0].clubId, "bandra-social-run");
    assert.equal(result.rows[0].routeStatus, "valid");
    assert.equal(result.rows[0].routeReservationStatus, "reserved");
    assert.equal(result.rows[0].searchIndexStatus, "indexed");
    assert.equal(result.rows[0].publishStatus, "published");
    assert.equal(result.generatedAt, "2026-06-25T08:30:00.000Z");
  }
);

test(
  "adminListClubDetailsHandler supports bounded launch-city filters",
  async () => {
    const h = harness({
      "clubs/afterfly-run-club-indore": clubDoc(),
      "clubs/bandra-social-run": clubDoc({
        name: "Bandra Social Run",
        location: "mumbai",
        cityName: "Mumbai",
        publicPage: {
          slug: "bandra-social-run",
          citySlug: "mumbai",
          canonicalPath: "/organizers/mumbai/bandra-social-run/",
          publishStatus: "published",
          indexStatus: "indexReady",
          robots: "index, follow",
          seoTitle: "Bandra Social Run",
          seoDescription: "Mumbai organizer profile.",
          lastRenderedAt: null,
        },
      }),
      "clubs/delhi-run-club": clubDoc({
        name: "Delhi Run Club",
        location: "delhi",
        cityName: "Delhi",
        publicPage: {
          slug: "delhi-run-club",
          citySlug: "delhi",
          canonicalPath: "/organizers/delhi/delhi-run-club/",
          publishStatus: "qa",
          indexStatus: "noindex",
          robots: "noindex, follow",
          seoTitle: "Delhi Run Club",
          seoDescription: "Delhi organizer profile.",
          lastRenderedAt: null,
        },
      }),
    });

    const result = await adminListClubDetailsHandler(
      callableRequest("admin-1", {
        citySlugs: [" indore ", "mumbai", "indore"],
        limit: 10,
      }, {support: true}),
      h.deps
    );

    assert.deepEqual(
      result.rows.map((row) => row.clubId).sort(),
      ["afterfly-run-club-indore", "bandra-social-run"]
    );
  }
);

test("adminUpdateClubDetailsHandler saves allowed cleanup fields", async () => {
  const h = harness({
    "clubs/afterfly-run-club-indore": clubDoc(),
  });

  const result = await adminUpdateClubDetailsHandler(
    callableRequest("admin-1", {
      clubId: "afterfly-run-club-indore",
      fields: {
        name: " Afterfly Run Club ",
        tags: [" social run ", "social run", ""],
        email: "hello@afterfly.in ",
        publicPage: {
          seoTitle: "Afterfly Run Club | Indore organizer profile",
        },
        provenance: {
          sourceConfidence: "high",
          verificationStatus: "sourceBacked",
        },
        publicProfile: {
          headline: "Afterfly Run Club in Indore",
          missingEvidence: ["Owner contact", "Media permission"],
        },
      },
      reviewNote: "Cleaned up naming and owner contact.",
    }, {admin: true}),
    h.deps
  );

  assert.equal(result.clubId, "afterfly-run-club-indore");
  assert.equal(result.updatedFieldCount, 9);
  const club = h.firestore.get("clubs/afterfly-run-club-indore");
  assert.equal(club?.name, "Afterfly Run Club");
  assert.deepEqual(club?.tags, ["social run"]);
  assert.equal(club?.email, "hello@afterfly.in");
  assert.equal(
    (club?.publicPage as FakeData).seoTitle,
    "Afterfly Run Club | Indore organizer profile"
  );
  assert.equal(
    (club?.provenance as FakeData).lastVerifiedAt,
    "SERVER_TIMESTAMP"
  );
  assert.deepEqual(
    (club?.publicProfile as FakeData).missingEvidence,
    ["Owner contact", "Media permission"]
  );
  assert.equal((club?.adminSearch as FakeData).updatedBySource,
    "adminUpdateClubDetails");
  assert.ok(((club?.adminSearch as FakeData).tokens as string[])
    .includes("afterfly"));
  assert.equal(h.firestore.auditLogs().length, 1);
});

test("adminUpdateClubDetailsHandler reserves changed canonical routes",
  async () => {
    const h = harness({
      "clubs/afterfly-run-club-indore": clubDoc(),
      "publicRouteReservations/organizers__indore__afterfly-run-club": {
        status: "active",
        targetPath: "clubs/afterfly-run-club-indore",
        routePath: "/organizers/indore/afterfly-run-club/",
      },
    });

    const result = await adminUpdateClubDetailsHandler(
      callableRequest("admin-1", {
        clubId: "afterfly-run-club-indore",
        fields: {
          publicPage: {
            slug: "afterfly",
            citySlug: "indore",
            canonicalPath: "/organizers/indore/afterfly/",
          },
        },
        reviewNote: "Updated route to the simpler public slug.",
      }, {admin: true}),
      h.deps
    );

    assert.equal(result.updatedFieldCount, 3);
    const newReservation = h.firestore.get(
      "publicRouteReservations/organizers__indore__afterfly"
    );
    assert.equal(newReservation?.status, "active");
    assert.equal(newReservation?.targetPath, "clubs/afterfly-run-club-indore");
    assert.equal(newReservation?.routePath, "/organizers/indore/afterfly/");
    assert.deepEqual(newReservation?.routeSegments, [
      "organizers",
      "indore",
      "afterfly",
    ]);
    assert.equal(newReservation?.lastVerifiedByUid, "admin-1");
    assert.equal(newReservation?.lastVerifiedSource, "adminUpdateClubDetails");
    const previousReservation = h.firestore.get(
      "publicRouteReservations/organizers__indore__afterfly-run-club"
    );
    assert.equal(previousReservation?.status, "released");
    assert.equal(
      previousReservation?.replacementRoutePath,
      "/organizers/indore/afterfly/"
    );
  }
);

test("adminUpdateClubDetailsHandler rejects reserved route conflicts",
  async () => {
    const h = harness({
      "clubs/duplicate-afterfly": clubDoc({
        name: "Duplicate Afterfly",
        publicPage: {
          slug: "duplicate-afterfly",
          citySlug: "indore",
          canonicalPath: "/organizers/indore/duplicate-afterfly/",
          publishStatus: "qa",
          indexStatus: "noindex",
          robots: "noindex, follow",
          seoTitle: "Duplicate",
          seoDescription: "Duplicate profile.",
          lastRenderedAt: null,
        },
      }),
      "publicRouteReservations/organizers__indore__claimed-route": {
        status: "active",
        targetPath: "clubs/other-organizer",
        routePath: "/organizers/indore/claimed-route/",
      },
    });

    await assert.rejects(
      () => adminUpdateClubDetailsHandler(
        callableRequest("admin-1", {
          clubId: "duplicate-afterfly",
          fields: {
            publicPage: {
              slug: "claimed-route",
              citySlug: "indore",
              canonicalPath: "/organizers/indore/claimed-route/",
            },
          },
          reviewNote: "Checked route before publish.",
        }, {admin: true}),
        h.deps
      ),
      (error) => assertHttpsCode(error, "already-exists")
    );
  }
);

test("adminUpdateClubDetailsHandler rejects duplicate canonical paths",
  async () => {
    const h = harness({
      "clubs/afterfly-run-club-indore": clubDoc(),
      "clubs/duplicate-afterfly": clubDoc({
        name: "Duplicate Afterfly",
        publicPage: {
          slug: "duplicate-afterfly",
          citySlug: "indore",
          canonicalPath: "/organizers/indore/duplicate-afterfly/",
          publishStatus: "qa",
          indexStatus: "noindex",
          robots: "noindex, follow",
          seoTitle: "Duplicate",
          seoDescription: "Duplicate profile.",
          lastRenderedAt: null,
        },
      }),
    });

    await assert.rejects(
      () => adminUpdateClubDetailsHandler(
        callableRequest("admin-1", {
          clubId: "duplicate-afterfly",
          fields: {
            publicPage: {
              slug: "afterfly-run-club",
              citySlug: "indore",
              canonicalPath: "/organizers/indore/afterfly-run-club/",
            },
          },
          reviewNote: "Checked duplicate route before publish.",
        }, {admin: true}),
        h.deps
      ),
      (error) => assertHttpsCode(error, "already-exists")
    );
  }
);

test("adminUpdateClubDetailsHandler rejects path and slug mismatch",
  async () => {
    const h = harness({
      "clubs/afterfly-run-club-indore": clubDoc(),
    });

    await assert.rejects(
      () => adminUpdateClubDetailsHandler(
        callableRequest("admin-1", {
          clubId: "afterfly-run-club-indore",
          fields: {
            publicPage: {
              slug: "afterfly-run-club",
              canonicalPath: "/organizers/indore/wrong-slug/",
            },
          },
          reviewNote: "Checked route shape before publish.",
        }, {admin: true}),
        h.deps
      ),
      (error) => assertHttpsCode(error, "invalid-argument")
    );
  }
);

test("adminUpdateClubDetailsHandler rejects protected index fields",
  async () => {
    const h = harness({
      "clubs/afterfly-run-club-indore": clubDoc(),
    });

    await assert.rejects(
      () => adminUpdateClubDetailsHandler(
        callableRequest("admin-1", {
          clubId: "afterfly-run-club-indore",
          fields: {
            publicPage: {
              indexStatus: "indexReady",
            },
          },
        }, {admin: true}),
        h.deps
      ),
      (error) => assertHttpsCode(error, "invalid-argument")
    );
  }
);

test("adminUpdateClubDetailsHandler requires review notes", async () => {
  const h = harness({
    "clubs/afterfly-run-club-indore": clubDoc(),
  });

  await assert.rejects(
    () => adminUpdateClubDetailsHandler(
      callableRequest("admin-1", {
        clubId: "afterfly-run-club-indore",
        fields: {name: "Afterfly"},
      }, {admin: true}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "invalid-argument")
  );
});

test("adminUpdateClubDetailsHandler blocks viewer-only admins", async () => {
  const h = harness({
    "clubs/afterfly-run-club-indore": clubDoc(),
  });

  await assert.rejects(
    () => adminUpdateClubDetailsHandler(
      callableRequest("admin-1", {
        clubId: "afterfly-run-club-indore",
        fields: {name: "Afterfly"},
      }, {analyticsViewer: true}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "permission-denied")
  );
});
