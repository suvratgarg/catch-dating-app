import assert from "node:assert/strict";
import test from "node:test";
import {
  applyEventIntakeDashboardPublishPlan,
  buildEventIntakeDashboardPublishPlan,
  validateEventIntakeDashboardForLivePublish,
} from "./lib/event_intake_dashboard_publish_core.mjs";

test("buildEventIntakeDashboardPublishPlan wraps generated bridge", () => {
  const plan = buildEventIntakeDashboardPublishPlan({
    bridge: eventIntakeBridge(),
    bridgePath: "admin/src/generated/eventIntakeBridge.json",
    generatedAt: "2026-06-25T00:00:00.000Z",
  });

  assert.equal(plan.targetPath, "eventIntakeDashboards/current");
  assert.equal(plan.summary.eventCandidates, 2);
  assert.equal(plan.summary.sourceResults, 1);
  assert.equal(plan.summary.dedupeGroups, 1);
  assert.equal(plan.summary.city, "Mumbai");
  assert.equal(plan.summary.bridgeSource, "native_generated");
  assert.equal(plan.document.bridge.program, "catch-event-intake");
  assert.equal(plan.document.bridge.bridgeSource, "native_generated");
  assert.equal(
    plan.document.sourcePaths.bridge,
    "admin/src/generated/eventIntakeBridge.json"
  );
});

test("live Event Intake validation rejects stale and sample bridge data", () => {
  const bridge = eventIntakeBridge();
  bridge.weekEnd = "2026-06-29";
  bridge.sourceResults = [{
    id: "placeholder",
    url: "https://example.com/events",
    riskFlags: ["placeholder_result"],
  }];
  bridge.eventCandidates = [{
    id: "sample-event",
    sourceLabel: "sample candidate",
  }];

  const errors = validateEventIntakeDashboardForLivePublish(bridge, {
    asOf: "2026-07-11",
  });

  assert.equal(errors.length, 4);
  assert.match(errors.join("\n"), /week ended/);
  assert.match(errors.join("\n"), /placeholder URL/);
  assert.match(errors.join("\n"), /sample candidate/);
});

test("live Event Intake validation accepts a current source-backed bridge", () => {
  const bridge = eventIntakeBridge();
  bridge.weekEnd = "2026-07-18";
  bridge.sourceResults = [{
    id: "official",
    url: "https://luma.com/verified-event",
    riskFlags: [],
  }];
  bridge.eventCandidates = [{
    id: "verified-event",
    sourceLabel: "Luma",
  }];

  assert.deepEqual(
    validateEventIntakeDashboardForLivePublish(bridge, {asOf: "2026-07-11"}),
    []
  );
});

test("applyEventIntakeDashboardPublishPlan writes one dashboard document",
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
    const plan = buildEventIntakeDashboardPublishPlan({
      bridge: eventIntakeBridge(),
      generatedAt: "2026-06-25T00:00:00.000Z",
    });

    const result = await applyEventIntakeDashboardPublishPlan(
      firestore,
      plan,
      {serverTimestamp: "SERVER_TIMESTAMP"}
    );

    assert.deepEqual(result, {
      targetPath: "eventIntakeDashboards/current",
      written: true,
      generatedAt: "2026-06-25T00:00:00.000Z",
    });
    assert.equal(writes.length, 1);
    assert.equal(writes[0].path, "eventIntakeDashboards/current");
    assert.deepEqual(writes[0].options, {merge: true});
    assert.equal(writes[0].patch.updatedAt, "SERVER_TIMESTAMP");
    assert.equal(writes[0].patch.bridge.bridgeSource, "native_generated");
  });

function eventIntakeBridge() {
  return {
    schemaVersion: 1,
    program: "catch-event-intake",
    generatedAt: "2026-06-24T00:00:00.000Z",
    city: {id: "mumbai", label: "Mumbai"},
    weekStart: "2026-06-22",
    summary: {eventCandidates: 2},
    sourceProfiles: [{id: "cntraveller"}],
    queryTemplates: [{id: "mumbai-events"}],
    runPlan: {id: "mumbai-weekly-guide"},
    sourceResults: [{id: "source-1"}],
    eventCandidates: [{id: "candidate-1"}, {id: "candidate-2"}],
    dedupeGroups: [{canonicalCandidateId: "candidate-1"}],
    auditTrail: [{targetId: "candidate-1"}],
    contentDrafts: [{id: "marketing-only"}],
  };
}
