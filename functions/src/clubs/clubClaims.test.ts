import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {
  adminDecideClubClaimHandler,
  requestClubClaimHandler,
} from "./clubClaims";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  readonly id: string;

  constructor(readonly firestore: FakeFirestore, readonly path: string) {
    this.id = path.split("/").at(-1) ?? "";
  }

  collection(collectionPath: string) {
    return new FakeCollectionRef(
      this.firestore,
      `${this.path}/${collectionPath}`
    );
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
    return data === undefined ? undefined : {...data};
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
  return {...current, ...patch};
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
        "SERVER_TIMESTAMP" as unknown as FirebaseFirestore.FieldValue,
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

function unclaimedClub(overrides: FakeData = {}): FakeData {
  return {
    name: "AFTER FLY",
    status: "active",
    archived: false,
    hostUserId: null,
    ownerUserId: null,
    hostUserIds: [],
    hostProfiles: [],
    ownership: {
      state: "programmatic",
      ownerUserId: null,
      primaryHostUserId: null,
      hostUserIds: [],
      claimedAt: null,
      claimedByUid: null,
    },
    claim: {
      state: "unclaimed",
      claimHref: "/host/#founding-hosts",
      lastClaimRequestId: null,
    },
    provenance: {
      origin: "scraper",
      sourceConfidence: "high",
      verificationStatus: "sourceBacked",
      lastVerifiedAt: "SOURCE_TIMESTAMP",
    },
    ...overrides,
  };
}

function userProfile(overrides: FakeData = {}): FakeData {
  return {
    profileComplete: true,
    name: "Asha Runner",
    displayName: "Asha Host",
    profilePhotos: [{
      id: "photo-1",
      url: "https://example.com/avatar.jpg",
      thumbnailUrl: "https://example.com/avatar-thumb.jpg",
      storagePath: "users/owner-1/photos/photo-1.jpg",
      thumbnailStoragePath: "users/owner-1/photoThumbnails/photo-1.jpg",
      position: 0,
      createdAt: {toDate: () => new Date("2026-01-01T00:00:00.000Z")},
      updatedAt: {toDate: () => new Date("2026-01-01T00:00:00.000Z")},
    }],
    ...overrides,
  };
}

function pendingRequest(overrides: FakeData = {}): FakeData {
  return {
    requestId: "club_claim_request_1",
    clubId: "afterfly-run-club-indore",
    requesterUid: "owner-1",
    requesterName: "Asha Host",
    requesterRole: "owner",
    businessEmail: "asha@example.com",
    businessPhone: null,
    proofUrls: ["https://example.com/proof"],
    message: "I run this club.",
    status: "pending",
    createdAt: "REQUEST_CREATED",
    updatedAt: "REQUEST_CREATED",
    decidedAt: null,
    decidedByUid: null,
    decisionReason: null,
    previousRequestId: null,
    ...overrides,
  };
}

function assertHttpsCode(error: unknown, code: string): boolean {
  return error instanceof HttpsError && error.code === code;
}

test("requestClubClaimHandler creates a pending request and marks the club",
  async () => {
    const h = harness({
      "clubs/afterfly-run-club-indore": unclaimedClub(),
    });

    const result = await requestClubClaimHandler(
      callableRequest("owner-1", {
        clubId: "afterfly-run-club-indore",
        requesterName: " Asha Host ",
        requesterRole: "owner",
        businessEmail: " asha@example.com ",
        proofUrls: [
          "https://example.com/proof",
          "https://example.com/proof",
        ],
        message: " I run this club. ",
      }),
      h.deps
    );

    assert.equal(result.status, "pending");
    assert.match(result.requestId, /^club_claim_[a-f0-9]{24}$/);
    assert.deepEqual(h.rateLimitCalls, ["owner-1:requestClubClaim"]);
    const requestDoc = h.firestore.get(
      `clubClaimRequests/${result.requestId}`
    );
    assert.equal(requestDoc?.requesterName, "Asha Host");
    assert.deepEqual(requestDoc?.proofUrls, ["https://example.com/proof"]);
    assert.deepEqual(
      h.firestore.get("clubs/afterfly-run-club-indore")?.claim,
      {
        state: "claimPending",
        claimHref: "/host/#founding-hosts",
        lastClaimRequestId: result.requestId,
      }
    );
  }
);

test("requestClubClaimHandler rejects users who already own a club",
  async () => {
    const h = harness({
      "clubs/afterfly-run-club-indore": unclaimedClub(),
      "clubHostClaims/owner-1": {
        uid: "owner-1",
        clubId: "existing-club",
        createdAt: "SERVER_TIMESTAMP",
      },
    });

    await assert.rejects(
      () => requestClubClaimHandler(
        callableRequest("owner-1", {
          clubId: "afterfly-run-club-indore",
          requesterName: "Asha",
          requesterRole: "owner",
        }),
        h.deps
      ),
      (error) => assertHttpsCode(error, "failed-precondition")
    );
  }
);

test("adminDecideClubClaimHandler approves pending claims",
  async () => {
    const h = harness({
      "clubClaimRequests/club_claim_request_1": pendingRequest(),
      "clubs/afterfly-run-club-indore": unclaimedClub({
        claim: {
          state: "claimPending",
          claimHref: "/host/#founding-hosts",
          lastClaimRequestId: "club_claim_request_1",
        },
      }),
      "users/owner-1": userProfile(),
    });

    const result = await adminDecideClubClaimHandler(
      callableRequest("admin-1", {
        requestId: "club_claim_request_1",
        decision: "approve",
        decisionReason: "Official source verified.",
      }, {support: true}),
      h.deps
    );

    assert.deepEqual(result, {
      requestId: "club_claim_request_1",
      clubId: "afterfly-run-club-indore",
      decision: "approve",
      status: "approved",
    });
    const club = h.firestore.get("clubs/afterfly-run-club-indore");
    assert.equal(club?.ownerUserId, "owner-1");
    assert.equal(club?.hostUserId, "owner-1");
    assert.equal(club?.appVisibility, "discoverable");
    assert.deepEqual(club?.claim, {
      state: "claimed",
      claimHref: null,
      lastClaimRequestId: "club_claim_request_1",
    });
    assert.deepEqual(club?.ownership, {
      state: "claimed",
      ownerUserId: "owner-1",
      primaryHostUserId: "owner-1",
      hostUserIds: ["owner-1"],
      claimedAt: "SERVER_TIMESTAMP",
      claimedByUid: "owner-1",
    });
    assert.equal(
      h.firestore.get("clubHostClaims/owner-1")?.clubId,
      "afterfly-run-club-indore"
    );
    assert.equal(
      h.firestore.get("clubMemberships/afterfly-run-club-indore_owner-1")
        ?.role,
      "owner"
    );
    assert.equal(
      h.firestore.get("clubClaimRequests/club_claim_request_1")?.status,
      "approved"
    );
    assert.deepEqual(
      h.firestore.get(
        "notifications/owner-1/items/clubUpdate_club_claim_request_1"
      ),
      {
        uid: "owner-1",
        type: "clubUpdate",
        title: "Your organizer profile is ready",
        body: "Open Catch to finish setup for AFTER FLY.",
        createdAt: "SERVER_TIMESTAMP",
        clubId: "afterfly-run-club-indore",
        actorUid: "admin-1",
        readAt: null,
      }
    );
    assert.equal(h.firestore.auditLogs().length, 1);
  }
);

test("adminDecideClubClaimHandler rejects pending claims", async () => {
  const h = harness({
    "clubClaimRequests/club_claim_request_1": pendingRequest(),
    "clubs/afterfly-run-club-indore": unclaimedClub({
      claim: {
        state: "claimPending",
        claimHref: "/host/#founding-hosts",
        lastClaimRequestId: "club_claim_request_1",
      },
    }),
  });

  const result = await adminDecideClubClaimHandler(
    callableRequest("admin-1", {
      requestId: "club_claim_request_1",
      decision: "reject",
      decisionReason: "Could not verify ownership.",
    }, {support: true}),
    h.deps
  );

  assert.deepEqual(result, {
    requestId: "club_claim_request_1",
    clubId: "afterfly-run-club-indore",
    decision: "reject",
    status: "rejected",
  });
  assert.equal(
    h.firestore.get("clubClaimRequests/club_claim_request_1")?.status,
    "rejected"
  );
  assert.deepEqual(
    h.firestore.get("clubs/afterfly-run-club-indore")?.claim,
    {
      state: "unclaimed",
      claimHref: "/host/#founding-hosts",
      lastClaimRequestId: "club_claim_request_1",
    }
  );
  assert.equal(h.firestore.auditLogs().length, 1);
});

test("adminDecideClubClaimHandler blocks viewer-only admins", async () => {
  const h = harness({
    "clubClaimRequests/club_claim_request_1": pendingRequest(),
  });

  await assert.rejects(
    () => adminDecideClubClaimHandler(
      callableRequest("admin-1", {
        requestId: "club_claim_request_1",
        decision: "approve",
      }, {analyticsViewer: true}),
      h.deps
    ),
    (error) => assertHttpsCode(error, "permission-denied")
  );
});
