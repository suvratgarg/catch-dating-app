import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest} from "firebase-functions/v2/https";
import {
  adminCreateOrganizerDraftFromCandidateHandler,
} from "./organizerDraftFromCandidate";
import {
  validateAdminCreateOrganizerDraftFromCandidateCallableResponse,
  validateClubDocument,
  validateOrganizerDocument,
  validateOrganizerIntakeCurationDecisionDocument,
  schemaErrorMessages,
} from "../shared/generated/schemaValidators";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  readonly id: string;

  constructor(readonly firestore: FakeFirestore, readonly path: string) {
    this.id = path.split("/").at(-1) ?? "";
  }
}

class FakeSnapshot {
  constructor(
    readonly ref: FakeDocRef,
    private readonly value: FakeData | undefined
  ) {}

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
    return new FakeSnapshot(ref, this.firestore.get(ref.path));
  }

  create(ref: FakeDocRef, data: FakeData) {
    if (this.firestore.get(ref.path) !== undefined) {
      throw new Error(`Document ${ref.path} already exists.`);
    }
    this.writes.push(() => this.firestore.set(ref.path, data));
  }

  set(
    ref: FakeDocRef,
    data: FakeData,
    options?: {merge?: boolean}
  ) {
    this.writes.push(() => {
      this.firestore.set(ref.path, options?.merge ? {
        ...(this.firestore.get(ref.path) ?? {}),
        ...data,
      } : data);
    });
  }

  commit() {
    for (const write of this.writes) write();
  }
}

function harness(
  initialDocs: Record<string, FakeData | undefined> = {}
) {
  const firestore = new FakeFirestore(initialDocs);
  const reservedRoutes: FakeData[] = [];
  return {
    firestore,
    reservedRoutes,
    deps: {
      firestore: () =>
        firestore as unknown as FirebaseFirestore.Firestore,
      serverTimestamp: () =>
        ({_seconds: 1784881800, _nanoseconds: 0}) as unknown as
          FirebaseFirestore.FieldValue,
      reserveCanonicalRoute: async (
        _tx: FirebaseFirestore.Transaction,
        _db: FirebaseFirestore.Firestore,
        options: unknown
      ) => {
        const serializableOptions = Object.fromEntries(
          Object.entries(options as FakeData).filter(([key]) =>
            key !== "serverTimestamp")
        );
        reservedRoutes.push(structuredClone(serializableOptions));
      },
    },
  };
}

function callableRequest(
  data: FakeData,
  token: FakeData = {support: true}
): CallableRequest<unknown> {
  return {
    auth: {
      uid: "admin-1",
      token,
    } as CallableRequest["auth"],
    data,
    rawRequest: {headers: {}} as CallableRequest["rawRequest"],
  } as CallableRequest<unknown>;
}

function payload(overrides: FakeData = {}) {
  return {
    workItemId: "work-courtside",
    candidateId: "candidate-courtside",
    organizerId: "courtside",
    name: "Courtside",
    description: "Reviewed source-backed sports and social community.",
    organizerType: "community",
    reviewNote: "Reviewed the official source before creating this draft.",
    ...overrides,
  };
}

function workItem(overrides: FakeData = {}): FakeData {
  return {
    schemaVersion: 1,
    workItemId: "work-courtside",
    workflowId: "supply-intake",
    runId: "organizer-mumbai-2026-07-24",
    entityKind: "organizer",
    externalKey: "candidate-courtside",
    revision: 0,
    candidateHash: "b".repeat(64),
    primaryStage: "incoming",
    lifecycleStatus: "queued",
    outcome: null,
    taskFlags: ["human_review_required"],
    blockerCodes: [],
    warningCodes: [],
    priority: 10,
    attemptCount: 1,
    evidenceRefs: [],
    fieldProvenance: [],
    normalizedPayload: {
      intake: {
        recordType: "organizer_search_candidate",
        candidate: {
          candidateId: "candidate-courtside",
          canonicalUrl: "https://courtside.example/",
          normalizedKey: "domain:courtside.example",
          platform: "officialWebsite",
          snippet: "Sports and social community in Mumbai.",
          title: "Courtside",
          queryIntent: {marketSlug: "mumbai"},
          existingEntityMatches: [],
          reviewContext: {
            formats: ["Racket sports", "Socials"],
            reviewNotes: "Verify event cadence before publication.",
            verifiedAt: "2026-07-24",
          },
        },
      },
    },
    decisionId: null,
    publicationPlanId: null,
    createdAt: "2026-07-24T08:00:00.000Z",
    updatedAt: "2026-07-24T08:00:00.000Z",
    staleAt: null,
    expiresAt: null,
    ...overrides,
  };
}

function assertHttpsCode(error: unknown, code: string): boolean {
  assert.equal((error as {code?: string}).code, code);
  return true;
}

test("creates a fail-closed organizer draft and curation receipt", async () => {
  const h = harness({
    "operationWorkItems/work-courtside": workItem(),
  });

  const result = await adminCreateOrganizerDraftFromCandidateHandler(
    callableRequest(payload()),
    h.deps
  );

  assert.equal(result.organizerId, "courtside");
  assert.equal(result.created, true);
  assert.equal(
    validateAdminCreateOrganizerDraftFromCandidateCallableResponse(result),
    true,
    schemaErrorMessages(
      validateAdminCreateOrganizerDraftFromCandidateCallableResponse
    ).join("; ")
  );
  assert.deepEqual({
    appVisibility: result.appVisibility,
    ownershipState: result.ownershipState,
    claimState: result.claimState,
    publishStatus: result.publishStatus,
    indexStatus: result.indexStatus,
    crawlStatus: result.crawlStatus,
  }, {
    appVisibility: "hidden",
    ownershipState: "programmatic",
    claimState: "unclaimed",
    publishStatus: "draft",
    indexStatus: "noindex",
    crawlStatus: "disabled",
  });
  const organizer = h.firestore.get("organizers/courtside");
  assert.equal(
    validateOrganizerDocument(organizer),
    true,
    schemaErrorMessages(validateOrganizerDocument).join("; ")
  );
  assert.equal(organizer?.appVisibility, "hidden");
  assert.deepEqual(organizer?.ownership, {
    state: "programmatic",
    ownerUserId: null,
    primaryHostUserId: null,
    hostUserIds: [],
    claimedAt: null,
    claimedByUid: null,
  });
  assert.equal((organizer?.claim as FakeData).state, "unclaimed");
  assert.equal((organizer?.publicPage as FakeData).publishStatus, "draft");
  assert.equal((organizer?.publicPage as FakeData).indexStatus, "noindex");
  assert.equal((organizer?.provenance as FakeData).verificationStatus,
    "sourceBacked");
  assert.equal((organizer?.adminSearch as FakeData).updatedBySource,
    "adminCreateOrganizerDraftFromCandidate");
  const legacyClub = h.firestore.get("clubs/courtside");
  assert.equal(
    validateClubDocument(legacyClub),
    true,
    schemaErrorMessages(validateClubDocument).join("; ")
  );
  const curation = h.firestore.get(result.curationPath);
  assert.equal(
    validateOrganizerIntakeCurationDecisionDocument(curation),
    true,
    schemaErrorMessages(
      validateOrganizerIntakeCurationDecisionDocument
    ).join("; ")
  );
  assert.equal(curation?.operationType, "create_entity_draft");
  assert.equal(curation?.sourceWorkItemId, "work-courtside");
  assert.equal(curation?.sourceCandidateId, "candidate-courtside");
  assert.equal(h.reservedRoutes.length, 1);
  assert.equal(h.reservedRoutes[0].canonicalPath, "/organizers/courtside/");
  assert.equal(h.firestore.auditLogs().length, 1);
});

test("exact retry reuses the organizer without duplicate audit", async () => {
  const h = harness({
    "operationWorkItems/work-courtside": workItem(),
  });

  await adminCreateOrganizerDraftFromCandidateHandler(
    callableRequest(payload()),
    h.deps
  );
  const retry = await adminCreateOrganizerDraftFromCandidateHandler(
    callableRequest(payload()),
    h.deps
  );

  assert.equal(retry.created, false);
  assert.equal(h.firestore.auditLogs().length, 1);
});

test("blocks matched, unreviewed, and viewer-only candidate creation",
  async () => {
    const matched = harness({
      "operationWorkItems/work-courtside": workItem({
        normalizedPayload: {
          intake: {
            recordType: "organizer_search_candidate",
            candidate: {
              ...((workItem().normalizedPayload as FakeData)
                .intake as FakeData).candidate as FakeData,
              existingEntityMatches: [{entityId: "existing-courtside"}],
            },
          },
        },
      }),
    });
    await assert.rejects(
      adminCreateOrganizerDraftFromCandidateHandler(
        callableRequest(payload()),
        matched.deps
      ),
      (error) => assertHttpsCode(error, "failed-precondition")
    );

    const unreviewed = harness({
      "operationWorkItems/work-courtside": workItem({
        normalizedPayload: {
          intake: {
            recordType: "organizer_search_candidate",
            candidate: {
              ...((workItem().normalizedPayload as FakeData)
                .intake as FakeData).candidate as FakeData,
              reviewContext: null,
            },
          },
        },
      }),
    });
    await assert.rejects(
      adminCreateOrganizerDraftFromCandidateHandler(
        callableRequest(payload()),
        unreviewed.deps
      ),
      (error) => assertHttpsCode(error, "failed-precondition")
    );

    const viewer = harness({
      "operationWorkItems/work-courtside": workItem(),
    });
    await assert.rejects(
      adminCreateOrganizerDraftFromCandidateHandler(
        callableRequest(payload(), {analyticsViewer: true}),
        viewer.deps
      ),
      (error) => assertHttpsCode(error, "permission-denied")
    );
  });
