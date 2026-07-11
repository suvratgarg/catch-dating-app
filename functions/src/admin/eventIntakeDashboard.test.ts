import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest} from "firebase-functions/v2/https";
import {
  adminGetEventIntakeDashboardHandler,
  overlayEventIntakeDecisions,
} from "./eventIntakeDashboard";

type FakeData = Record<string, unknown>;

const regenerateCommand =
  "node tool/marketing/event_guide/scripts/" +
  "generate_marketing_ops_bridge.mjs --week 2026-06-22";
const updateAdminBridgeCommand =
  "node tool/marketing/event_guide/scripts/" +
  "generate_marketing_ops_bridge.mjs --event-intake-admin-output " +
  "admin/src/generated/eventIntakeBridge.json";

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}

  async get() {
    return new FakeSnapshot(this.firestore.get(this.path));
  }
}

class FakeSnapshot {
  constructor(private readonly value: FakeData | undefined) {}

  data(): FakeData | undefined {
    return this.value === undefined ? undefined : structuredClone(this.value);
  }
}

class FakeCollectionRef {
  constructor(
    private readonly firestore: FakeFirestore,
    private readonly path: string
  ) {}

  doc(docId: string) {
    return new FakeDocRef(this.firestore, `${this.path}/${docId}`);
  }

  limit(count: number) {
    return new FakeQuery(this.firestore, this.path, count);
  }
}

class FakeQuery {
  constructor(
    private readonly firestore: FakeFirestore,
    private readonly path: string,
    private readonly count: number
  ) {}

  async get() {
    const prefix = `${this.path}/`;
    return {
      docs: this.firestore.entries()
        .filter(([path, value]) =>
          path.startsWith(prefix) &&
          path.slice(prefix.length).split("/").length === 1 &&
          value !== undefined
        )
        .slice(0, this.count)
        .map(([, value]) => ({
          data: () => structuredClone(value as FakeData),
        })),
    };
  }
}

class FakeFirestore {
  constructor(private readonly docs: Record<string, FakeData | undefined>) {}

  collection(collectionPath: string) {
    return new FakeCollectionRef(this, collectionPath);
  }

  get(path: string): FakeData | undefined {
    const data = this.docs[path];
    return data === undefined ? undefined : structuredClone(data);
  }

  entries() {
    return Object.entries(this.docs);
  }
}

function harness(initialDocs: Record<string, FakeData | undefined> = {}) {
  const firestore = new FakeFirestore(initialDocs);
  return {
    firestore,
    deps: {
      firestore: () =>
        firestore as unknown as FirebaseFirestore.Firestore,
    },
  };
}

function callableRequest(
  uid: string | null,
  token: Record<string, unknown> = {}
): CallableRequest<unknown> {
  return {
    auth: uid ? {uid, token} as CallableRequest["auth"] : undefined,
    data: {},
    rawRequest: {headers: {}} as CallableRequest["rawRequest"],
  } as CallableRequest<unknown>;
}

function sourceBridge(overrides: FakeData = {}) {
  return {
    schemaVersion: 1,
    program: "catch-event-guide-marketing-ops",
    generatedAt: "2026-06-25T00:00:00.000Z",
    city: {id: "mumbai", label: "Mumbai"},
    weekStart: "2026-06-22",
    summary: {eventCandidates: 2},
    sourceProfiles: [{id: "cntraveller"}],
    queryTemplates: [{id: "mumbai-events"}],
    runPlan: {
      id: "mumbai-2026-06-22-weekly-event-guide",
      status: "planned",
      schedule: {cadence: "weekly", publishDay: "Monday", lookaheadDays: 7},
      budgets: {maxQueries: 16, maxSourceResults: 40, maxCandidatePool: 25},
      automationPolicy: {
        searchProvider: "not_configured",
        networkFetchesEnabled: false,
        instagramScrapingEnabled: false,
      },
    },
    sourceResults: [{id: "source-1"}],
    eventCandidates: [{id: "candidate-1"}],
    dedupeGroups: [{canonicalCandidateId: "candidate-1"}],
    auditTrail: [{targetId: "candidate-1"}],
    commands: {
      regenerate: regenerateCommand,
      updateAdminBridge: updateAdminBridgeCommand,
    },
    recommendationSets: [{id: "marketing-only"}],
    contentDrafts: [{id: "draft-1"}],
    ...overrides,
  };
}

function assertHttpsCode(error: unknown, code: string): boolean {
  assert.equal((error as {code?: string}).code, code);
  return true;
}

test("adminGetEventIntakeDashboardHandler reads event dashboard first",
  async () => {
    const h = harness({
      "eventIntakeDashboards/current": {bridge: sourceBridge({
        city: {id: "indore", label: "Indore"},
      })},
      "marketingOpsDashboards/current": {bridge: sourceBridge()},
    });

    const result = await adminGetEventIntakeDashboardHandler(
      callableRequest("admin-1", {support: true}),
      h.deps
    );

    assert.equal((result.bridge.city as FakeData).id, "indore");
    assert.equal(result.bridge.program, "catch-event-intake");
    assert.equal(result.bridge.bridgeSource, "event_intake");
    assert.deepEqual(result.bridge.commands, {
      regenerate: regenerateCommand,
      updateAdminBridge: updateAdminBridgeCommand,
    });
    assert.equal("contentDrafts" in result.bridge, false);
  });

test("event intake decisions survive dashboard refresh and overlay edits",
  async () => {
    const h = harness({
      "eventIntakeDashboards/current": {bridge: sourceBridge()},
      "eventIntakeReviewDecisions/event_candidate_candidate-1": {
        targetType: "event_candidate",
        targetId: "candidate-1",
        decision: "approve",
        decisionStatus: "approved",
        note: "Official source and venue verified.",
        edits: {title: "Verified candidate"},
        reviewedByUid: "admin-1",
        reviewedAt: "2026-07-11T00:00:00.000Z",
      },
    });

    const result = await adminGetEventIntakeDashboardHandler(
      callableRequest("admin-1", {support: true}),
      h.deps
    );
    const candidates = result.bridge.eventCandidates as FakeData[];
    assert.equal(candidates[0].title, "Verified candidate");
    assert.equal(candidates[0].reviewState, "approved");
    assert.equal((result.bridge.summary as FakeData).approvedCandidates, 1);
    assert.equal((result.bridge.summary as FakeData).overlaidDecisions, 1);
  }
);

test("overlayEventIntakeDecisions preserves source ids across edits", () => {
  const result = overlayEventIntakeDecisions(sourceBridge(), [{
    targetType: "source_result",
    targetId: "source-1",
    decision: "needs_changes",
    decisionStatus: "needs_changes",
    note: "Replace the placeholder source.",
    edits: {id: "attempted-rewrite", title: "Needs a real source"},
    reviewedByUid: "admin-1",
    reviewedAt: "2026-07-11T00:00:00.000Z",
  }]);
  const sourceResults = result.sourceResults as FakeData[];
  assert.equal(sourceResults[0].id, "source-1");
  assert.equal(sourceResults[0].status, "needs_changes");
});

test(
  "adminGetEventIntakeDashboardHandler returns empty without event dashboard",
  async () => {
    const h = harness({
      "marketingOpsDashboards/current": {bridge: sourceBridge()},
    });

    const result = await adminGetEventIntakeDashboardHandler(
      callableRequest("admin-1", {support: true}),
      h.deps
    );

    assert.equal((result.bridge.city as FakeData).id, "unknown");
    assert.equal(result.bridge.bridgeSource, "empty");
    assert.deepEqual(result.bridge.eventCandidates, []);
    assert.deepEqual(result.bridge.commands, {});
    assert.equal("recommendationSets" in result.bridge, false);
  }
);

test("adminGetEventIntakeDashboardHandler blocks viewer-only admins",
  async () => {
    const h = harness();

    await assert.rejects(
      () => adminGetEventIntakeDashboardHandler(
        callableRequest("admin-1", {analyticsViewer: true}),
        h.deps
      ),
      (error) => assertHttpsCode(error, "permission-denied")
    );
  });

test("adminGetEventIntakeDashboardHandler rate limits explicitly",
  async () => {
    const h = harness();
    const rateLimitCalls: string[] = [];

    await adminGetEventIntakeDashboardHandler(
      callableRequest("admin-1", {support: true}),
      {
        ...h.deps,
        checkRateLimit: async (_db, uid, action) => {
          rateLimitCalls.push(`${uid}:${action}`);
        },
      }
    );

    assert.deepEqual(rateLimitCalls, [
      "admin-1:adminGetEventIntakeDashboard",
    ]);
  });
