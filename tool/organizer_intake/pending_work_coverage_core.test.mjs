import assert from "node:assert/strict";
import test from "node:test";
import {buildOrganizerPendingWorkCoverage} from
  "./lib/pending_work_coverage_core.mjs";

test("pending work coverage maps unresolved health to inputs and follow-ups", () => {
  const coverage = buildOrganizerPendingWorkCoverage({
    operationalHealth: operationalHealth(),
    pendingInputRequest: pendingInputRequest(),
  });

  assert.equal(coverage.summary.status, "awaiting_required_input");
  assert.equal(coverage.summary.unresolvedWorkstreams, 3);
  assert.equal(coverage.summary.coveredWorkstreams, 3);
  assert.equal(coverage.summary.coveredByInputRequest, 2);
  assert.equal(coverage.summary.coveredByFollowUp, 1);
  assert.equal(coverage.summary.untriagedWorkstreams, 0);
  assert.equal(coverage.summary.highestPriority, "p0");

  const publication = coverage.entries.find((entry) =>
    entry.workstreamId === "publication_review");
  assert.deepEqual(publication.pendingRequestIds, [
    "admin-publication:afterfly",
  ]);
  assert.equal(publication.coverageStatus, "covered_by_input_request");

  const rawStorage = coverage.entries.find((entry) =>
    entry.workstreamId === "raw_artifact_storage");
  assert.deepEqual(rawStorage.followUpIds, ["workflow:raw_artifact_storage"]);
  assert.equal(rawStorage.coverageStatus, "covered_by_follow_up");
});

test("pending work coverage flags untriaged unresolved workstreams", () => {
  const coverage = buildOrganizerPendingWorkCoverage({
    operationalHealth: {
      workstreams: [
        {
          commands: [],
          id: "new_workstream",
          label: "New Workstream",
          nextActions: [],
          priority: "p1",
          status: "blocked",
        },
      ],
    },
    pendingInputRequest: pendingInputRequest(),
  });

  assert.equal(coverage.summary.status, "untriaged_work");
  assert.equal(coverage.summary.untriagedWorkstreams, 1);
  assert.equal(coverage.entries[0].coverageStatus, "untriaged");
  assert.equal(coverage.entries[0].blockerClass, "missing_pending_input");
});

function operationalHealth() {
  return {
    workstreams: [
      {
        commands: ["node review"],
        id: "publication_review",
        label: "Publication Review",
        nextActions: ["Record publication decision."],
        priority: "p0",
        status: "requires_admin_decision",
      },
      {
        commands: ["node policy"],
        id: "policy_decisions",
        label: "Policy Decisions",
        nextActions: ["Record policy decision."],
        priority: "p0",
        status: "requires_policy_input",
      },
      {
        blockers: ["bucket_missing"],
        commands: ["node storage"],
        id: "raw_artifact_storage",
        label: "Raw Artifact Storage",
        nextActions: ["Choose storage policy."],
        priority: "p1",
        status: "blocked_by_policy",
      },
      {
        commands: [],
        id: "search_intake",
        label: "Search Intake",
        nextActions: [],
        priority: "p3",
        status: "ready",
      },
    ],
  };
}

function pendingInputRequest() {
  return {
    requests: [
      {
        commands: ["node review"],
        requestId: "admin-publication:afterfly",
        requestType: "admin_publication_decision",
      },
      {
        commands: ["node policy"],
        requestId: "policy:recurring_event_crawl_policy",
        requestType: "policy_decision",
      },
    ],
    followUps: [
      {
        commands: ["node storage"],
        followUpId: "workflow:raw_artifact_storage",
        workstreamId: "raw_artifact_storage",
      },
    ],
  };
}
