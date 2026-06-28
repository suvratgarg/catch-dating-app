import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {createClubHandler} from "./createClub";

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

class FakeFirestore {
  constructor(private readonly docs: Record<string, FakeData | undefined>) {}

  collection(collectionPath: string) {
    return {
      doc: (docId = "generated-club-id") => new FakeDocRef(
        this,
        `${collectionPath}/${docId}`
      ),
      where: (field: string, op: string, value: unknown) =>
        new FakeQuery(this, collectionPath, field, op, value),
    };
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

  set(path: string, data: FakeData) {
    this.docs[path] = data;
  }

  query(
    collectionPath: string,
    field: string,
    op: string,
    value: unknown,
    limitCount: number
  ): FakeData[] {
    if (op !== "==") {
      throw new Error(`Unsupported fake query op: ${op}`);
    }
    return Object.entries(this.docs)
      .filter(([path]) => path.startsWith(`${collectionPath}/`))
      .map(([, data]) => data)
      .filter((data): data is FakeData => data !== undefined)
      .filter((data) => data[field] === value)
      .slice(0, limitCount)
      .map((data) => ({...data}));
  }
}

class FakeQuery {
  private limitCount = Number.MAX_SAFE_INTEGER;

  constructor(
    private readonly firestore: FakeFirestore,
    private readonly collectionPath: string,
    private readonly field: string,
    private readonly op: string,
    private readonly value: unknown
  ) {}

  limit(count: number) {
    this.limitCount = count;
    return this;
  }

  async get(): Promise<{empty: boolean}> {
    const docs = this.firestore.query(
      this.collectionPath,
      this.field,
      this.op,
      this.value,
      this.limitCount
    );
    return {empty: docs.length === 0};
  }
}

class FakeTransaction {
  private readonly writes: Array<() => void> = [];

  constructor(private readonly firestore: FakeFirestore) {}

  async get(ref: FakeDocRef): Promise<FakeSnapshot> {
    return new FakeSnapshot(this.firestore.get(ref.path));
  }

  create(ref: FakeDocRef, data: FakeData) {
    this.writes.push(() => {
      if (this.firestore.get(ref.path) !== undefined) {
        throw new Error(`Doc already exists: ${ref.path}`);
      }
      this.firestore.set(ref.path, applyPatch({}, data));
    });
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
  const next = {...current};
  for (const [field, value] of Object.entries(patch)) {
    if (isArrayUnion(value)) {
      const values = Array.isArray(next[field]) ?
        [...(next[field] as string[])] :
        [];
      next[field] = values.includes(value.value) ?
        values :
        [...values, value.value];
    } else {
      next[field] = value;
    }
  }
  return next;
}

function isArrayUnion(value: unknown): value is {kind: string; value: string} {
  return typeof value === "object" &&
    value !== null &&
    "kind" in value &&
    (value as {kind: string}).kind === "arrayUnion";
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
      serverTimestamp: () =>
        ({kind: "serverTimestamp"}) as unknown as FirebaseFirestore.FieldValue,
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

function profile(overrides: FakeData = {}): FakeData {
  return {
    profileComplete: true,
    name: "Asha Runner",
    displayName: "Asha Host",
    profilePhotos: [{
      id: "photo-1",
      url: "https://example.com/avatar.jpg",
      thumbnailUrl: "https://example.com/avatar-thumb.jpg",
      storagePath: "users/host-1/photos/photo-1.jpg",
      thumbnailStoragePath: "users/host-1/photoThumbnails/photo-1.jpg",
      position: 0,
      createdAt: {toDate: () => new Date("2026-01-01T00:00:00.000Z")},
      updatedAt: {toDate: () => new Date("2026-01-01T00:00:00.000Z")},
    }],
    ...overrides,
  };
}

function payload(overrides: FakeData = {}): FakeData {
  return {
    clubId: "club-1",
    name: "Morning Miles",
    description: "Easy weekday events.",
    location: "in-mh-mumbai",
    area: "Bandra",
    imageUrl: "https://example.com/cover.jpg",
    profileImageUrl: "https://example.com/profile.jpg",
    instagramHandle: "@morningmiles",
    phoneNumber: "+91 99999 99999",
    email: "hello@example.com",
    ...overrides,
  };
}

function assertHttpsCode(error: unknown, code: string): boolean {
  return error instanceof HttpsError && error.code === code;
}

test("createClubHandler creates a club and host membership edge",
  async () => {
    const h = harness({"users/host-1": profile()});

    const result = await createClubHandler(
      request("host-1", payload()),
      h.deps
    );

    assert.deepEqual(result, {clubId: "club-1"});
    assert.deepEqual(h.rateLimitCalls, ["host-1:createClub"]);
    assert.deepEqual(h.firestore.get("clubs/club-1"), {
      name: "Morning Miles",
      description: "Easy weekday events.",
      location: "in-mh-mumbai",
      locationCityId: "in-mh-mumbai",
      locationMarketId: "in-mh-mumbai",
      area: "Bandra",
      hostUserId: "host-1",
      hostName: "Asha Host",
      hostAvatarUrl: "https://example.com/avatar-thumb.jpg",
      ownerUserId: "host-1",
      hostUserIds: ["host-1"],
      hostProfiles: [{
        uid: "host-1",
        displayName: "Asha Host",
        avatarUrl: "https://example.com/avatar-thumb.jpg",
        role: "owner",
      }],
      createdAt: {kind: "serverTimestamp"},
      imageUrl: "https://example.com/cover.jpg",
      profileImageUrl: "https://example.com/profile.jpg",
      clubPhotos: [],
      logoPhoto: null,
      tags: [],
      memberCount: 1,
      rating: 0,
      reviewCount: 0,
      nextEventAt: null,
      nextEventLabel: null,
      status: "active",
      archived: false,
      archivedAt: null,
      archiveReason: null,
      instagramHandle: "@morningmiles",
      phoneNumber: "+91 99999 99999",
      email: "hello@example.com",
      hostDefaults: {
        primaryActivityKind: "socialRun",
        supportedActivityKinds: ["socialRun"],
        eventPolicy: {
          admissionPreset: "openCapacity",
          minAge: 0,
          maxAge: 99,
          maxMen: null,
          maxWomen: null,
          dynamicPricingEnabled: false,
          dynamicPricingStepInPaise: null,
          dynamicPricingMaxInPaise: null,
          cancellationPolicyId: "standard",
        },
        eventSuccess: {
          enabled: false,
          playbookId: "social_run_light",
          selectedModuleIds: [],
          structureConfig: {
            unitKind: "pods",
            unitSize: 4,
            unitCount: null,
            rotationIntervalMinutes: null,
            revealCountdownSeconds: 10,
          },
          hostGoal: "Help attendees meet at least two new people.",
          wingmanRequestsEnabled: true,
          contextualOpenersEnabled: true,
          compatibilityAffectsRanking: false,
          attendeePrompt: null,
        },
        eventSuccessByActivityKind: {},
      },
      entityKind: "club",
      entitySubtypes: [],
      displayCategory: "Club",
      cityName: "Mumbai",
      regionName: "Maharashtra",
      countryCode: "IN",
      countryName: "India",
      appVisibility: "discoverable",
      ownership: {
        state: "userCreated",
        ownerUserId: "host-1",
        primaryHostUserId: "host-1",
        hostUserIds: ["host-1"],
        claimedAt: {kind: "serverTimestamp"},
        claimedByUid: "host-1",
      },
      claim: {
        state: "claimed",
        claimHref: null,
        lastClaimRequestId: null,
      },
      publicPage: {
        slug: "club-1",
        citySlug: "mumbai",
        canonicalPath: "/clubs/club-1",
        publishStatus: "draft",
        indexStatus: "noindex",
        robots: "noindex, follow",
        seoTitle: null,
        seoDescription: null,
        lastRenderedAt: null,
      },
      provenance: {
        origin: "userCreated",
        sourceConfidence: "ownerVerified",
        verificationStatus: "ownerVerified",
        lastVerifiedAt: {kind: "serverTimestamp"},
      },
      publicProfile: {
        headline: null,
        summary: null,
        sourceSummary: null,
        formats: [],
        facts: [],
        fitNotes: [],
        missingEvidence: [],
        eventEvidence: [],
      },
      publicSources: [],
    });
    assert.deepEqual(
      {
        clubId: h.firestore.get("clubMemberships/club-1_host-1")?.clubId,
        uid: h.firestore.get("clubMemberships/club-1_host-1")?.uid,
        role: h.firestore.get("clubMemberships/club-1_host-1")?.role,
        status: h.firestore.get("clubMemberships/club-1_host-1")?.status,
      },
      {
        clubId: "club-1",
        uid: "host-1",
        role: "owner",
        status: "active",
      }
    );
    assert.deepEqual(h.firestore.get("clubHostClaims/host-1"), {
      uid: "host-1",
      clubId: "club-1",
      createdAt: {kind: "serverTimestamp"},
    });
    assert.deepEqual(h.firestore.get("hostProfiles/host-1"), {
      displayName: "Asha Host",
      avatarUrl: "https://example.com/avatar-thumb.jpg",
      status: "active",
      createdAt: {kind: "serverTimestamp"},
      updatedAt: {kind: "serverTimestamp"},
    });
  }
);

test("createClubHandler uses host profile without dating profile", async () => {
  const h = harness({
    "hostProfiles/host-1": {
      displayName: "Asha Studio",
      avatarUrl: "https://example.com/host.jpg",
      status: "active",
    },
  });

  await createClubHandler(request("host-1", payload()), h.deps);

  assert.equal(h.firestore.get("clubs/club-1")?.hostName, "Asha Studio");
  assert.equal(
    h.firestore.get("clubs/club-1")?.hostAvatarUrl,
    "https://example.com/host.jpg"
  );
  assert.equal(h.firestore.get("users/host-1"), undefined);
});

test("createClubHandler can generate the club id server-side", async () => {
  const h = harness({
    "users/host-1": profile({profilePhotos: []}),
  });

  const result = await createClubHandler(
    request("host-1", payload({
      clubId: undefined,
      imageUrl: undefined,
      profileImageUrl: undefined,
    })),
    h.deps
  );

  assert.deepEqual(result, {clubId: "generated-club-id"});
  assert.equal(
    h.firestore.get("clubs/generated-club-id")?.hostAvatarUrl,
    null
  );
  assert.equal(h.firestore.get("clubs/generated-club-id")?.imageUrl, null);
  assert.equal(
    h.firestore.get("clubs/generated-club-id")?.profileImageUrl,
    null
  );
  assert.equal(
    h.firestore.get("clubMemberships/generated-club-id_host-1")?.status,
    "active"
  );
});

test("createClubHandler rejects unsafe creation states", async () => {
  const h = harness({
    "clubs/existing": {name: "Existing"},
    "users/host-1": profile(),
    "users/deleted": profile(),
    "deletedUsers/deleted": {deletedAt: "now"},
  });

  await assert.rejects(
    () => createClubHandler(request(null, payload()), h.deps),
    (error) => assertHttpsCode(error, "unauthenticated")
  );
  await assert.rejects(
    () => createClubHandler(
      request("host-1", payload({clubId: "existing"})),
      h.deps
    ),
    (error) => assertHttpsCode(error, "already-exists")
  );
  await assert.rejects(
    () => createClubHandler(request("deleted", payload()), h.deps),
    (error) => assertHttpsCode(error, "failed-precondition")
  );
});

test("createClubHandler rejects hosts that already own a club", async () => {
  const h = harness({
    "users/host-1": profile(),
    "clubs/existing-club": {
      ...payload({clubId: undefined}),
      hostUserId: "host-1",
    },
  });

  await assert.rejects(
    () => createClubHandler(request("host-1", payload()), h.deps),
    (error) => assertHttpsCode(error, "failed-precondition")
  );
});

test("createClubHandler rejects hosts with an existing host claim",
  async () => {
    const h = harness({
      "users/host-1": profile(),
      "clubHostClaims/host-1": {uid: "host-1", clubId: "existing"},
    });

    await assert.rejects(
      () => createClubHandler(request("host-1", payload()), h.deps),
      (error) => assertHttpsCode(error, "failed-precondition")
    );
  }
);
