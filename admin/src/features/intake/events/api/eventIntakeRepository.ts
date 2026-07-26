import {
  listIntakeOperations,
  loadEventIntakeDashboard,
} from "../../../../shared/api/adminApi";
import {launchMarketSlugs} from
  "../../../../shared/config/launchMarkets";
import type {
  AdminGetEventIntakeDashboardResponse,
  EventIntakeBridge,
  EventIntakeCandidate,
} from "../../../../shared/types/adminTypes";
import type {
  AdminListIntakeOperationsResponse,
  OperationRun,
  OperationWorkItem,
} from "../../../../shared/operations/operationsTypes";

export async function loadEventIntakeBridge():
Promise<AdminGetEventIntakeDashboardResponse> {
  const [dashboard, inventory] = await Promise.all([
    loadEventIntakeDashboard(),
    listIntakeOperations({
      workflowId: "supply-intake",
      runStatus: "completed",
      entityKind: "event",
      runLimit: 25,
      workItemLimit: 1,
    }),
  ]);
  const runs = latestEventRunPerLaunchMarket(inventory.runs);
  const pages = await Promise.all(runs.map(loadEventRun));
  const orphanCandidates = pages.flatMap((page) =>
    page.workItems.flatMap(orphanCandidateFromWorkItem));
  if (orphanCandidates.length === 0) return dashboard;
  return {
    bridge: mergeOrphanCandidates(dashboard.bridge, orphanCandidates),
  };
}

export {
  recordEventIntakeReviewDecision,
} from "../../../../shared/api/adminApi";

function latestEventRunPerLaunchMarket(runs: OperationRun[]): OperationRun[] {
  const latest = new Map<string, OperationRun>();
  for (const run of runs) {
    const market = stringValue(run.scope.market);
    if (run.scope.intakeScope === "organizer" ||
      !market ||
      !launchMarketSlugs.includes(
        market as typeof launchMarketSlugs[number]
      ) ||
      latest.has(market)) continue;
    latest.set(market, run);
  }
  return launchMarketSlugs
    .map((market) => latest.get(market))
    .filter((run): run is OperationRun => Boolean(run));
}

async function loadEventRun(
  run: OperationRun
): Promise<AdminListIntakeOperationsResponse> {
  let page = await listIntakeOperations({
    workflowId: "supply-intake",
    runId: run.runId,
    runStatus: "completed",
    entityKind: "event",
    workItemLimit: 200,
  });
  const workItems = new Map(page.workItems.map((item) => [
    item.workItemId,
    item,
  ]));
  const cursors = new Set<string>();
  while (page.nextWorkItemCursor) {
    if (cursors.has(page.nextWorkItemCursor)) {
      throw new Error(`Event Intake pagination stalled for run ${run.runId}.`);
    }
    cursors.add(page.nextWorkItemCursor);
    page = await listIntakeOperations({
      workflowId: "supply-intake",
      runId: run.runId,
      runStatus: "completed",
      entityKind: "event",
      workItemCursor: page.nextWorkItemCursor,
      workItemLimit: 200,
    });
    for (const item of page.workItems) {
      workItems.set(item.workItemId, item);
    }
  }
  return {...page, workItems: Array.from(workItems.values())};
}

function orphanCandidateFromWorkItem(
  item: OperationWorkItem
): EventIntakeCandidate[] {
  const intake = recordValue(item.normalizedPayload.intake);
  if (intake?.recordType !== "orphan_event_candidate") return [];
  const candidate = recordValue(intake.candidate);
  if (!candidate || !isOrphanCandidate(candidate)) {
    throw new Error(
      `Event work item ${item.workItemId} has an invalid orphan projection.`
    );
  }
  return [candidate as unknown as EventIntakeCandidate];
}

function mergeOrphanCandidates(
  bridge: EventIntakeBridge,
  orphanCandidates: EventIntakeCandidate[]
): EventIntakeBridge {
  const byId = new Map(bridge.eventCandidates.map((candidate) => [
    candidate.id,
    candidate,
  ]));
  for (const candidate of orphanCandidates) byId.set(candidate.id, candidate);
  const eventCandidates = Array.from(byId.values()).sort((left, right) =>
    left.startDate.localeCompare(right.startDate) ||
    left.title.localeCompare(right.title) ||
    left.id.localeCompare(right.id)
  );
  return {
    ...bridge,
    bridgeSource: "operations",
    summary: {
      ...bridge.summary,
      eventCandidates: eventCandidates.length,
      approvedCandidates: eventCandidates.filter((candidate) =>
        candidate.reviewState === "approved").length,
      candidatesNeedingReview: eventCandidates.filter((candidate) =>
        !["approved", "rejected"].includes(candidate.reviewState)).length,
      orphanCandidates: orphanCandidates.length,
    },
    eventCandidates,
  };
}

function isOrphanCandidate(candidate: Record<string, unknown>): boolean {
  const attribution = recordValue(candidate.attribution);
  const organizerEvidence = recordValue(attribution?.organizerEvidence);
  const match = recordValue(attribution?.match);
  return [
    "candidateId",
    "id",
    "title",
    "category",
    "neighborhood",
    "venue",
    "startDate",
    "time",
    "price",
    "sourceLabel",
    "reviewState",
    "whySinglesFriendly",
    "publicDescription",
    "publicationEligibility",
  ].every((field) => typeof candidate[field] === "string") &&
    candidate.publicationEligibility === "blocked_orphan" &&
    candidate.requiresVerification === true &&
    Array.isArray(candidate.sourceResultIds) &&
    Array.isArray(candidate.warnings) &&
    Array.isArray(candidate.blockerCodes) &&
    attribution?.state === "orphan" &&
    organizerEvidence !== null &&
    match !== null &&
    typeof match.rationale === "string" &&
    match.matchedEntityId === null;
}

function recordValue(
  value: unknown
): Record<string, unknown> | null {
  return value && typeof value === "object" && !Array.isArray(value) ?
    value as Record<string, unknown> :
    null;
}

function stringValue(value: unknown): string | null {
  return typeof value === "string" && value.trim() ? value.trim() : null;
}
