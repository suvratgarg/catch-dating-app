import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest} from "firebase-functions/v2/https";
import {
  adminCreateMarketingContentDraftHandler,
  adminGetMarketingOpsDashboardHandler,
  adminRecordMarketingReviewDecisionHandler,
  decisionIdForMarketingTarget,
} from "./marketingOps";

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

function approvalPayload(overrides: FakeData = {}) {
  return {
    targetType: "event_candidate",
    targetId: "mumbai-2026-06-experimenter-colaba-photo",
    decision: "approve",
    runId: "mumbai-2026-06-22-weekly-event-guide",
    note: "Reviewed for marketing recommendation use.",
    edits: {
      title: "Photo Exhibition at Experimenter",
      sourceUrl: "https://www.instagram.com/p/DZK5ZZFjN_W/",
    },
    checklist: {
      sourceReviewed: true,
      dateReviewed: true,
      venueReviewed: true,
      copyReviewed: true,
      rightsReviewed: false,
      noCatchHostingImplied: true,
    },
    ...overrides,
  };
}

function dashboardBridge() {
  return {
    schemaVersion: 1,
    program: "catch-event-guide-marketing-ops",
    generatedAt: "2026-06-23T00:00:00.000Z",
    city: {
      id: "mumbai",
      label: "Mumbai",
      timezone: "Asia/Kolkata",
    },
    weekStart: "2026-06-22",
    weekEnd: "2026-06-29",
    timezone: "Asia/Kolkata",
    summary: {
      status: "ready",
      sourceProfiles: 0,
      queryTemplates: 0,
      sourceResults: 0,
      sourceResultsNeedingReview: 0,
      eventCandidates: 1,
      approvedCandidates: 1,
      candidatesNeedingReview: 0,
      recommendationSets: 1,
      contentDrafts: 0,
      exportReadyDrafts: 0,
    },
    guardrails: [],
    sourceProfiles: [],
    queryTemplates: [],
    runPlan: {
      id: "mumbai-2026-06-22-weekly-event-guide",
      cityId: "mumbai",
      weekStart: "2026-06-22",
      status: "ready",
      generatedAt: "2026-06-23T00:00:00.000Z",
      schedule: {cadence: "weekly", publishDay: "Monday", lookaheadDays: 7},
      budgets: {maxQueries: 0, maxSourceResults: 0, maxCandidatePool: 0},
      automationPolicy: {
        searchProvider: "manual",
        networkFetchesEnabled: false,
        instagramScrapingEnabled: false,
        requiresHumanApprovalBeforePublish: true,
      },
      queryIds: [],
      sourceProfileIds: [],
    },
    sourceResults: [],
    eventCandidates: [
      {
        id: "event-1",
        title: "Colaba Photo Walk",
        venue: "Experimenter",
        neighborhood: "Colaba",
        startDate: "2026-06-26",
        time: "19:30",
        price: "Free",
        whySinglesFriendly: "Good small-group culture.",
        publicDescription: "A gallery walk.",
      },
    ],
    recommendationSets: [
      {
        id: "rec-1",
        cityId: "mumbai",
        weekStart: "2026-06-22",
        weekEnd: "2026-06-29",
        tone: "singles-friendly",
        title: "Mumbai plans worth leaving the app for",
        status: "ready",
        reviewState: "approved",
        items: [
          {
            id: "item-1",
            eventCandidateId: "event-1",
            rank: 1,
            title: "Colaba Photo Walk",
            category: "Art",
            neighborhood: "Colaba",
            score: 83,
            inclusionReason: "Easy to join solo.",
            warnings: [],
            reviewState: "approved",
          },
        ],
      },
    ],
    contentDrafts: [],
    appFeatureMedia: {
      schemaVersion: 1,
      status: "ready",
      generatedAt: "2026-06-23T00:00:00.000Z",
      sourceDocs: {},
      summary: {},
      commands: {},
      captures: [
        {
          id: "member-event-discovery",
          audience: "members",
          surface: "Event discovery",
          status: "active",
          sourcePath: "design/screens/member.png",
          websitePath: "public/images/member.png",
          webPath: "/images/member.png",
          alt: "Catch event discovery screen",
          caption: "Discover events by activity.",
          walkthroughStep: "Event discovery",
        },
      ],
    },
    auditTrail: [],
    commands: {},
  };
}

function assertHttpsCode(error: unknown, code: string): boolean {
  assert.equal((error as {code?: string}).code, code);
  return true;
}

test("adminGetMarketingOpsDashboardHandler returns deterministic empty bridge",
  async () => {
    const h = harness();

    const result = await adminGetMarketingOpsDashboardHandler(
      callableRequest("admin-1", {}, {support: true}),
      h.deps
    );

    assert.equal(result.bridge.generatedAt, "2026-06-25T08:30:00.000Z");
    assert.equal(result.bridge.weekStart, "2026-06-25");
    assert.equal((result.bridge.summary as FakeData).status, "not_synced");
  });

test("adminRecordMarketingReviewDecisionHandler records an approval decision",
  async () => {
    const h = harness();

    const result = await adminRecordMarketingReviewDecisionHandler(
      callableRequest("admin-1", approvalPayload(), {support: true}),
      h.deps
    );

    assert.deepEqual(result, {
      decisionId:
        "marketing-event-candidate-mumbai-2026-06-experimenter-colaba-photo",
      targetType: "event_candidate",
      targetId: "mumbai-2026-06-experimenter-colaba-photo",
      decision: "approve",
      decisionStatus: "approved",
      decisionPath:
        "marketingReviewDecisions/" +
        "marketing-event-candidate-mumbai-2026-06-experimenter-colaba-photo",
    });
    assert.equal(h.firestore.auditLogs().length, 1);
    assert.equal(
      h.firestore.get(
        "marketingReviewDecisions/" +
          "marketing-event-candidate-mumbai-2026-06-experimenter-colaba-photo"
      )?.effect,
      "decision_only_no_publish"
    );
  });

test("adminCreateMarketingContentDraftHandler appends an event draft",
  async () => {
    const h = harness({
      "marketingOpsDashboards/current": {bridge: dashboardBridge()},
    });

    const result = await adminCreateMarketingContentDraftHandler(
      callableRequest(
        "admin-1",
        {
          draftType: "event_highlights",
          cityId: "mumbai",
          weekStart: "2026-06-22",
          sourceRecommendationSetId: "rec-1",
        },
        {support: true}
      ),
      h.deps
    );

    assert.match(
      result.draft.id as string,
      /^mumbai-2026-06-22-event-highlights-[a-f0-9]{8}$/
    );
    assert.equal(result.draft.recommendationSetId, "rec-1");
    assert.equal(
      (result.bridge.summary as FakeData).contentDrafts,
      1
    );
    const saved = h.firestore.get("marketingOpsDashboards/current");
    const savedBridge = saved?.bridge as FakeData;
    assert.equal(((savedBridge.contentDrafts as FakeData[])[0]).id,
      result.draft.id);
    assert.equal(h.firestore.auditLogs().length, 1);
  });

test("adminCreateMarketingContentDraftHandler creates feature drafts",
  async () => {
    const h = harness({
      "marketingOpsDashboards/current": {bridge: dashboardBridge()},
    });

    const result = await adminCreateMarketingContentDraftHandler(
      callableRequest(
        "admin-1",
        {
          draftType: "feature_explainer",
          cityId: "mumbai",
          weekStart: "2026-06-22",
        },
        {support: true}
      ),
      h.deps
    );

    const slides = result.draft.slides as FakeData[];
    assert.equal(result.draft.recommendationSetId, "app-feature-media");
    assert.equal(slides.some((slide) => slide.role === "feature"), true);
  });

test("adminCreateMarketingContentDraftHandler rejects unknown draft types",
  async () => {
    const h = harness({
      "marketingOpsDashboards/current": {bridge: dashboardBridge()},
    });

    await assert.rejects(
      () => adminCreateMarketingContentDraftHandler(
        callableRequest(
          "admin-1",
          {draftType: "organizer_spotlight"},
          {support: true}
        ),
        h.deps
      ),
      (error) => assertHttpsCode(error, "invalid-argument")
    );
  });

test("adminRecordMarketingReviewDecisionHandler rejects unsafe approvals",
  async () => {
    const h = harness();

    await assert.rejects(
      () => adminRecordMarketingReviewDecisionHandler(
        callableRequest(
          "admin-1",
          approvalPayload({
            checklist: {
              sourceReviewed: true,
              dateReviewed: true,
              venueReviewed: true,
              copyReviewed: true,
              rightsReviewed: false,
              noCatchHostingImplied: false,
            },
          }),
          {support: true}
        ),
        h.deps
      ),
      (error) => assertHttpsCode(error, "failed-precondition")
    );
  });

test("adminRecordMarketingReviewDecisionHandler requires review notes",
  async () => {
    const h = harness();

    await assert.rejects(
      () => adminRecordMarketingReviewDecisionHandler(
        callableRequest(
          "admin-1",
          approvalPayload({note: null}),
          {support: true}
        ),
        h.deps
      ),
      (error) => assertHttpsCode(error, "invalid-argument")
    );
  });

test("adminRecordMarketingReviewDecisionHandler requires content rights review",
  async () => {
    const h = harness();

    await assert.rejects(
      () => adminRecordMarketingReviewDecisionHandler(
        callableRequest(
          "admin-1",
          approvalPayload({
            targetType: "content_draft",
            targetId: "mumbai-2026-06-22-instagram-carousel",
            decision: "export_ready",
            checklist: {
              copyReviewed: true,
              rightsReviewed: false,
              noCatchHostingImplied: true,
            },
          }),
          {support: true}
        ),
        h.deps
      ),
      (error) => assertHttpsCode(error, "failed-precondition")
    );
  });

test("decisionIdForMarketingTarget truncates long ids with a hash suffix",
  () => {
    const id = decisionIdForMarketingTarget(
      "content_draft",
      "x".repeat(240)
    );

    assert.ok(id.length <= 150);
    assert.match(id, /^marketing-content-draft-x+-[a-f0-9]{12}$/);
  });
