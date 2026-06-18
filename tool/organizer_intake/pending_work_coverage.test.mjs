import assert from "node:assert/strict";
import test from "node:test";
import {
  checkOrganizerPendingWorkCoverage,
  renderPendingWorkCoverageMarkdown,
} from "./pending_work_coverage.mjs";

test("checker accepts covered pending work", () => {
  const result = checkOrganizerPendingWorkCoverage(coverage());

  assert.equal(result.ok, true);
  assert.deepEqual(result.errors, []);
  assert.equal(result.summary.status, "awaiting_required_input");
  assert.equal(result.summary.unresolvedWorkstreams, 2);
  assert.equal(result.summary.coveredWorkstreams, 2);
  assert.equal(result.summary.untriagedWorkstreams, 0);
});

test("checker rejects stale counts", () => {
  const payload = coverage();
  payload.summary.coveredWorkstreams = 9;
  payload.summary.status = "ready";

  const result = checkOrganizerPendingWorkCoverage(payload);

  assert.equal(result.ok, false);
  assert(
    result.errors.some((error) =>
      error.includes("summary.coveredWorkstreams 9 does not match 2"))
  );
  assert(
    result.errors.some((error) =>
      error.includes("summary.status ready does not match awaiting_required_input"))
  );
});

test("markdown renderer names covered workstreams", () => {
  const markdown = renderPendingWorkCoverageMarkdown(coverage());

  assert.match(markdown, /# Organizer Pending Work Coverage/);
  assert.match(markdown, /Publication Review/);
  assert.match(markdown, /admin-publication:afterfly/);
});

function coverage() {
  return {
    schemaVersion: 1,
    summary: {
      status: "awaiting_required_input",
      unresolvedWorkstreams: 2,
      coveredWorkstreams: 2,
      coveredByInputRequest: 1,
      coveredByFollowUp: 1,
      untriagedWorkstreams: 0,
      highestPriority: "p0",
      coverageByStatus: {
        covered_by_follow_up: 1,
        covered_by_input_request: 1,
      },
      workstreamsByStatus: {
        blocked_by_policy: 1,
        requires_admin_decision: 1,
      },
      workstreamsByPriority: {
        p0: 1,
        p1: 1,
      },
    },
    entries: [
      {
        blockerClass: "requires_decision_input",
        blockers: [],
        commands: ["node review"],
        coverageId: "pending-work:publication_review",
        coverageStatus: "covered_by_input_request",
        followUpIds: [],
        label: "Publication Review",
        nextActions: ["Record decision."],
        pendingRequestIds: ["admin-publication:afterfly"],
        priority: "p0",
        status: "requires_admin_decision",
        workstreamId: "publication_review",
      },
      {
        blockerClass: "covered_follow_up",
        blockers: ["bucket_missing"],
        commands: ["node storage"],
        coverageId: "pending-work:raw_artifact_storage",
        coverageStatus: "covered_by_follow_up",
        followUpIds: ["workflow:raw_artifact_storage"],
        label: "Raw Artifact Storage",
        nextActions: ["Choose policy."],
        pendingRequestIds: [],
        priority: "p1",
        status: "blocked_by_policy",
        workstreamId: "raw_artifact_storage",
      },
    ],
  };
}
