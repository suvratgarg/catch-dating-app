import {hashValue, shortHash} from "../../platform/canonical-json.mjs";
import {
  assertWorkItem as assertPlatformWorkItem,
  MAX_WORK_ITEMS_PER_RUN,
  safeId,
  uniqueSorted,
} from "../../platform/contracts.mjs";
import {invariant} from "../../platform/errors.mjs";
import {
  LegacyIntakeArtifactAdapter,
  organizerPacketSupportsMarket,
  stripArtifactData,
} from "./adapters/legacy-artifacts.mjs";
import {loadSourceProfiles} from "./sources/index.mjs";
import {
  SUPPLY_INTAKE_ENTITY_KINDS,
  SUPPLY_INTAKE_LIFECYCLE_SEMANTICS,
  SUPPLY_INTAKE_LIFECYCLE_STATUSES,
  SUPPLY_INTAKE_PRIMARY_STAGES,
  SUPPLY_INTAKE_TRANSITIONS,
} from "./definition.mjs";

export const MAX_SUPPLY_INTAKE_WORK_ITEMS_PER_RUN = MAX_WORK_ITEMS_PER_RUN;
export const SUPPLY_INTAKE_WORKFLOW_ID = "supply-intake";
export const SUPPLY_INTAKE_WORKFLOW_VERSION = "0.1.0";
const SUPPLY_INTAKE_STALE_AFTER_HOURS = 168;

export class SupplyIntakeWorkflow {
  constructor({
    repoRoot,
    adapter = new LegacyIntakeArtifactAdapter({repoRoot}),
    sourceProfilesLoader = loadSourceProfiles,
  } = {}) {
    this.workflowId = SUPPLY_INTAKE_WORKFLOW_ID;
    this.version = SUPPLY_INTAKE_WORKFLOW_VERSION;
    this.primaryStages = SUPPLY_INTAKE_PRIMARY_STAGES;
    this.lifecycleStatuses = SUPPLY_INTAKE_LIFECYCLE_STATUSES;
    this.lifecycleSemantics = SUPPLY_INTAKE_LIFECYCLE_SEMANTICS;
    this.entityKinds = SUPPLY_INTAKE_ENTITY_KINDS;
    this.allowedTransitions = SUPPLY_INTAKE_TRANSITIONS;
    this.adapter = adapter;
    this.sourceProfilesLoader = sourceProfilesLoader;
  }

  async createPlan({market = "mumbai", through, now}) {
    invariant(/^[a-z][a-z0-9-]{1,49}$/.test(market), "INVALID_MARKET", "Market must be a lowercase slug.", {market});
    invariant(/^\d{4}-\d{2}-\d{2}$/.test(through ?? ""), "INVALID_THROUGH", "--through YYYY-MM-DD is required.", {through});
    const generatedAt = new Date(now).toISOString();
    const profiles = await this.sourceProfilesLoader();
    const artifactSnapshotWithData = await this.adapter.snapshot({market});
    assertEventBridgeCompatibility(artifactSnapshotWithData, {
      market,
      generatedAt,
      staleAfterHours: SUPPLY_INTAKE_STALE_AFTER_HOURS,
    });
    const artifactSnapshot = stripArtifactData(artifactSnapshotWithData, {market});
    const plannedItems = plannedWorkItemCount(artifactSnapshot, profiles.length);
    invariant(
      plannedItems <= MAX_SUPPLY_INTAKE_WORK_ITEMS_PER_RUN,
      "RUN_SHARD_REQUIRED",
      `Supply Intake plans are limited to ${MAX_SUPPLY_INTAKE_WORK_ITEMS_PER_RUN} work items; split the source scope before running.`,
      {plannedItems, maximum: MAX_SUPPLY_INTAKE_WORK_ITEMS_PER_RUN}
    );
    const sourceProfiles = profiles.map(snapshotSourceProfile);
    const policy = {
      staleAfterHours: SUPPLY_INTAKE_STALE_AFTER_HOURS,
      randomAuditBasisPoints: 10_000,
      autoPublicationEnabled: false,
      editorialSourcesDiscoveryOnly: true,
    };
    const promotionPolicyHash = hashValue({workflowPolicy: policy, sourceProfiles});
    const basis = {
      schemaVersion: 1,
      workflowId: this.workflowId,
      workflowVersion: this.version,
      market,
      through,
      mode: "shadow",
      workflowContract: {
        primaryStages: [...this.primaryStages],
        lifecycleStatuses: [...this.lifecycleStatuses],
        lifecycleSemantics: copyLifecycleSemantics(
          this.lifecycleSemantics
        ),
        entityKinds: [...this.entityKinds],
        allowedTransitions: this.allowedTransitions,
      },
      artifactSnapshot,
      sourceProfiles,
      policy,
      promotionPolicyHash,
      capabilities: {network: false, modelCalls: false, publicWrites: false, ruleDeployment: false},
    };
    const basisHash = hashValue(basis);
    const plan = {
      ...basis,
      planId: `supply-${market}-${through}-${basisHash.slice(0, 12)}`,
      basisHash,
      generatedAt,
      budgets: {
        workItems: Math.max(1_000, plannedItems),
        networkRequests: 0,
        modelCalls: 0,
        modelInputTokens: 0,
        modelOutputTokens: 0,
        modelCostMicros: 0,
        publicWrites: 0,
      },
      guardrails: [
        "The plan reads reviewed local artifacts only.",
        "No network, model, public write, scheduler, or rule deployment capability is granted.",
        "Editorial sources are discovery-only until an official source is resolved.",
      ],
    };
    return finalizePlan(plan);
  }

  createReconciliationPlan(sourceRun, {now}) {
    invariant(sourceRun?.workflowId === this.workflowId,
      "INVALID_RECONCILIATION_SOURCE",
      "A Supply Intake reconciliation must start from a Supply Intake run.");
    this.assertPlan(sourceRun.plan);
    invariant(sourceRun.status === "completed" &&
      typeof sourceRun.inventoryHash === "string",
    "INVALID_RECONCILIATION_SOURCE",
    "Reconciliation requires an immutable completed source snapshot.");
    const generatedAt = new Date(now).toISOString();
    const window = generatedAt.slice(0, 10);
    const reconciliation = {
      schemaVersion: 1,
      kind: "reconciliation_snapshot",
      sourceRunId: sourceRun.runId,
      sourcePlanHash: sourceRun.planHash,
      sourceInventoryHash: sourceRun.inventoryHash,
      window,
    };
    const basisHash = hashValue({
      workflowId: this.workflowId,
      workflowVersion: this.version,
      reconciliation,
    });
    const {
      planContentHash: _sourcePlanContentHash,
      reconciliation: _priorReconciliation,
      ...sourcePlan
    } = sourceRun.plan;
    return finalizePlan({
      ...sourcePlan,
      planId: `supply-reconcile-${window}-${basisHash.slice(0, 12)}`,
      basisHash,
      generatedAt,
      reconciliation,
      budgets: {...sourceRun.plan.budgets},
      guardrails: [
        ...sourceRun.plan.guardrails,
        "Reconciliation creates a new immutable run snapshot; it never edits its source run.",
      ],
    });
  }

  assertPlan(plan) {
    invariant(plan?.schemaVersion === 1, "INVALID_PLAN", "Unsupported supply-intake plan version.");
    invariant(plan.workflowId === this.workflowId, "INVALID_PLAN", "Plan belongs to another workflow.");
    invariant(plan.workflowVersion === this.version, "INVALID_PLAN", "Plan workflow version is stale.");
    invariant(plan.mode === "shadow", "UNSAFE_MODE", "Only shadow mode is supported.");
    invariant(
      hashValue(plan.workflowContract) === hashValue({
        primaryStages: this.primaryStages,
        lifecycleStatuses: this.lifecycleStatuses,
        lifecycleSemantics: this.lifecycleSemantics,
        entityKinds: this.entityKinds,
        allowedTransitions: this.allowedTransitions,
      }),
      "INVALID_STAGE_CONTRACT",
      "Supply Intake workflow contract is missing or stale."
    );
    invariant(
      !plan.capabilities.network &&
        !plan.capabilities.modelCalls &&
        !plan.capabilities.publicWrites &&
        !plan.capabilities.ruleDeployment,
      "UNSAFE_CAPABILITY",
      "Shadow plan grants an unsafe capability."
    );
    invariant(
      plan.promotionPolicyHash === hashValue({workflowPolicy: plan.policy, sourceProfiles: plan.sourceProfiles}),
      "INVALID_PLAN",
      "Plan promotion policy snapshot is stale or invalid."
    );
    if (plan.reconciliation !== undefined) {
      invariant(
        plan.reconciliation?.schemaVersion === 1 &&
          plan.reconciliation.kind === "reconciliation_snapshot" &&
          typeof plan.reconciliation.sourceRunId === "string" &&
          typeof plan.reconciliation.sourcePlanHash === "string" &&
          typeof plan.reconciliation.sourceInventoryHash === "string" &&
          /^\d{4}-\d{2}-\d{2}$/.test(plan.reconciliation.window ?? "") &&
          plan.reconciliation.window === plan.generatedAt.slice(0, 10) &&
          plan.basisHash === hashValue({
            workflowId: this.workflowId,
            workflowVersion: this.version,
            reconciliation: plan.reconciliation,
          }),
        "INVALID_RECONCILIATION_PLAN",
        "Reconciliation plan lineage is missing or stale."
      );
    }
    const plannedItems = plannedWorkItemCount(
      plan.artifactSnapshot,
      Array.isArray(plan.sourceProfiles) ? plan.sourceProfiles.length : NaN
    );
    invariant(
      plannedItems <= MAX_SUPPLY_INTAKE_WORK_ITEMS_PER_RUN,
      "RUN_SHARD_REQUIRED",
      `Supply Intake plans are limited to ${MAX_SUPPLY_INTAKE_WORK_ITEMS_PER_RUN} work items; split the source scope before running.`,
      {plannedItems, maximum: MAX_SUPPLY_INTAKE_WORK_ITEMS_PER_RUN}
    );
    invariant(
      Number.isSafeInteger(plan.budgets?.workItems) &&
        plan.budgets.workItems >= plannedItems &&
        plan.budgets.workItems <= MAX_SUPPLY_INTAKE_WORK_ITEMS_PER_RUN,
      "RUN_SHARD_REQUIRED",
      "The plan work-item budget must cover its inventory without exceeding the canonical shard limit.",
      {
        plannedItems,
        workItemBudget: plan.budgets?.workItems ?? null,
        maximum: MAX_SUPPLY_INTAKE_WORK_ITEMS_PER_RUN,
      }
    );
    invariant(typeof plan.planId === "string" && plan.planId.includes(plan.basisHash.slice(0, 12)), "INVALID_PLAN", "Plan id is not bound to its basis hash.");
    const {planContentHash, generatedAt: _generatedAt, ...content} = plan;
    invariant(planContentHash === hashValue(content), "INVALID_PLAN", "Plan content hash is stale or invalid.");
    return plan;
  }

  assertWorkItem(item) {
    assertPlatformWorkItem(item);
    invariant(item.workflowId === this.workflowId, "INVALID_WORK_ITEM",
      "Work item belongs to another workflow.");
    invariant(this.primaryStages.includes(item.primaryStage),
      "INVALID_WORK_ITEM", "Work item has an invalid Supply Intake stage.");
    invariant(this.lifecycleStatuses.includes(item.lifecycleStatus),
      "INVALID_WORK_ITEM",
      "Work item has an invalid Supply Intake lifecycle status.");
    invariant(this.entityKinds.includes(item.entityKind),
      "INVALID_WORK_ITEM",
      "Work item has an invalid Supply Intake entity kind.");
    return item;
  }

  async project(plan, {runId, now}) {
    this.assertPlan(plan);
    const artifacts = await this.adapter.reload(plan.artifactSnapshot);
    const profiles = await this.sourceProfilesLoader();
    const plannedProfileHashes = new Map(plan.sourceProfiles.map((profile) => [profile.sourceProfileId, profile.versionHash]));
    for (const profile of profiles) {
      invariant(
        plannedProfileHashes.get(profile.sourceProfileId) === hashValue(profile),
        "ARTIFACT_DRIFT",
        `Source profile ${profile.sourceProfileId} changed after planning.`,
        {sourceProfileId: profile.sourceProfileId}
      );
    }
    const items = [];
    const eventBridge = artifacts.eventIntakeBridge;
    if (eventBridge?.data) {
      const bridge = eventBridge.data;
      for (const profile of bridge.sourceProfiles ?? []) {
        items.push(workItemForLegacySourceProfile(profile, {runId, now, market: plan.market, artifact: eventBridge}));
      }
      for (const result of bridge.sourceResults ?? []) {
        items.push(workItemForSourceResult(result, {runId, now, market: plan.market, artifact: eventBridge}));
      }
      for (const event of bridge.eventCandidates ?? []) {
        if (event.startDate && event.startDate > plan.through) continue;
        items.push(workItemForEvent(event, {runId, now, market: plan.market, artifact: eventBridge}));
      }
    }
    for (const profile of profiles) {
      items.push(workItemForOperationsSourceProfile(profile, {runId, now, market: plan.market}));
    }
    const organizerArtifact = artifacts.organizerPublicationPackets;
    for (const packet of organizerArtifact?.data?.packets ?? []) {
      if (!organizerPacketSupportsMarket(packet, plan.market)) continue;
      items.push(workItemForOrganizer(packet, {runId, now, market: plan.market, artifact: organizerArtifact}));
    }
    return dedupeItems(items).sort((left, right) => left.workItemId.localeCompare(right.workItemId));
  }

  review(item, {now}) {
    if (item.entityKind === "event") return reviewEvent(item, now);
    if (item.entityKind === "organizer") return reviewOrganizer(item, now);
    if (item.entityKind === "source_result") return reviewSourceResult(item, now);
    return reviewSourceProfile(item, now);
  }

  async promotionEligibility(item, {run} = {}) {
    const blockers = [];
    if (!["event", "organizer"].includes(item.entityKind)) {
      blockers.push("entity_kind_not_publishable");
    }
    if (item.blockers.length > 0) blockers.push("work_item_has_blockers");
    if (item.owner === "human" || item.taskFlags.includes("human_review_required")) {
      blockers.push("human_review_required");
    }
    const profile = run?.plan?.sourceProfiles?.find((candidate) =>
      candidate.sourceProfileId === item.source?.sourceProfileId);
    if (item.entityKind === "event") {
      if (!profile) blockers.push("source_policy_snapshot_missing");
      if (profile?.publication?.autoEligible !== true) {
        blockers.push("source_not_auto_eligible");
      }
      if (profile?.publication?.discoveryOnly || profile?.publication?.requiresOfficialSource) {
        blockers.push("official_source_policy_required");
      }
    }
    return {eligible: blockers.length === 0, blockers: uniqueSorted(blockers)};
  }

  promotionCandidates(items) {
    return items.filter((item) =>
      item.primaryStage === "ready" && item.lifecycleStatus === "active");
  }

  reconcile(item, {now}) {
    const reasons = [];
    const taskFlags = [];
    const blockers = [];
    let lifecycleStatus = item.lifecycleStatus;
    if (item.entityKind === "event" && item.expiresAt && Date.parse(item.expiresAt) < Date.parse(now)) {
      lifecycleStatus = "expired";
      reasons.push("event_ended");
      blockers.push("event_expired");
    }
    if (item.timestamps?.evidenceStaleAt && Date.parse(item.timestamps.evidenceStaleAt) < Date.parse(now)) {
      taskFlags.push("stale_evidence");
      blockers.push("evidence_refresh_required");
      reasons.push("evidence_stale");
    }
    return {
      changed: lifecycleStatus !== item.lifecycleStatus ||
        taskFlags.some((flag) => !item.taskFlags.includes(flag)) ||
        blockers.some((blocker) => !item.blockers.includes(blocker)) ||
        (lifecycleStatus !== "active" &&
          (item.owner === "human" ||
            item.taskFlags.includes("human_review_required") ||
            item.blockers.includes("human_review_required"))),
      lifecycleStatus,
      taskFlags,
      blockers,
      reasons,
    };
  }
}

function copyLifecycleSemantics(semantics) {
  return {
    activeStatuses: [...semantics.activeStatuses],
    publishedStatuses: [...semantics.publishedStatuses],
    expiredStatuses: [...semantics.expiredStatuses],
  };
}

function assertEventBridgeCompatibility(snapshot, {market, generatedAt, staleAfterHours}) {
  const artifact = snapshot?.artifacts?.eventIntakeBridge;
  invariant(
    artifact?.status === "available" && artifact.data,
    "ARTIFACT_NOT_FOUND",
    `A reviewed Event Intake bridge is required for ${market}.`,
    {market, artifactRef: artifact?.relativePath ?? null}
  );
  const bridge = artifact.data;
  invariant(
    bridge.city?.id === market,
    "ARTIFACT_MARKET_MISMATCH",
    `Event Intake bridge ${artifact.relativePath} does not match market ${market}.`,
    {market, bridgeMarket: bridge.city?.id ?? null, artifactRef: artifact.relativePath}
  );
  const bridgeGeneratedAt = Date.parse(bridge.generatedAt ?? "");
  const planGeneratedAt = Date.parse(generatedAt);
  const maximumAgeMs = staleAfterHours * 60 * 60 * 1_000;
  invariant(
    Number.isFinite(bridgeGeneratedAt) &&
      bridgeGeneratedAt <= planGeneratedAt &&
      planGeneratedAt - bridgeGeneratedAt <= maximumAgeMs,
    "ARTIFACT_STALE",
    `Event Intake bridge ${artifact.relativePath} is outside the ${staleAfterHours}-hour freshness window.`,
    {
      market,
      artifactRef: artifact.relativePath,
      bridgeGeneratedAt: bridge.generatedAt ?? null,
      planGeneratedAt: generatedAt,
      staleAfterHours,
    }
  );
  invariant(
    /^\d{4}-\d{2}-\d{2}$/.test(bridge.weekEnd ?? "") &&
      bridge.weekEnd >= generatedAt.slice(0, 10),
    "ARTIFACT_STALE",
    `Event Intake bridge ${artifact.relativePath} has an expired review window.`,
    {
      market,
      artifactRef: artifact.relativePath,
      bridgeWeekEnd: bridge.weekEnd ?? null,
      planDate: generatedAt.slice(0, 10),
    }
  );
}

function plannedWorkItemCount(artifactSnapshot, sourceProfileCount) {
  const eventCounts = artifactSnapshot?.artifacts?.eventIntakeBridge?.counts ?? {};
  const organizerCounts = artifactSnapshot?.artifacts?.organizerPublicationPackets?.counts ?? {};
  const counts = [
    eventCounts.sourceProfiles,
    eventCounts.sourceResults,
    eventCounts.eventCandidates,
    organizerCounts.organizers,
    sourceProfileCount,
  ].map((count) => count ?? 0);
  invariant(
    counts.every((count) => Number.isSafeInteger(count) && count >= 0),
    "INVALID_PLAN",
    "Planned work-item counts must be non-negative safe integers."
  );
  return counts.reduce((sum, count) => sum + count, 0);
}

function snapshotSourceProfile(profile) {
  return {
    sourceProfileId: profile.sourceProfileId,
    versionHash: hashValue(profile),
    status: profile.status,
    publication: {
      autoEligible: profile.publication?.autoEligible === true,
      discoveryOnly: profile.publication?.discoveryOnly === true,
      requiresOfficialSource: profile.publication?.requiresOfficialSource === true,
      requiresPolicyApproval: profile.publication?.requiresPolicyApproval === true,
    },
  };
}

function baseWorkItem({runId, now, market, entityKind, id, title, source, evidence, raw, observedAt = null, expiresAt = null}) {
  const workItemId = safeId(`wi-${shortHash({runId, entityKind, id})}-${entityKind}-${id}`);
  return {
    schemaVersion: 1,
    workItemId,
    runId,
    workflowId: "supply-intake",
    market,
    entityKind,
    sourceEntity: {id: String(id), title: String(title || id)},
    primaryStage: "incoming",
    lifecycleStatus: "active",
    owner: "system",
    taskFlags: [],
    blockers: [],
    source,
    decisionProvenance: {
      actorKind: "legacy_projection",
      actorId: "supply-intake-v0.1.0",
      decision: "pending_deterministic_review",
      decidedAt: now,
      inputHash: hashValue(raw),
      model: null,
      ruleIds: ["supply-intake-shadow-v1"],
    },
    confidence: {
      overall: 0,
      basis: "unreviewed_projection",
      calibrated: false,
      fieldConfidence: {},
    },
    evidence,
    timestamps: {
      createdAt: now,
      updatedAt: now,
      observedAt,
      evidenceStaleAt: addHours(observedAt ?? now, 168),
    },
    expiresAt,
    raw,
    stageHistory: [],
    createdAt: now,
    updatedAt: now,
  };
}

function workItemForEvent(event, context) {
  return baseWorkItem({
    ...context,
    entityKind: "event",
    id: event.id,
    title: event.title,
    source: {
      sourceProfileId: sourceProfileForEvent(event),
      label: event.sourceLabel ?? null,
      url: event.sourceUrl ?? null,
      artifactRef: context.artifact.relativePath,
    },
    evidence: evidenceFor(context.artifact, event, [event.sourceUrl].filter(Boolean)),
    raw: event,
    observedAt: null,
    expiresAt: endOfDate(event.endDate ?? event.startDate),
  });
}

function workItemForSourceResult(result, context) {
  return baseWorkItem({
    ...context,
    entityKind: "source_result",
    id: result.id,
    title: result.title,
    source: {
      sourceProfileId: result.sourceProfileId ?? "legacy_unknown",
      label: result.sourceLabel ?? null,
      url: result.url ?? null,
      artifactRef: context.artifact.relativePath,
    },
    evidence: evidenceFor(context.artifact, result, [result.url].filter(Boolean)),
    raw: result,
    observedAt: result.observedAt ?? null,
  });
}

function workItemForLegacySourceProfile(profile, context) {
  return baseWorkItem({
    ...context,
    entityKind: "source_profile",
    id: `legacy-${profile.id}`,
    title: profile.label ?? profile.id,
    source: {
      sourceProfileId: profile.id,
      label: profile.label ?? null,
      url: profile.items?.[0]?.url ?? null,
      artifactRef: context.artifact.relativePath,
    },
    evidence: evidenceFor(context.artifact, profile, (profile.items ?? []).map((item) => item.url).filter(Boolean)),
    raw: profile,
  });
}

function workItemForOperationsSourceProfile(profile, context) {
  return baseWorkItem({
    ...context,
    entityKind: "source_profile",
    id: profile.sourceProfileId,
    title: profile.label,
    source: {
      sourceProfileId: profile.sourceProfileId,
      label: profile.label,
      url: null,
      artifactRef: `operations/src/workflows/supply-intake/sources/${profile.sourceProfileId}/profile.json`,
    },
    evidence: {
      artifactRef: `operations/src/workflows/supply-intake/sources/${profile.sourceProfileId}/profile.json`,
      artifactHash: hashValue(profile),
      citations: [],
      provenanceStatus: "operations_owned_profile",
    },
    raw: profile,
  });
}

function workItemForOrganizer(packet, context) {
  return baseWorkItem({
    ...context,
    entityKind: "organizer",
    id: packet.entityId ?? packet.canonicalHostId,
    title: packet.displayName,
    source: {
      sourceProfileId: "legacy_organizer_intake",
      label: "Organizer Intake publication review",
      url: packet.evidenceReview?.records?.find((record) => record.surface?.url)?.surface?.url ?? null,
      artifactRef: context.artifact.relativePath,
    },
    evidence: evidenceFor(
      context.artifact,
      packet,
      (packet.evidenceReview?.records ?? []).map((record) => record.surface?.url).filter(Boolean)
    ),
    raw: packet,
  });
}

function reviewEvent(item, now) {
  const event = item.raw;
  const blockers = [];
  const taskFlags = [];
  let primaryStage = "verify";
  let lifecycleStatus = item.lifecycleStatus;
  if (item.expiresAt && Date.parse(item.expiresAt) < Date.parse(now)) {
    return outcome(item, {
      primaryStage: "verify",
      lifecycleStatus: "expired",
      blockers: ["event_expired"],
      taskFlags: ["stale_event"],
      owner: "system",
      overall: event.sourceUrl ? 0.72 : 0.28,
      basis: "event_expired_before_review",
      ruleIds: ["event-expiry-v1"],
      reason: "event_expired",
      now,
    });
  }
  if (!event.sourceUrl) {
    blockers.push("official_source_missing");
    taskFlags.push("source_verification");
  }
  if (event.requiresVerification) taskFlags.push("fact_verification");
  if ((event.dedupe?.duplicateCandidateIds ?? []).length > 0) {
    blockers.push("possible_duplicate");
    taskFlags.push("dedupe_resolution");
  }
  if (event.sourceStatus === "missing_source_url") blockers.push("source_url_missing");
  if (blockers.some((blocker) => blocker !== "event_expired")) primaryStage = "resolve";
  else if (event.reviewState === "approved" && !event.requiresVerification && lifecycleStatus === "active") primaryStage = "ready";
  return outcome(item, {
    primaryStage,
    lifecycleStatus,
    blockers,
    taskFlags,
    owner: primaryStage === "resolve" ? "human" : "agent",
    overall: event.sourceUrl ? 0.72 : 0.28,
    basis: event.sourceUrl ? "legacy_candidate_with_source" : "legacy_lead_missing_source",
    ruleIds: ["event-source-required-v1", "event-expiry-v1", "event-dedupe-flag-v1"],
    reason: primaryStage === "resolve" ? "deterministic_blockers_found" : "deterministic_verification_pending",
    now,
  });
}

function reviewOrganizer(item, now) {
  const packet = item.raw;
  const blockers = uniqueSorted([...(packet.blockers ?? []), ...(packet.dataBlockers ?? []), ...(packet.evidenceBlockers ?? [])]);
  const approved = packet.adminDecision?.currentDecision?.decision === "approve_public";
  const primaryStage = blockers.length > 0 ? "resolve" : approved ? "ready" : "verify";
  return outcome(item, {
    primaryStage,
    blockers,
    taskFlags: [
      ...(packet.evidenceReview?.manualReportsWithoutArtifacts > 0 ? ["manual_evidence_review"] : []),
      ...(!approved ? ["publication_decision"] : []),
    ],
    owner: primaryStage === "resolve" || !approved ? "human" : "agent",
    overall: blockers.length === 0 && approved ? 0.92 : 0.55,
    basis: approved ? "legacy_admin_approval" : "legacy_publication_packet",
    ruleIds: ["organizer-publication-packet-v1"],
    reason: blockers.length > 0 ? "organizer_packet_blocked" : approved ? "legacy_approval_verified" : "organizer_decision_pending",
    now,
  });
}

function reviewSourceResult(item, now) {
  const result = item.raw;
  const blockers = [];
  const taskFlags = [...(result.riskFlags ?? [])];
  if (!result.url) blockers.push("source_url_missing");
  if ((result.riskFlags ?? []).length > 0) taskFlags.push("source_policy_review");
  const primaryStage = blockers.length > 0 ? "resolve" : result.status === "approved" ? "ready" : "verify";
  return outcome(item, {
    primaryStage,
    blockers,
    taskFlags,
    owner: blockers.length > 0 ? "human" : "agent",
    overall: result.url ? 0.68 : 0.2,
    basis: result.url ? "attributed_source_result" : "unattributed_source_result",
    ruleIds: ["source-result-attribution-v1"],
    reason: blockers.length > 0 ? "source_result_blocked" : "source_result_verification_pending",
    now,
  });
}

function reviewSourceProfile(item, now) {
  const profile = item.raw;
  const blockers = [];
  const taskFlags = [];
  if (profile.status === "needs_verification") blockers.push("source_policy_unverified");
  if (profile.status === "planned") blockers.push("source_not_implemented");
  if (profile.status === "discovery_only" || profile.publication?.discoveryOnly) taskFlags.push("discovery_only");
  if (profile.publication?.requiresOfficialSource) taskFlags.push("official_source_required");
  if (profile.acquisition?.networkEnabled === false) taskFlags.push("network_disabled");
  const operationsOwned = item.evidence.provenanceStatus === "operations_owned_profile";
  const primaryStage = blockers.length > 0 ? "resolve" : operationsOwned ? "ready" : "verify";
  return outcome(item, {
    primaryStage,
    blockers,
    taskFlags,
    owner: blockers.length > 0 ? "human" : "agent",
    overall: operationsOwned ? 0.95 : 0.65,
    basis: operationsOwned ? "versioned_operations_profile" : "legacy_source_profile",
    ruleIds: ["source-profile-policy-v1"],
    reason: blockers.length > 0 ? "source_profile_blocked" : operationsOwned ? "source_profile_configured" : "source_profile_verification_pending",
    now,
  });
}

function outcome(item, {primaryStage, lifecycleStatus = "active", blockers, taskFlags, owner, overall, basis, ruleIds, reason, now}) {
  return {
    primaryStage,
    lifecycleStatus,
    blockers: uniqueSorted(blockers),
    taskFlags: uniqueSorted([
      ...taskFlags,
      ...(owner === "human" ? ["human_review_required"] : []),
    ]),
    owner,
    reason,
    confidence: {
      overall,
      basis,
      calibrated: false,
      fieldConfidence: fieldConfidenceFor(item, overall),
    },
    decisionProvenance: {
      actorKind: "deterministic_rule_engine",
      actorId: "supply-intake-v0.1.0",
      decision: `${primaryStage}:${lifecycleStatus}`,
      decidedAt: now,
      inputHash: hashValue(item.raw),
      model: null,
      ruleIds,
    },
  };
}

function fieldConfidenceFor(item, overall) {
  return {
    title: item.sourceEntity.title ? Math.min(1, overall + 0.08) : 0,
    source: item.source.url ? overall : Math.min(overall, 0.25),
    identity: overall,
  };
}

function evidenceFor(artifact, raw, citations) {
  return {
    artifactRef: artifact.relativePath,
    artifactHash: hashValue({artifactSha256: artifact.sha256, raw}),
    citations: uniqueSorted(citations),
    provenanceStatus: "legacy_artifact_snapshot",
  };
}

function sourceProfileForEvent(event) {
  try {
    const host = new URL(event.sourceUrl).hostname.toLowerCase();
    if (host === "lu.ma" || host.endsWith(".lu.ma") || host === "luma.com" || host.endsWith(".luma.com")) return "luma";
    if (host === "cntraveller.in" || host.endsWith(".cntraveller.in")) return "cntraveller";
    return `web:${host}`;
  } catch {
    return "legacy_unknown";
  }
}

function endOfDate(value) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value ?? "")) return null;
  return `${value}T23:59:59.999Z`;
}

function addHours(value, hours) {
  const parsed = Date.parse(value);
  return Number.isNaN(parsed) ? null : new Date(parsed + hours * 60 * 60 * 1000).toISOString();
}

function finalizePlan(plan) {
  const {generatedAt: _generatedAt, ...hashablePlan} = plan;
  return {...plan, planContentHash: hashValue(hashablePlan)};
}

function dedupeItems(items) {
  const byId = new Map();
  for (const item of items) {
    const existing = byId.get(item.workItemId);
    if (!existing || existing.evidence.provenanceStatus !== "operations_owned_profile") byId.set(item.workItemId, item);
  }
  return [...byId.values()];
}
