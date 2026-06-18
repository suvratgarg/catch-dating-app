import assert from "node:assert/strict";
import test from "node:test";
import {buildEventCrawlRunPlan} from "./lib/event_crawl_run_plan_core.mjs";

test("buildEventCrawlRunPlan blocks all runs by default", () => {
  const plan = buildEventCrawlRunPlan({
    eventCrawlPlan: sampleEventCrawlPlan(),
  });

  assert.equal(plan.policy.status, "disabled");
  assert.equal(plan.summary.candidateSurfaces, 2);
  assert.equal(plan.summary.wouldFetch, 0);
  assert.equal(plan.summary.blocked, 2);
  assert.equal(plan.summary.networkRequests, 0);
  assert.equal(plan.summary.firestoreWrites, 0);
  assert.deepEqual(plan.summary.platforms, {
    luma: 1,
    sortMyScene: 1,
  });
  assert.deepEqual(plan.runIntents.map((intent) => intent.action), [
    "blocked",
    "blocked",
  ]);
  assert.ok(
    plan.runIntents[0].blockedBy.includes("network_disabled")
  );
  assert.ok(
    plan.runIntents[0].blockedBy.includes("scheduler_disabled")
  );
});

test("buildEventCrawlRunPlan can model a future fetch-ready run", () => {
  const input = sampleEventCrawlPlan();
  input.entries[0].blockedBy = [];

  const plan = buildEventCrawlRunPlan({
    eventCrawlPlan: input,
    executionPolicy: {
      schedulerEnabled: true,
      networkEnabled: true,
      platformAllowlist: ["luma"],
      maxRequestsPerRun: 20,
    },
  });

  assert.equal(plan.policy.status, "enabled");
  assert.equal(plan.summary.wouldFetch, 1);
  assert.equal(plan.summary.blocked, 1);
  assert.equal(plan.summary.networkRequests, 0);
  assert.equal(plan.summary.firestoreWrites, 0);
  assert.equal(plan.runIntents[0].action, "would_fetch");
  assert.equal(plan.runIntents[0].nextGate, "reviewed_provider_capture");
});

function sampleEventCrawlPlan() {
  return {
    policy: {
      schedulerEnabled: true,
    },
    entries: [
      {
        blockedBy: [],
        displayName: "AFTER FLY",
        entityId: "afterfly",
        normalizedKey: "luma:event:pxgmph3b",
        platform: "luma",
        surfaceId: "afterfly-luma-takeoff-run-rave",
        surfaceKind: "eventListing",
        url: "https://luma.com/pxgmph3b",
      },
      {
        blockedBy: ["surface_not_active"],
        displayName: "AFTER FLY",
        entityId: "afterfly",
        normalizedKey: "sortMyScene:profile:afterfly",
        platform: "sortMyScene",
        surfaceId: "afterfly-sortmyscene-reported",
        surfaceKind: "organizerProfile",
        url: "https://sortmyscene.com/organizers/afterfly",
      },
    ],
  };
}
