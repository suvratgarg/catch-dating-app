import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest} from "firebase-functions/v2/https";
import {
  adminGetEventSupplyReadinessHandler,
} from "./eventSupplyReadiness";

type FakeData = Record<string, unknown>;

class FakeDocRef {
  constructor(readonly firestore: FakeFirestore, readonly path: string) {}

  async get() {
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

  doc(docId: string) {
    return new FakeDocRef(this.firestore, `${this.path}/${docId}`);
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

function importPlan(overrides: FakeData = {}) {
  return {
    schemaVersion: 1,
    summary: {
      candidates: 2,
      proposedReadOnlyEvents: 1,
      proposedCreates: 1,
      mergedSourceLinks: 1,
      writeReady: 0,
      blocked: 1,
      waitingReview: 1,
      rejected: 0,
      duplicateEventKeys: 1,
      actionsByStatus: {blocked: 1},
      actionsByPlatform: {luma: 1},
    },
    policy: {
      status: "disabled",
      writeEnabled: false,
      reason: "Read-only review only.",
    },
    generatedFrom: {
      externalEventCandidateQueue:
        "tool/organizer_intake/generated/external_event_candidate_queue.json",
      batches: ["batch-a"],
      reviewDecisionBatches: [],
      locationResolutionBatches: [],
    },
    guardrails: ["event_import_writes_disabled_by_default"],
    actions: [],
    commands: {
      plan: "node tool/organizer_intake/plan_external_event_imports.mjs",
    },
    ...overrides,
  };
}

function executionPlan(overrides: FakeData = {}) {
  return {
    schemaVersion: 1,
    summary: {
      importActions: 1,
      createActions: 0,
      readOnlyActions: 1,
      skipped: 0,
      blocked: 1,
      projectionInvalid: 0,
      schemaInvalid: 0,
      wouldPublishReadOnly: 0,
      wouldCreate: 0,
      projectionValid: 1,
      projectionInvalidCount: 0,
      payloadValid: 1,
      payloadInvalid: 0,
      actionsByStatus: {blocked: 1},
    },
    policy: {
      status: "disabled",
      writeEnabled: false,
      authorityModel: "undecided",
      reason: "Preflight only.",
    },
    generatedFrom: {
      externalEventImportPlan:
        "tool/organizer_intake/generated/external_event_import_plan.json",
      importPlanGeneratedFrom: {},
    },
    guardrails: ["execution_preflight_never_writes_firestore"],
    actions: [],
    commands: {
      preflight:
        "node tool/organizer_intake/preflight_external_event_imports.mjs",
    },
    ...overrides,
  };
}

function assertHttpsCode(error: unknown, code: string): boolean {
  assert.equal((error as {code?: string}).code, code);
  return true;
}

test("adminGetEventSupplyReadinessHandler reads published readiness",
  async () => {
    const h = harness({
      "eventSupplyReadiness/current": {
        generatedAt: "2026-06-25T00:00:00.000Z",
        importPlan: importPlan(),
        executionPlan: executionPlan(),
      },
    });

    const result = await adminGetEventSupplyReadinessHandler(
      callableRequest("admin-1", {support: true}),
      h.deps
    );

    assert.equal(result.source, "event_supply_readiness");
    assert.equal(result.generatedAt, "2026-06-25T00:00:00.000Z");
    assert.equal((result.importPlan.summary as FakeData).candidates, 2);
    assert.equal((result.executionPlan.summary as FakeData).importActions, 1);
  });

test("adminGetEventSupplyReadinessHandler falls back to empty disabled plan",
  async () => {
    const h = harness();

    const result = await adminGetEventSupplyReadinessHandler(
      callableRequest("admin-1", {support: true}),
      h.deps
    );

    assert.equal(result.source, "empty");
    assert.equal(result.generatedAt, null);
    assert.equal((result.importPlan.policy as FakeData).writeEnabled, false);
    assert.equal((result.executionPlan.policy as FakeData).writeEnabled, false);
  });

test("adminGetEventSupplyReadinessHandler blocks viewer-only admins",
  async () => {
    const h = harness();

    await assert.rejects(
      () => adminGetEventSupplyReadinessHandler(
        callableRequest("admin-1", {analyticsViewer: true}),
        h.deps
      ),
      (error) => assertHttpsCode(error, "permission-denied")
    );
  });

test("adminGetEventSupplyReadinessHandler rate limits explicitly",
  async () => {
    const h = harness();
    const rateLimitCalls: string[] = [];

    await adminGetEventSupplyReadinessHandler(
      callableRequest("admin-1", {support: true}),
      {
        ...h.deps,
        checkRateLimit: async (_db, uid, action) => {
          rateLimitCalls.push(`${uid}:${action}`);
        },
      }
    );

    assert.deepEqual(rateLimitCalls, [
      "admin-1:adminGetEventSupplyReadiness",
    ]);
  });
