import assert from "node:assert/strict";
import test from "node:test";
import {checkOrganizerOperationalHealth} from
  "./check_operational_health.mjs";

test("checkOrganizerOperationalHealth accepts action-required health", () => {
  const result = checkOrganizerOperationalHealth({
    health: actionRequiredHealth(),
  });

  assert.equal(result.ok, true);
  assert.deepEqual(result.errors, []);
  assert.equal(result.summary.healthStatus, "p0_action_required");
  assert.equal(result.summary.highestPriority, "p0");
  assert.equal(result.summary.workstreams, 3);
  assert.equal(result.summary.unresolvedWorkstreams, 2);
  assert.equal(result.unresolvedWorkstreams[0].id, "publication_review");
  assert.equal(result.unresolvedWorkstreams[1].id, "policy_decisions");
  assert.match(result.warnings[0], /2 operational workstream/);
});

test("checkOrganizerOperationalHealth can require ready health", () => {
  const result = checkOrganizerOperationalHealth({
    health: actionRequiredHealth(),
    requireReady: true,
  });

  assert.equal(result.ok, false);
  assert.match(result.errors.join("\n"), /expected ready/);

  const ready = actionRequiredHealth();
  ready.summary.healthStatus = "ready";
  ready.summary.highestPriority = "p3";
  ready.summary.workstreamsByPriority = {p3: 1};
  ready.summary.workstreamsByStatus = {clear: 1};
  ready.summary.workstreams = 1;
  ready.workstreams = [
    {
      blockers: [],
      commands: [],
      id: "publication_review",
      label: "Publication Review",
      metrics: {},
      nextActions: [],
      priority: "p3",
      sourceArtifacts: [],
      status: "clear",
    },
  ];

  const readyResult = checkOrganizerOperationalHealth({
    health: ready,
    requireReady: true,
  });

  assert.equal(readyResult.ok, true);
  assert.equal(readyResult.summary.unresolvedWorkstreams, 0);
});

test("checkOrganizerOperationalHealth rejects stale summary counts", () => {
  const health = actionRequiredHealth();
  health.summary.workstreamsByStatus.requires_policy_input = 2;
  health.summary.highestPriority = "p1";

  const result = checkOrganizerOperationalHealth({health});

  assert.equal(result.ok, false);
  assert.match(result.errors.join("\n"), /workstreamsByStatus/);
  assert.match(result.errors.join("\n"), /highestPriority/);
});

function actionRequiredHealth() {
  return {
    schemaVersion: 1,
    summary: {
      actionRequiredWorkstreams: 2,
      adminDecisionsRequired: 1,
      healthStatus: "p0_action_required",
      highestPriority: "p0",
      operatorActions: 2,
      policyBlockedWorkstreams: 0,
      policyInputsRequired: 1,
      waitingWorkstreams: 0,
      workstreams: 3,
      workstreamsByPriority: {
        p0: 2,
        p3: 1,
      },
      workstreamsByStatus: {
        idle: 1,
        requires_admin_decision: 1,
        requires_policy_input: 1,
      },
    },
    workstreams: [
      {
        blockers: ["event_crawl_plan"],
        commands: ["node tool/organizer_intake/policy_gap_decision.mjs list"],
        id: "policy_decisions",
        label: "Policy Decisions",
        metrics: {unansweredQuestions: 1},
        nextActions: ["Choose crawl policy."],
        priority: "p0",
        sourceArtifacts: [],
        status: "requires_policy_input",
      },
      {
        blockers: [],
        commands: ["node tool/organizer_intake/review_decision.mjs list"],
        id: "publication_review",
        label: "Publication Review",
        metrics: {readyForManualReview: 1},
        nextActions: ["Record publication decision."],
        priority: "p0",
        sourceArtifacts: [],
        status: "requires_admin_decision",
      },
      {
        blockers: [],
        commands: ["node tool/organizer_intake/ingest_search_results.mjs --check"],
        id: "search_intake",
        label: "Search Intake",
        metrics: {candidates: 0},
        nextActions: [],
        priority: "p3",
        sourceArtifacts: [],
        status: "idle",
      },
    ],
  };
}
