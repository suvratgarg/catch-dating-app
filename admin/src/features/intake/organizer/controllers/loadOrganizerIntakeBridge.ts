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
  const packetEntries = workItems.flatMap(organizerPacketFromWorkItem);
  const packetByEntity = new Map(packetEntries.map((entry) => [
    entry.packet.entityId,
    entry,
  ]));
  const packets = Array.from(packetByEntity.values()).map(({packet}) =>
    workbenchPacketFromProjection(packet));
  const items = Array.from(packetByEntity.values()).map(({item, packet}) =>
    workbenchItemFromPacket(item, packet));
  const hasPackets = packets.length > 0;
  const duplicateKeys = duplicateCandidateKeys(candidates);
  return {
    schemaVersion: 1,
    summary: {
      reviewItems: hasPackets ? items.length : null,
      evidenceReview: hasPackets ?
        packets.reduce((sum, packet) =>
          sum + packet.evidenceSummary.records, 0) :
        null,
      promotionReview: hasPackets ?
        packets.filter((packet) =>
          packet.status === "ready_for_manual_publication_review").length :
        null,
      blocked: hasPackets ?
        items.filter((item) => item.blockers.length > 0).length :
        null,
      approvedPublic: hasPackets ?
        packets.filter((packet) =>
          packet.status === "published" ||
          packet.adminDecision.currentDecision?.decision ===
            "approve_public").length :
        null,
      appDiscoverable: hasPackets ?
        packets.filter((packet) =>
          packet.publicPresence.appVisibility !== "hidden").length :
        null,
      publicationReviewPackets: hasPackets ? packets.length : undefined,
      publicationReviewReady: hasPackets ?
        packets.filter((packet) =>
          packet.status === "ready_for_manual_publication_review").length :
        undefined,
      publicationReviewBlockedByData: hasPackets ?
        packets.filter((packet) => packet.dataBlockers.length > 0).length :
        undefined,
      searchResultCandidates: candidates.length,
      duplicateSearchResultKeys: duplicateKeys.length,
      matchedSearchResultCandidates: candidates.filter((candidate) =>
        candidate.existingEntityMatches.length > 0).length,
    },
    publicationReviewPackets: hasPackets ?
      publicationPacketsWorkbench(packets) :
      emptyPublicationPackets(),
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
    items,
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

function organizerPacketFromWorkItem(
  item: OperationWorkItem
): Array<{
  item: OperationWorkItem;
  packet: Intake.OrganizerPublicationPacketProjection;
}> {
  const intake = recordValue(item.normalizedPayload.intake);
  if (intake?.recordType !== "organizer_publication_packet") return [];
  const packet = recordValue(intake.packet);
  const normalizedPacket = packet ?
    normalizeOrganizerPacketProjection(packet) :
    null;
  if (!normalizedPacket) {
    throw new Error(
      `Organizer work item ${item.workItemId} has an invalid publication packet projection.`
    );
  }
  return [{
    item,
    packet: normalizedPacket,
  }];
}

function normalizeOrganizerPacketProjection(
  packet: Record<string, unknown>
): Intake.OrganizerPublicationPacketProjection | null {
  if (isOrganizerPacketProjection(packet)) {
    return packet as unknown as Intake.OrganizerPublicationPacketProjection;
  }

  const presence = recordValue(packet.publicPresence);
  const decision = recordValue(packet.adminDecision);
  if (!presence || !decision || !hasOnlyKeys(presence, [
    "canonicalPath",
    "claimTargetPath",
    "indexStatus",
    "appVisibility",
    "projectionStatus",
  ]) || !hasOnlyKeys(decision, [
    "allowedDecisions",
    "defaultAppVisibility",
    "currentDecision",
  ])) return null;

  const current = decision.currentDecision === null ?
    null :
    recordValue(decision.currentDecision);
  if (current !== null && !hasOnlyKeys(current, [
    "decision",
    "decidedAt",
    "appVisibility",
  ])) return null;

  const visibility = current ?
    legacyVisibilityForDecision(current.decision) :
    legacyVisibilityWithoutDecision(packet.status, presence.indexStatus);
  if (!visibility ||
    presence.indexStatus !== visibility.indexStatus ||
    (current !== null &&
      current.appVisibility !== presence.appVisibility)) return null;

  const normalized = {
    ...packet,
    publicPresence: {
      ...presence,
      publishStatus: visibility.publishStatus,
    },
    adminDecision: {
      ...decision,
      currentDecision: current ? {
        ...current,
        publishStatus: visibility.publishStatus,
        indexStatus: visibility.indexStatus,
      } : null,
    },
  };
  return isOrganizerPacketProjection(normalized) ?
    normalized as unknown as Intake.OrganizerPublicationPacketProjection :
    null;
}

function legacyVisibilityForDecision(
  decision: unknown
): {publishStatus: string; indexStatus: string} | null {
  if (decision === "approve_public") {
    return {publishStatus: "published", indexStatus: "indexed"};
  }
  if (decision === "hold") {
    return {publishStatus: "draft", indexStatus: "noindex"};
  }
  if (decision === "suppress") {
    return {publishStatus: "suppressed", indexStatus: "noindex"};
  }
  return null;
}

function legacyVisibilityWithoutDecision(
  packetStatus: unknown,
  indexStatus: unknown
): {publishStatus: string; indexStatus: string} | null {
  const publishStatus = packetStatus === "published" ?
    "published" :
    "draft";
  if (publishStatus === "published" && indexStatus === "indexed") {
    return {publishStatus, indexStatus};
  }
  if (publishStatus === "draft" && indexStatus === "noindex") {
    return {publishStatus, indexStatus};
  }
  return null;
}

function isOrganizerPacketProjection(
  packet: Record<string, unknown>
): boolean {
  if (!hasOnlyKeys(packet, [
    "packetId",
    "entityId",
    "canonicalHostId",
    "displayName",
    "status",
    "priority",
    "markets",
    "blockers",
    "dataBlockers",
    "evidenceBlockers",
    "approvalChecklist",
    "evidenceSummary",
    "publicPresence",
    "adminDecision",
    "nextActions",
  ])) return false;
  if (![
    "packetId",
    "entityId",
    "canonicalHostId",
    "displayName",
    "status",
    "priority",
  ].every((field) => nonEmptyString(packet[field]))) return false;
  if (!stringArray(packet.blockers, 40) ||
      !stringArray(packet.dataBlockers, 40) ||
      !stringArray(packet.evidenceBlockers, 40) ||
      !stringArray(packet.nextActions, 12)) return false;
  if (!Array.isArray(packet.markets) || packet.markets.length > 8 ||
      !packet.markets.every((market) => {
        const value = recordValue(market);
        return value !== null &&
          hasOnlyKeys(value, ["slug", "displayName"]) &&
          nonEmptyString(value.slug) &&
          nonEmptyString(value.displayName);
      })) return false;

  const checklist = recordValue(packet.approvalChecklist);
  if (!checklist || !hasOnlyKeys(checklist, [
    "crawlDisabledReviewed",
    "identityReviewed",
    "marketScopeReviewed",
    "mediaRightsReviewed",
    "ownerSafeCopyReviewed",
    "surfaceInventoryReviewed",
  ]) || !Object.values(checklist).every((value) =>
    typeof value === "boolean")) return false;

  const evidence = recordValue(packet.evidenceSummary);
  if (!evidence || !hasOnlyKeys(evidence, [
    "records",
    "manualReportsWithoutArtifacts",
    "unresolvedLocalRefs",
    "missingSurfaceEvidence",
    "rawProviderArtifactRefs",
    "firestoreForbiddenArtifactRefs",
    "riskFlags",
  ]) || ![
    "records",
    "manualReportsWithoutArtifacts",
    "unresolvedLocalRefs",
    "missingSurfaceEvidence",
    "rawProviderArtifactRefs",
    "firestoreForbiddenArtifactRefs",
  ].every((field) => nonNegativeSafeInteger(evidence[field])) ||
    !stringArray(evidence.riskFlags, 12)) return false;

  const presence = recordValue(packet.publicPresence);
  if (!presence || !hasOnlyKeys(presence, [
    "canonicalPath",
    "claimTargetPath",
    "publishStatus",
    "indexStatus",
    "appVisibility",
    "projectionStatus",
  ]) || !nullableString(presence.canonicalPath) ||
    !nullableString(presence.claimTargetPath) ||
    !nonEmptyString(presence.publishStatus) ||
    !nonEmptyString(presence.indexStatus) ||
    !nonEmptyString(presence.appVisibility) ||
    !nonEmptyString(presence.projectionStatus)) return false;

  const decision = recordValue(packet.adminDecision);
  if (!decision || !hasOnlyKeys(decision, [
    "allowedDecisions",
    "defaultAppVisibility",
    "currentDecision",
  ]) || !stringArray(decision.allowedDecisions, 40) ||
    !nonEmptyString(decision.defaultAppVisibility)) return false;
  if (decision.currentDecision !== null) {
    const current = recordValue(decision.currentDecision);
    if (!current || !hasOnlyKeys(current, [
      "decision",
      "publishStatus",
      "indexStatus",
      "decidedAt",
      "appVisibility",
    ]) || ![
      "decision",
      "publishStatus",
      "indexStatus",
      "decidedAt",
      "appVisibility",
    ].every((field) => nonEmptyString(current[field]))) return false;
  }
  return !JSON.stringify(packet).toLocaleLowerCase()
    .includes("providerpayload");
}

function workbenchPacketFromProjection(
  packet: Intake.OrganizerPublicationPacketProjection
): Intake.OrganizerPublicationReviewPacket {
  const markets = packet.markets.map((market) => ({
    marketSlug: market.slug,
    displayName: market.displayName,
    countryCode: "",
    eventFilter: {
      mode: "eventCity",
      citySlug: market.slug,
    },
  }));
  const currentDecision = packet.adminDecision.currentDecision;
  const resolvedArtifactRefs = Math.max(
    0,
    packet.evidenceSummary.records -
    packet.evidenceSummary.manualReportsWithoutArtifacts -
    packet.evidenceSummary.unresolvedLocalRefs -
    packet.evidenceSummary.missingSurfaceEvidence
  );
  return {
    ...packet,
    taskType: "publication_review",
    recommendedAction: packet.nextActions[0] ?? "review_publication_packet",
    identity: {
      entityKind: "organizer",
      aliases: [],
      activity: {
        primaryActivityKind: null,
        supportedActivityKinds: [],
        confidence: "unavailable_in_live_projection",
        derivedFromSurfaceIds: [],
      },
      geography: {
        scopeKind: markets.length > 1 ? "multi_market" : "single_market",
        primaryMarketSlug: markets[0]?.marketSlug ?? null,
        markets,
        countryCodes: [],
      },
    },
    publicPresence: {
      ...packet.publicPresence,
      legacyPaths: [],
      publishStatus: packet.publicPresence.publishStatus,
    },
    publicDraft: {
      headline: null,
      summary: null,
      sourceSummary: null,
      formats: [],
      missingEvidence: [],
    },
    surfaceSummary: {
      surfaces: packet.evidenceSummary.records,
      active: 0,
      ambiguous: packet.evidenceSummary.riskFlags.includes(
        "surface_ambiguous"
      ) ? 1 : 0,
      rejected: packet.evidenceSummary.riskFlags.includes(
        "surface_rejected"
      ) ? 1 : 0,
      historical: 0,
      primarySurfaceIds: [],
      eventSourceSurfaceIds: [],
      socialProfileSurfaceIds: [],
      platforms: {},
      normalizedKeys: [],
    },
    evidenceSummary: {
      ...packet.evidenceSummary,
      resolvedArtifactRefs,
      byStatus: {},
      byType: {},
    },
    evidenceReview: {
      totalRecords: packet.evidenceSummary.records,
      shownRecords: 0,
      truncated: packet.evidenceSummary.records > 0,
      artifactBackedRecords: resolvedArtifactRefs,
      manualReportsWithoutArtifacts:
        packet.evidenceSummary.manualReportsWithoutArtifacts,
      unresolvedLocalRefs: packet.evidenceSummary.unresolvedLocalRefs,
      missingSurfaceEvidence:
        packet.evidenceSummary.missingSurfaceEvidence,
      externalUrlRefs: 0,
      rawProviderArtifactRefs:
        packet.evidenceSummary.rawProviderArtifactRefs,
      records: [],
    },
    evidenceRecordIds: [],
    gates: [],
    adminDecision: {
      ...packet.adminDecision,
      currentDecision: currentDecision ? {
        ...currentDecision,
        reviewer: "operations_projection",
        decisionBatchId: "",
        sourceFile: "",
      } : null,
      command: "",
    },
  };
}

function workbenchItemFromPacket(
  item: OperationWorkItem,
  packet: Intake.OrganizerPublicationPacketProjection
): Intake.OrganizerIntakeItem {
  const reviewDecision = packet.adminDecision.currentDecision;
  const riskFlags = new Set(packet.evidenceSummary.riskFlags);
  return {
    entityId: packet.entityId,
    displayName: packet.displayName,
    priority: packet.priority,
    taskType: "publication_review",
    reviewStatus: item.primaryStage === "verify" ?
      "needs_review" :
      item.primaryStage === "resolve" ? "needs_attention" :
        item.primaryStage,
    relationshipToCatch: "source_backed",
    canonicalPath: packet.publicPresence.canonicalPath,
    legacyPaths: [],
    markets: packet.markets.map((market) => ({
      marketSlug: market.slug,
      displayName: market.displayName,
      countryCode: "",
      eventFilter: {mode: "eventCity", citySlug: market.slug},
    })),
    blockers: Array.from(new Set([
      ...packet.blockers,
      ...packet.dataBlockers,
      ...packet.evidenceBlockers,
    ])),
    gates: [],
    surfaceSummary: {
      total: packet.evidenceSummary.records,
      active: 0,
      ambiguous: riskFlags.has("surface_ambiguous") ? 1 : 0,
      candidate: riskFlags.has("surface_candidate") ? 1 : 0,
      rejected: riskFlags.has("surface_rejected") ? 1 : 0,
      platforms: {},
    },
    surfaces: [],
    promotionPolicy: {
      adminApprovalIndexesWebsite: true,
      adminApprovalPublishesWebsite: true,
      appVisibilityAfterPublicApproval:
        packet.adminDecision.defaultAppVisibility,
    },
    reviewDecision: reviewDecision ? {
      ...reviewDecision,
      reviewer: "operations_projection",
      decisionBatchId: "",
      sourceFile: "",
    } : null,
    projectionStatus: packet.publicPresence.projectionStatus,
    publishStatus: packet.publicPresence.publishStatus,
    indexStatus: packet.publicPresence.indexStatus,
    appVisibility: packet.publicPresence.appVisibility,
    claimTargetPath: packet.publicPresence.claimTargetPath,
    curation: null,
    decisionCommands: {
      approvePublic: "",
      hold: "",
      suppress: "",
    },
  };
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

function publicationPacketsWorkbench(
  packets: Intake.OrganizerPublicationReviewPacket[]
): OrganizerWorkbenchPublicationReviewPackets {
  return {
    schemaVersion: 1,
    summary: {
      packets: packets.length,
      readyForManualPublicationReview: packets.filter((packet) =>
        packet.status === "ready_for_manual_publication_review").length,
      blockedByData: packets.filter((packet) =>
        packet.dataBlockers.length > 0).length,
      published: packets.filter((packet) =>
        packet.status === "published").length,
      suppressed: packets.filter((packet) =>
        packet.status === "suppressed").length,
      held: packets.filter((packet) =>
        packet.status === "held").length,
      evidenceRecords: packets.reduce((sum, packet) =>
        sum + packet.evidenceSummary.records, 0),
      manualReportsWithoutArtifacts: packets.reduce((sum, packet) =>
        sum + packet.evidenceSummary.manualReportsWithoutArtifacts, 0),
      unresolvedEvidenceRefs: packets.reduce((sum, packet) =>
        sum + packet.evidenceSummary.unresolvedLocalRefs, 0),
      missingSurfaceEvidence: packets.reduce((sum, packet) =>
        sum + packet.evidenceSummary.missingSurfaceEvidence, 0),
      packetsByStatus: countBy(packets, (packet) => packet.status),
      packetsByTaskType: countBy(packets, (packet) => packet.taskType),
    },
    guardrails: [],
    packets,
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

function hasOnlyKeys(
  value: Record<string, unknown>,
  expected: string[]
): boolean {
  const keys = Object.keys(value).sort();
  return keys.length === expected.length &&
    keys.every((key, index) => key === [...expected].sort()[index]);
}

function nonEmptyString(value: unknown): value is string {
  return typeof value === "string" && value.length > 0 && value.length <= 500;
}

function nullableString(value: unknown): value is string | null {
  return value === null || nonEmptyString(value);
}

function stringArray(value: unknown, maxItems: number): value is string[] {
  return Array.isArray(value) && value.length <= maxItems &&
    value.every(nonEmptyString);
}

function nonNegativeSafeInteger(value: unknown): value is number {
  return Number.isSafeInteger(value) && Number(value) >= 0;
}

function stringValue(value: unknown): string | null {
  return typeof value === "string" && value.length > 0 ? value : null;
}
