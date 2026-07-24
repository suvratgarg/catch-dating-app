import {listIntakeOperations} from
  "../../../../shared/api/adminApi";
import {launchMarketSlugs} from
  "../../../../shared/config/launchMarkets";
import type {
  AdminListIntakeOperationsResponse,
  OperationRun,
  OperationWorkItem,
} from "../../../../shared/operations/operationsTypes";
import type * as Intake from "../types/organizerIntakeTypes";

export type OrganizerIntakeWorkbenchBridge = Pick<
  Intake.OrganizerIntakeBridge,
  "schemaVersion" |
  "summary" |
  "publicationReviewPackets" |
  "searchCandidates" |
  "items"
>;

export interface OrganizerIntakeLoadResult {
  source: "firestore" | "sample";
  workbench: OrganizerIntakeWorkbenchBridge;
  diagnosticsBridge: Intake.OrganizerIntakeBridge | null;
}

export async function loadOrganizerIntakeBridge():
Promise<OrganizerIntakeLoadResult> {
  if (import.meta.env.VITE_ADMIN_DATA_MODE !== "live") {
    const {loadSampleOrganizerIntakeBridge} = await import(
      "../api/sampleOrganizerIntakeRepository"
    );
    const bridge = await loadSampleOrganizerIntakeBridge();
    return {
      source: "sample",
      workbench: bridge,
      diagnosticsBridge: bridge,
    };
  }
  return loadLiveOrganizerIntake();
}

async function loadLiveOrganizerIntake(): Promise<OrganizerIntakeLoadResult> {
  const inventory = await listIntakeOperations({
    workflowId: "supply-intake",
    runStatus: "completed",
    entityKind: "organizer",
    runLimit: 50,
    workItemLimit: 1,
  });
  const runs = latestRunPerLaunchMarket(inventory.runs);
  const pages = await Promise.all(runs.map(loadOrganizerRun));
  const workItems = pages.flatMap((page) => page.workItems);
  const candidates = workItems.flatMap(organizerCandidateFromWorkItem);
  const duplicateKeys = duplicateCandidateKeys(candidates);
  return {
    source: "firestore",
    diagnosticsBridge: null,
    workbench: {
      schemaVersion: 1,
      summary: {
        reviewItems: 0,
        evidenceReview: 0,
        promotionReview: 0,
        blocked: workItems.filter((item) =>
          item.blockerCodes.length > 0).length,
        approvedPublic: 0,
        appDiscoverable: 0,
        searchResultCandidates: candidates.length,
        duplicateSearchResultKeys: duplicateKeys.length,
        matchedSearchResultCandidates: candidates.filter((candidate) =>
          candidate.existingEntityMatches.length > 0).length,
      },
      publicationReviewPackets: emptyPublicationPackets(),
      searchCandidates: {
        summary: {
          batches: new Set(candidates.map((candidate) =>
            candidate.batchId)).size,
          results: candidates.length,
          candidates: candidates.length,
          matchedExistingEntities: candidates.filter((candidate) =>
            candidate.existingEntityMatches.length > 0).length,
          duplicateNormalizedKeys: duplicateKeys.length,
          platforms: countBy(candidates, (candidate) => candidate.platform),
        },
        generatedFrom: {
          batches: Array.from(new Set(candidates.map((candidate) =>
            candidate.batchId))).sort(),
          dedupeIndexGeneratedAt: inventory.generatedAt,
        },
        candidates,
        duplicateKeys,
        warnings: [],
        errors: [],
        commands: {
          capture: "Managed by the Supply Intake worker.",
          curateSurface: "adminRecordOrganizerCuration",
          ingest: "Managed by the Supply Intake worker.",
          normalize: "Managed by the Supply Intake worker.",
        },
      },
      items: [],
    },
  };
}

function latestRunPerLaunchMarket(runs: OperationRun[]): OperationRun[] {
  const latest = new Map<string, OperationRun>();
  for (const run of runs) {
    const market = stringValue(run.scope.market);
    if (run.scope.intakeScope !== "organizer" ||
      !market || !launchMarketSlugs.includes(
      market as typeof launchMarketSlugs[number]
    ) || latest.has(market)) continue;
    latest.set(market, run);
  }
  return Array.from(launchMarketSlugs)
    .map((market) => latest.get(market))
    .filter((run): run is OperationRun => Boolean(run));
}

async function loadOrganizerRun(
  run: OperationRun
): Promise<AdminListIntakeOperationsResponse> {
  let page = await listIntakeOperations({
    workflowId: "supply-intake",
    runId: run.runId,
    runStatus: "completed",
    entityKind: "organizer",
    workItemLimit: 200,
  });
  const workItems = new Map(page.workItems.map((item) => [
    item.workItemId,
    item,
  ]));
  const cursors = new Set<string>();
  while (page.nextWorkItemCursor) {
    if (cursors.has(page.nextWorkItemCursor)) {
      throw new Error(
        `Organizer Intake pagination stalled for run ${run.runId}.`
      );
    }
    cursors.add(page.nextWorkItemCursor);
    page = await listIntakeOperations({
      workflowId: "supply-intake",
      runId: run.runId,
      runStatus: "completed",
      entityKind: "organizer",
      workItemCursor: page.nextWorkItemCursor,
      workItemLimit: 200,
    });
    for (const item of page.workItems) {
      workItems.set(item.workItemId, item);
    }
  }
  return {...page, workItems: Array.from(workItems.values())};
}

function organizerCandidateFromWorkItem(
  item: OperationWorkItem
): Intake.OrganizerSearchCandidate[] {
  const intake = recordValue(item.normalizedPayload.intake);
  if (intake?.recordType !== "organizer_search_candidate") return [];
  const candidate = recordValue(intake.candidate);
  if (!candidate || !isOrganizerCandidate(candidate)) {
    throw new Error(
      `Organizer work item ${item.workItemId} has an invalid candidate projection.`
    );
  }
  return [candidate as unknown as Intake.OrganizerSearchCandidate];
}

function isOrganizerCandidate(
  candidate: Record<string, unknown>
): boolean {
  return [
    "candidateId",
    "batchId",
    "resultId",
    "title",
    "url",
    "canonicalUrl",
    "platform",
    "surfaceKind",
    "reviewAction",
  ].every((field) => typeof candidate[field] === "string") &&
    Number.isSafeInteger(candidate.rank) &&
    recordValue(candidate.queryIntent) !== null &&
    recordValue(candidate.suggestedSurface) !== null &&
    Array.isArray(candidate.existingEntityMatches) &&
    Array.isArray(candidate.diagnostics);
}

function duplicateCandidateKeys(
  candidates: Intake.OrganizerSearchCandidate[]
) {
  const byKey = new Map<string, string[]>();
  for (const candidate of candidates) {
    if (!candidate.normalizedKey) continue;
    const ids = byKey.get(candidate.normalizedKey) ?? [];
    ids.push(candidate.candidateId);
    byKey.set(candidate.normalizedKey, ids);
  }
  return Array.from(byKey)
    .filter(([, candidateIds]) => candidateIds.length > 1)
    .map(([normalizedKey, candidateIds]) => ({
      normalizedKey,
      candidateIds: candidateIds.sort(),
    }))
    .sort((left, right) =>
      left.normalizedKey.localeCompare(right.normalizedKey));
}

function emptyPublicationPackets():
Intake.OrganizerPublicationReviewPackets {
  return {
    schemaVersion: 1,
    summary: {
      packets: 0,
      readyForManualPublicationReview: 0,
      blockedByData: 0,
      published: 0,
      suppressed: 0,
      held: 0,
      evidenceRecords: 0,
      manualReportsWithoutArtifacts: 0,
      unresolvedEvidenceRefs: 0,
      missingSurfaceEvidence: 0,
      packetsByStatus: {},
      packetsByTaskType: {},
    },
    guardrails: [],
    packets: [],
  };
}

function countBy<T>(
  values: T[],
  keyFor: (value: T) => string
): Record<string, number> {
  const counts: Record<string, number> = {};
  for (const value of values) {
    const key = keyFor(value);
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return counts;
}

function recordValue(value: unknown): Record<string, unknown> | null {
  return value && typeof value === "object" && !Array.isArray(value) ?
    value as Record<string, unknown> : null;
}

function stringValue(value: unknown): string | null {
  return typeof value === "string" && value.length > 0 ? value : null;
}
