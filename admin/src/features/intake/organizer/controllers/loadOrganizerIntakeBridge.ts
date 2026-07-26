import {listIntakeOperations} from
  "../../../../shared/api/adminApi";
import {launchMarketSlugs} from
  "../../../../shared/config/launchMarkets";
import type {
  AdminListIntakeOperationsResponse,
  OperationRun,
  OperationWorkItem,
  OrganizerDraftLink,
} from "../../../../shared/operations/operationsTypes";
import type * as Intake from "../types/organizerIntakeTypes";

type NullableLiveSummaryFields =
  | "reviewItems"
  | "evidenceReview"
  | "promotionReview"
  | "blocked"
  | "approvedPublic"
  | "appDiscoverable";

export type OrganizerIntakeWorkbenchBridge = Omit<
  Pick<
    Intake.OrganizerIntakeBridge,
    | "schemaVersion"
    | "summary"
    | "publicationReviewPackets"
    | "searchCandidates"
    | "items"
  >,
  "summary" | "publicationReviewPackets"
> & {
  summary: Omit<
    Intake.OrganizerIntakeSummary,
    NullableLiveSummaryFields
  > & Record<NullableLiveSummaryFields, number | null>;
  publicationReviewPackets: OrganizerWorkbenchPublicationReviewPackets;
};

type NullablePublicationPacketSummaryFields =
  | "packets"
  | "readyForManualPublicationReview"
  | "blockedByData"
  | "published"
  | "suppressed"
  | "held"
  | "evidenceRecords"
  | "manualReportsWithoutArtifacts"
  | "unresolvedEvidenceRefs"
  | "missingSurfaceEvidence";

type OrganizerWorkbenchPublicationReviewPackets = Omit<
  Intake.OrganizerPublicationReviewPackets,
  "summary"
> & {
  summary: Omit<
    Intake.OrganizerPublicationReviewPackets["summary"],
    NullablePublicationPacketSummaryFields
  > & Record<NullablePublicationPacketSummaryFields, number | null>;
};

export interface OrganizerIntakeAvailability {
  searchCandidates: boolean;
  publicationPackets: boolean;
  canonicalItems: boolean;
  diagnostics: boolean;
  discoveryCandidateCount: number;
  runIds: string[];
}

export interface OrganizerIntakeLoadResult {
  source: "firestore" | "sample";
  workbench: OrganizerIntakeWorkbenchBridge;
  diagnosticsBridge: Intake.OrganizerIntakeBridge | null;
  availability: OrganizerIntakeAvailability;
}

export async function loadOrganizerIntakeBridge():
Promise<OrganizerIntakeLoadResult> {
  const inventory = await listIntakeOperations({
    workflowId: "supply-intake",
    runStatus: "completed",
    entityKind: "organizer",
    runLimit: 25,
    workItemLimit: 1,
  });
  const runs = latestRunPerLaunchMarket(inventory.runs);
  const pages = await Promise.all(runs.map(loadOrganizerRun));
  const workItems = pages.flatMap((page) => page.workItems);
  const draftLinks = pages.flatMap(organizerDraftLinksOf);
  const workbench = organizerWorkbenchFromOperations(
    inventory,
    workItems,
    draftLinks
  );
  const diagnosticsBridge = null;
  return {
    source: inventory.source === "firestore" ? "firestore" : "sample",
    diagnosticsBridge,
    availability: organizerAvailabilityFromOperations(
      runs,
      workItems,
      diagnosticsBridge
    ),
    workbench,
  };
}

export function organizerWorkbenchFromOperations(
  inventory: AdminListIntakeOperationsResponse,
  workItems: OperationWorkItem[],
  organizerDraftLinks: OrganizerDraftLink[] = organizerDraftLinksOf(inventory)
): OrganizerIntakeWorkbenchBridge {
  const draftLinkByWorkItem = new Map(organizerDraftLinks.map((link) => [
    link.workItemId,
    link,
  ]));
  const candidates = workItems.flatMap((item) =>
    organizerCandidateFromWorkItem(item, draftLinkByWorkItem));
  const duplicateKeys = duplicateCandidateKeys(candidates);
  return {
    schemaVersion: 1,
    summary: {
      reviewItems: null,
      evidenceReview: null,
      promotionReview: null,
      blocked: null,
      approvedPublic: null,
      appDiscoverable: null,
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
  };
}

function organizerAvailabilityFromOperations(
  runs: OperationRun[],
  workItems: OperationWorkItem[],
  diagnosticsBridge: Intake.OrganizerIntakeBridge | null
): OrganizerIntakeAvailability {
  const recordTypes = new Set(workItems.flatMap((item) => {
    const intake = recordValue(item.normalizedPayload.intake);
    return typeof intake?.recordType === "string" ? [intake.recordType] : [];
  }));
  const discoveryCandidateCount = workItems.filter((item) => {
    const intake = recordValue(item.normalizedPayload.intake);
    return intake?.recordType === "organizer_search_candidate";
  }).length;
  const hasPublicationPackets =
    recordTypes.has("organizer_publication_packet");
  return {
    searchCandidates:
      recordTypes.has("organizer_search_candidate"),
    publicationPackets: hasPublicationPackets,
    canonicalItems: hasPublicationPackets,
    diagnostics: diagnosticsBridge !== null,
    discoveryCandidateCount,
    runIds: runs.map((run) => run.runId),
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
  const organizerDraftLinks = new Map(
    organizerDraftLinksOf(page).map((link) => [link.workItemId, link])
  );
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
    for (const link of organizerDraftLinksOf(page)) {
      organizerDraftLinks.set(link.workItemId, link);
    }
  }
  return {
    ...page,
    workItems: Array.from(workItems.values()),
    organizerDraftLinks: Array.from(organizerDraftLinks.values()),
  };
}

function organizerDraftLinksOf(
  response: AdminListIntakeOperationsResponse
): OrganizerDraftLink[] {
  return response.organizerDraftLinks ?? [];
}

function organizerCandidateFromWorkItem(
  item: OperationWorkItem,
  draftLinkByWorkItem: Map<string, OrganizerDraftLink>
): Intake.OrganizerSearchCandidate[] {
  const intake = recordValue(item.normalizedPayload.intake);
  if (intake?.recordType !== "organizer_search_candidate") return [];
  const candidate = recordValue(intake.candidate);
  if (!candidate || !isOrganizerCandidate(candidate)) {
    throw new Error(
      `Organizer work item ${item.workItemId} has an invalid candidate projection.`
    );
  }
  const draftLink = draftLinkByWorkItem.get(item.workItemId);
  return [{
    ...(candidate as unknown as Omit<
      Intake.OrganizerSearchCandidate,
      "workItemId" | "draftLink"
    >),
    workItemId: item.workItemId,
    fieldProvenance: item.fieldProvenance,
    ...(draftLink ? {draftLink} : {}),
  }];
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
OrganizerWorkbenchPublicationReviewPackets {
  return {
    schemaVersion: 1,
    summary: {
      packets: null,
      readyForManualPublicationReview: null,
      blockedByData: null,
      published: null,
      suppressed: null,
      held: null,
      evidenceRecords: null,
      manualReportsWithoutArtifacts: null,
      unresolvedEvidenceRefs: null,
      missingSurfaceEvidence: null,
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
