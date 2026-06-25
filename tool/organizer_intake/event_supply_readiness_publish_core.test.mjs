import assert from "node:assert/strict";
import test from "node:test";
import {
  applyEventSupplyReadinessPublishPlan,
  buildEventSupplyReadinessPublishPlan,
} from "./lib/event_supply_readiness_publish_core.mjs";

test("buildEventSupplyReadinessPublishPlan wraps generated plans", () => {
  const plan = buildEventSupplyReadinessPublishPlan({
    generatedAt: "2026-06-25T00:00:00.000Z",
    importPlanPath: "tool/organizer_intake/generated/external_event_import_plan.json",
    executionPlanPath:
      "tool/organizer_intake/generated/external_event_import_execution_plan.json",
    importPlan: importPlan(),
    executionPlan: executionPlan(),
  });

  assert.equal(plan.targetPath, "eventSupplyReadiness/current");
  assert.equal(plan.summary.candidates, 2);
  assert.equal(plan.summary.proposedReadOnlyEvents, 1);
  assert.equal(plan.summary.importBlocked, 1);
  assert.equal(plan.summary.executionBlocked, 1);
  assert.equal(plan.summary.writeEnabled, false);
  assert.equal(plan.document.importPlan.policy.status, "disabled");
  assert.equal(
    plan.document.sourcePaths.importPlan,
    "tool/organizer_intake/generated/external_event_import_plan.json"
  );
});

test("applyEventSupplyReadinessPublishPlan writes one guarded dashboard doc",
  async () => {
    const writes = [];
    const firestore = {
      collection(collectionPath) {
        return {
          doc(docId) {
            return {
              async set(patch, options) {
                writes.push({path: `${collectionPath}/${docId}`, patch, options});
              },
            };
          },
        };
      },
    };
    const plan = buildEventSupplyReadinessPublishPlan({
      generatedAt: "2026-06-25T00:00:00.000Z",
      importPlan: importPlan(),
      executionPlan: executionPlan(),
    });

    const result = await applyEventSupplyReadinessPublishPlan(
      firestore,
      plan,
      {serverTimestamp: "SERVER_TIMESTAMP"}
    );

    assert.deepEqual(result, {
      targetPath: "eventSupplyReadiness/current",
      written: true,
      generatedAt: "2026-06-25T00:00:00.000Z",
    });
    assert.equal(writes.length, 1);
    assert.equal(writes[0].path, "eventSupplyReadiness/current");
    assert.deepEqual(writes[0].options, {merge: true});
    assert.equal(writes[0].patch.updatedAt, "SERVER_TIMESTAMP");
    assert.equal(writes[0].patch.executionPlan.policy.status, "disabled");
  });

function importPlan() {
  return {
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
      batches: [],
      reviewDecisionBatches: [],
      locationResolutionBatches: [],
    },
    guardrails: ["event_import_writes_disabled_by_default"],
    actions: [],
    commands: {
      plan: "node tool/organizer_intake/plan_external_event_imports.mjs",
    },
  };
}

function executionPlan() {
  return {
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
      preflight: "node tool/organizer_intake/preflight_external_event_imports.mjs",
    },
  };
}
