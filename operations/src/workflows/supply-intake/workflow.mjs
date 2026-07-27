import {hashValue, shortHash} from "../../platform/canonical-json.mjs";
import {
  assertWorkItem as assertPlatformWorkItem,
  MAX_WORK_ITEMS_PER_RUN,
  safeId,
  uniqueSorted,
} from "../../platform/contracts.mjs";
import {invariant} from "../../platform/errors.mjs";
import {
  acquisitionRunKey,
  loadSupplyAcquisitionPolicy,
} from "./acquisition.mjs";
import {planDiscoveryQueries} from "./discovery-planner.mjs";
import {loadSourceProfiles} from "./sources/index.mjs";
import {
  SUPPLY_INTAKE_ENTITY_KINDS,
  SUPPLY_INTAKE_LIFECYCLE_SEMANTICS,
  SUPPLY_INTAKE_LIFECYCLE_STATUSES,
  SUPPLY_INTAKE_PRIMARY_STAGES,
  SUPPLY_INTAKE_TRANSITIONS,
} from "./definition.mjs";
import {
  freshnessRequestsFromInputs,
  loadSupplyFreshnessPolicy,
  planFreshnessRequests,
} from "./freshness.mjs";
import {
  assertSupplyInputSnapshot,
  emptySupplyInputSnapshot,
  supplyInputSummary,
} from "./input-snapshot.mjs";
import {loadSupplyModelPolicy} from "./model-fallback.mjs";

export const MAX_SUPPLY_INTAKE_WORK_ITEMS_PER_RUN = MAX_WORK_ITEMS_PER_RUN;
export const SUPPLY_INTAKE_WORKFLOW_ID = "supply-intake";
export const SUPPLY_INTAKE_WORKFLOW_VERSION = "0.6.0";
const SUPPLY_INTAKE_SCOPES = Object.freeze(["all", "organizer"]);
const ORGANIZER_PACKET_STRING_LIMIT = 500;
const ORGANIZER_PACKET_LIST_LIMIT = 40;
const ORGANIZER_PACKET_MARKET_LIMIT = 8;
const ORGANIZER_PACKET_SHORT_LIST_LIMIT = 12;
const ORGANIZER_PACKET_APPROVAL_CHECKS = Object.freeze([
  "crawlDisabledReviewed",
  "identityReviewed",
  "marketScopeReviewed",
  "mediaRightsReviewed",
  "ownerSafeCopyReviewed",
  "surfaceInventoryReviewed",
]);

export class SupplyIntakeWorkflow {
  constructor({
    store = null,
    inputSnapshotLoader = null,
    discoveryPlanner = planDiscoveryQueries,
    acquisitionPolicyLoader = loadSupplyAcquisitionPolicy,
    acquisitionPort = null,
    sourceProfilesLoader = loadSourceProfiles,
    freshnessPolicyLoader = loadSupplyFreshnessPolicy,
    modelPolicyLoader = loadSupplyModelPolicy,
    extractionRouter = null,
  } = {}) {
    this.workflowId = SUPPLY_INTAKE_WORKFLOW_ID;
    this.version = SUPPLY_INTAKE_WORKFLOW_VERSION;
    this.primaryStages = SUPPLY_INTAKE_PRIMARY_STAGES;
    this.lifecycleStatuses = SUPPLY_INTAKE_LIFECYCLE_STATUSES;
    this.lifecycleSemantics = SUPPLY_INTAKE_LIFECYCLE_SEMANTICS;
    this.entityKinds = SUPPLY_INTAKE_ENTITY_KINDS;
    this.allowedTransitions = SUPPLY_INTAKE_TRANSITIONS;
    this.store = store;
    this.inputSnapshotLoader = inputSnapshotLoader;
    this.discoveryPlanner = discoveryPlanner;
    this.acquisitionPolicyLoader = acquisitionPolicyLoader;
    this.acquisitionPort = acquisitionPort;
    this.sourceProfilesLoader = sourceProfilesLoader;
    this.freshnessPolicyLoader = freshnessPolicyLoader;
    this.modelPolicyLoader = modelPolicyLoader;
    this.extractionRouter = extractionRouter;
  }

  async planningContext({store, market}) {
    invariant(
      store &&
        typeof store.listRuns === "function" &&
        typeof store.listWorkItems === "function",
      "INVALID_FRESHNESS_STORE",
      "Supply Intake planning requires an Operations store."
    );
    const [runs, workItems, inputSnapshots] = await Promise.all([
      store.listRuns(),
      store.listWorkItems(),
      typeof store.listSupplyInputSnapshots === "function" ?
        store.listSupplyInputSnapshots({market}) :
        [],
    ]);
    return {
      freshnessHistory: {runs, workItems},
      inputSnapshot:
        inputSnapshots[0] ?? emptySupplyInputSnapshot(market),
    };
  }

  async createPlan({
    market = "mumbai",
    through,
    now,
    intakeScope = "all",
    freshnessHistory = {runs: [], workItems: []},
    inputSnapshot = null,
  }) {
    invariant(/^[a-z][a-z0-9-]{1,49}$/.test(market), "INVALID_MARKET", "Market must be a lowercase slug.", {market});
    invariant(/^\d{4}-\d{2}-\d{2}$/.test(through ?? ""), "INVALID_THROUGH", "--through YYYY-MM-DD is required.", {through});
    invariant(
      SUPPLY_INTAKE_SCOPES.includes(intakeScope),
      "INVALID_INTAKE_SCOPE",
      "--intake-scope must be all or organizer.",
      {intakeScope}
    );
    const generatedAt = new Date(now).toISOString();
    const loadedInput = assertSupplyInputSnapshot(
      inputSnapshot ??
        await this.inputSnapshotLoader?.({market}) ??
        emptySupplyInputSnapshot(market),
      {market}
    );
    const [
      profiles,
      freshnessPolicy,
      acquisitionPolicy,
      modelPolicy,
      discoveryPlan,
    ] = await Promise.all([
      this.sourceProfilesLoader(),
      this.freshnessPolicyLoader(),
      this.acquisitionPolicyLoader(),
      this.modelPolicyLoader(),
      this.discoveryPlanner({
        market,
        organizerCandidates:
          loadedInput.organizerSearchCandidates,
      }),
    ]);
    const organizerReviewPolicy = organizerReviewPolicySnapshot(
      loadedInput.organizerReviewPolicy
    );
    const freshness = planFreshnessRequests({
      requests: freshnessRequestsFromInputs({
        searchPlan: discoveryPlan,
        crawlSurfaces: loadedInput.crawlSurfaces,
        market,
      }),
      policy: freshnessPolicy,
      runs: freshnessHistory.runs,
      workItems: freshnessHistory.workItems,
      now: generatedAt,
    });
    const inputSummary = plannedInputSummary(loadedInput, market);
    const plannedItems = plannedWorkItemCount(
      inputSummary,
      profiles.length,
      intakeScope
    );
    invariant(
      plannedItems <= MAX_SUPPLY_INTAKE_WORK_ITEMS_PER_RUN,
      "RUN_SHARD_REQUIRED",
      `Supply Intake plans are limited to ${MAX_SUPPLY_INTAKE_WORK_ITEMS_PER_RUN} work items; split the source scope before running.`,
      {plannedItems, maximum: MAX_SUPPLY_INTAKE_WORK_ITEMS_PER_RUN}
    );
    const sourceProfiles = profiles.map(snapshotSourceProfile);
    const policy = {
      randomAuditBasisPoints: 10_000,
      autoPublicationEnabled: false,
      editorialSourcesDiscoveryOnly: true,
      freshnessPolicyVersion: freshnessPolicy.policyVersion,
      acquisitionPolicyVersion: acquisitionPolicy.policyVersion,
      modelPolicyVersion: modelPolicy.policyVersion,
    };
    const promotionPolicyHash = hashValue({
      workflowPolicy: policy,
      freshnessPolicy,
      acquisitionPolicy,
      modelPolicy,
      sourceProfiles,
    });
    const basis = {
      schemaVersion: 1,
      workflowId: this.workflowId,
      workflowVersion: this.version,
      market,
      intakeScope,
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
      inputSnapshot: loadedInput,
      inputSummary,
      discoveryPlan,
      organizerReviewPolicy,
      sourceProfiles,
      policy,
      freshnessPolicy,
      acquisitionPolicy,
      modelPolicy,
      freshness,
      promotionPolicyHash,
      capabilities: {
        network: acquisitionPolicy.provider.enabled,
        modelCalls: modelPolicy.provider.enabled,
        publicWrites: false,
        ruleDeployment: false,
      },
    };
    const basisHash = hashValue(basis);
    const plan = {
      ...basis,
      planId: `supply-${market}-${through}-${basisHash.slice(0, 12)}`,
      basisHash,
      generatedAt,
      budgets: {
        workItems: Math.max(1_000, plannedItems),
        networkRequests:
          acquisitionPolicy.budgets.maxNetworkRequestsPerRun,
        modelCalls: modelPolicy.budgets.maxModelCallsPerRun,
        modelInputTokens: modelPolicy.budgets.maxInputTokensPerRun,
        modelOutputTokens: modelPolicy.budgets.maxOutputTokensPerRun,
        modelCostMicros: modelPolicy.budgets.maxCostMicrosPerRun,
        publicWrites: 0,
      },
      guardrails: [
        "The plan reads one immutable Operations-owned normalized input snapshot; committed operational JSON is not an input.",
        acquisitionPolicy.provider.enabled ?
          "Provider acquisition requires the frozen policy-gap decision, injected adapter, and both request ceilings." :
          "Provider acquisition is disabled; manual file capture remains available through the injected acquisition port.",
        modelPolicy.provider.enabled ?
          "Model fallback is extraction-only and requires the frozen policy decision, GuardedModelRunner, cache, and run plus monthly ceilings." :
          "Model fallback is disabled with zero run and monthly ceilings.",
        "No public write, scheduler, or rule deployment capability is granted.",
        "Freshness eligibility is derived from immutable completed Operations runs; only scheduled requests may cross the acquisition port.",
        "Raw provider payloads remain outside Firestore; only bounded provenance may enter durable records.",
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
      plan.capabilities.network ===
          plan.acquisitionPolicy?.provider?.enabled &&
        plan.capabilities.modelCalls ===
          plan.modelPolicy?.provider?.enabled &&
        !plan.capabilities.publicWrites &&
        !plan.capabilities.ruleDeployment,
      "UNSAFE_CAPABILITY",
      "Shadow plan grants an unsafe capability."
    );
    invariant(
      plan.promotionPolicyHash === hashValue({
        workflowPolicy: plan.policy,
        freshnessPolicy: plan.freshnessPolicy,
        acquisitionPolicy: plan.acquisitionPolicy,
        modelPolicy: plan.modelPolicy,
        sourceProfiles: plan.sourceProfiles,
      }),
      "INVALID_PLAN",
      "Plan promotion policy snapshot is stale or invalid."
    );
    invariant(
      plan.policy?.acquisitionPolicyVersion ===
          plan.acquisitionPolicy?.policyVersion &&
        plan.acquisitionPolicy?.rawPayload
          ?.firestorePersistenceAllowed === false &&
        plan.acquisitionPolicy?.rawPayload?.persistence ===
          "external_artifact_store_only" &&
        plan.budgets?.networkRequests ===
          plan.acquisitionPolicy?.budgets
            ?.maxNetworkRequestsPerRun &&
        (plan.acquisitionPolicy?.provider?.enabled ?
          (
            typeof plan.acquisitionPolicy.provider.adapterId ===
              "string" &&
            typeof plan.acquisitionPolicy.provider.decisionId ===
              "string" &&
            plan.acquisitionPolicy.budgets
              .maxNetworkRequestsPerRun > 0 &&
            plan.acquisitionPolicy.budgets
              .maxNetworkRequestsPerMonth > 0
          ) :
          (
            plan.acquisitionPolicy?.provider?.adapterId === null &&
            plan.acquisitionPolicy?.provider?.decisionId === null &&
            plan.budgets.networkRequests === 0 &&
            plan.acquisitionPolicy?.budgets
              ?.maxNetworkRequestsPerMonth === 0
          )),
      "INVALID_ACQUISITION_PLAN",
      "Supply Intake acquisition policy or budget is missing, stale, or unsafe."
    );
    invariant(
      plan.policy?.modelPolicyVersion ===
          plan.modelPolicy?.policyVersion &&
        plan.budgets?.modelCalls ===
          plan.modelPolicy?.budgets?.maxModelCallsPerRun &&
        plan.budgets?.modelInputTokens ===
          plan.modelPolicy?.budgets?.maxInputTokensPerRun &&
        plan.budgets?.modelOutputTokens ===
          plan.modelPolicy?.budgets?.maxOutputTokensPerRun &&
        plan.budgets?.modelCostMicros ===
          plan.modelPolicy?.budgets?.maxCostMicrosPerRun &&
        (plan.modelPolicy?.provider?.enabled ?
          (
            typeof plan.modelPolicy.provider.adapterId === "string" &&
            typeof plan.modelPolicy.provider.modelId === "string" &&
            typeof plan.modelPolicy.provider.decisionId === "string" &&
            Object.values(plan.modelPolicy.budgets)
              .every((value) => Number.isSafeInteger(value) && value > 0)
          ) :
          (
            plan.modelPolicy?.provider?.adapterId === null &&
            plan.modelPolicy?.provider?.modelId === null &&
            plan.modelPolicy?.provider?.decisionId === null &&
            Object.values(plan.modelPolicy?.budgets ?? {})
              .every((value) => value === 0)
          )),
      "INVALID_MODEL_PLAN",
      "Supply Intake model policy or budget is missing, stale, or unsafe."
    );
    invariant(
      plan.freshness?.schemaVersion === 1 &&
        plan.freshness.policyVersion ===
          plan.freshnessPolicy?.policyVersion &&
        plan.policy?.freshnessPolicyVersion ===
          plan.freshnessPolicy?.policyVersion &&
        plan.freshness.summary?.requested ===
          (plan.freshness.scheduled?.length ?? 0) +
          (plan.freshness.skippedFresh?.length ?? 0),
      "INVALID_FRESHNESS_PLAN",
      "Supply Intake freshness plan is missing or stale."
    );
    const inputSnapshot = assertSupplyInputSnapshot(
      plan.inputSnapshot,
      {market: plan.market}
    );
    invariant(
      hashValue(plan.inputSummary) ===
        hashValue(plannedInputSummary(inputSnapshot, plan.market)) &&
        plan.discoveryPlan?.schemaVersion === 1 &&
        plan.discoveryPlan.plannerId ===
          "operations-supply-discovery-v1" &&
        plan.discoveryPlan.market === plan.market,
      "INVALID_SUPPLY_INPUT",
      "Supply Intake normalized input or discovery plan is missing or stale."
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
      plan.inputSummary,
      Array.isArray(plan.sourceProfiles) ? plan.sourceProfiles.length : NaN,
      plan.intakeScope ?? "all"
    );
    invariant(
      SUPPLY_INTAKE_SCOPES.includes(plan.intakeScope ?? "all"),
      "INVALID_INTAKE_SCOPE",
      "Supply Intake plan has an invalid intake scope."
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
    const input = assertSupplyInputSnapshot(plan.inputSnapshot, {
      market: plan.market,
    });
    const artifact = inputSnapshotEvidenceRef(input);
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
    if (plan.intakeScope !== "organizer") {
      for (const result of input.sourceResults) {
        items.push(workItemForSourceResult(result, {
          runId,
          now,
          market: plan.market,
          artifact,
        }));
      }
      for (const event of input.eventCandidates) {
        if (event.startDate && event.startDate > plan.through) continue;
        items.push(workItemForEvent(event, {
          runId,
          now,
          market: plan.market,
          artifact,
        }));
      }
      for (const profile of profiles) {
        items.push(workItemForOperationsSourceProfile(profile, {
          runId,
          now,
          market: plan.market,
        }));
      }
    }
    for (const packet of input.organizerPublicationPackets) {
      if (!organizerPacketSupportsMarket(packet, plan.market)) continue;
      items.push(workItemForOrganizer(packet, {
        runId,
        now,
        market: plan.market,
        artifact,
      }));
    }
    for (const candidate of input.organizerSearchCandidates) {
      if (candidate?.queryIntent?.marketSlug !== plan.market) continue;
      const reviewContext = candidate.reviewContext ?? null;
      items.push(workItemForOrganizerCandidate(candidate, {
        runId,
        now,
        market: plan.market,
        artifact,
        reviewContext,
      }));
    }
    if (plan.intakeScope !== "organizer") {
      for (const event of input.externalEventCandidates) {
        if (event?.attribution?.state !== "orphan" ||
          event?.location?.citySlug !== plan.market) continue;
        items.push(workItemForOrphanEvent(event, {
          runId,
          now,
          market: plan.market,
          artifact,
        }));
      }
    }
    for (const lead of input.organizerLeads) {
      if (lead?.marketSlug !== plan.market) continue;
      items.push(workItemForOrganizerEventLead(lead, {
        runId,
        now,
        market: plan.market,
        artifact,
      }));
    }
    return dedupeItems(items).sort((left, right) => left.workItemId.localeCompare(right.workItemId));
  }

  async acquire(plan, {runKey, input = {}} = {}) {
    this.assertPlan(plan);
    invariant(
      this.acquisitionPort &&
        typeof this.acquisitionPort.acquire === "function",
      "ACQUISITION_PORT_MISSING",
      "Acquisition requires a port injected by the trusted runtime."
    );
    invariant(
      this.acquisitionPort.policyVersion ===
        plan.acquisitionPolicy.policyVersion,
      "ACQUISITION_POLICY_MISMATCH",
      "The injected acquisition port does not match the frozen plan policy."
    );
    if (this.acquisitionPort.networkRequestCost > 0) {
      invariant(
        plan.capabilities.network === true,
        "UNSAFE_CAPABILITY",
        "The frozen plan does not grant provider network acquisition."
      );
    }
    const request = plan.freshness.scheduled.find((entry) =>
      acquisitionRunKey(entry) === runKey);
    invariant(
      request,
      "ACQUISITION_NOT_PLANNED",
      "Acquisition is allowed only for a scheduled freshness request.",
      {runKey: runKey ?? null}
    );
    return this.acquisitionPort.acquire({
      runKey,
      input,
      plannedRequest: request,
    });
  }

  async resolveExtraction(plan, request) {
    this.assertPlan(plan);
    invariant(
      this.extractionRouter &&
        typeof this.extractionRouter.resolve === "function",
      "MODEL_ROUTER_MISSING",
      "Extraction routing requires a trusted injected router."
    );
    invariant(
      this.extractionRouter.policy.policyVersion ===
        plan.modelPolicy.policyVersion,
      "MODEL_POLICY_MISMATCH",
      "The injected extraction router does not match the frozen plan policy."
    );
    if (request?.deterministic?.resolved !== true) {
      invariant(
        plan.capabilities.modelCalls === true,
        "UNSAFE_CAPABILITY",
        "The frozen plan does not grant model fallback."
      );
    }
    return this.extractionRouter.resolve(request);
  }

  review(item, {now}) {
    if (item.entityKind === "event") {
      return item.adminProjection?.recordType === "orphan_event_candidate" ?
        reviewOrphanEvent(item, now) :
        reviewEvent(item, now);
    }
    if (item.entityKind === "organizer") {
      return [
        "organizer_search_candidate",
        "organizer_event_lead",
      ].includes(item.adminProjection?.recordType) ?
        reviewOrganizerCandidate(item, now) :
        reviewOrganizer(item, now);
    }
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
      if (item.adminProjection?.recordType === "orphan_event_candidate") {
        blockers.push("organizer_not_in_inventory");
      }
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

function plannedWorkItemCount(
  inputSummary,
  sourceProfileCount,
  intakeScope = "all"
) {
  const counts = [
    intakeScope === "organizer" ? 0 : inputSummary?.sourceResults,
    intakeScope === "organizer" ? 0 : inputSummary?.eventCandidates,
    inputSummary?.organizerPublicationPackets,
    inputSummary?.organizerSearchCandidates,
    intakeScope === "organizer" ? 0 :
      inputSummary?.externalEventCandidates,
    inputSummary?.organizerLeads,
    intakeScope === "organizer" ? 0 : sourceProfileCount,
  ].map((count) => count ?? 0);
  invariant(
    counts.every((count) => Number.isSafeInteger(count) && count >= 0),
    "INVALID_PLAN",
    "Planned work-item counts must be non-negative safe integers."
  );
  return counts.reduce((sum, count) => sum + count, 0);
}

function inputSnapshotEvidenceRef(snapshot) {
  return {
    relativePath: `operations:supply-input:${snapshot.snapshotId}`,
    sha256: snapshot.contentHash,
  };
}

function organizerPacketSupportsMarket(packet, market) {
  if (typeof market !== "string" || market.length === 0) return false;
  const geography = packet?.identity?.geography;
  return [
    geography?.primaryMarketSlug,
    ...(geography?.markets ?? []).flatMap((entry) => [
      entry?.marketSlug,
      entry?.eventFilter?.citySlug,
    ]),
  ].some((entry) => entry === market);
}

function plannedInputSummary(snapshot, market) {
  const summary = supplyInputSummary(snapshot);
  return {
    ...summary,
    organizerPublicationPackets:
      snapshot.organizerPublicationPackets.filter((packet) =>
        organizerPacketSupportsMarket(packet, market)).length,
    organizerSearchCandidates:
      snapshot.organizerSearchCandidates.filter((candidate) =>
        candidate?.queryIntent?.marketSlug === market).length,
    externalEventCandidates:
      snapshot.externalEventCandidates.filter((candidate) =>
        candidate?.location?.citySlug === market).length,
    organizerLeads:
      snapshot.organizerLeads.filter((lead) =>
        lead?.marketSlug === market).length,
  };
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

function baseWorkItem({
  runId,
  now,
  market,
  entityKind,
  id,
  title,
  source,
  evidence,
  raw,
  adminProjection = null,
  observedAt = null,
  expiresAt = null,
}) {
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
    adminProjection,
    decisionProvenance: {
      actorKind: "normalized_projection",
      actorId: `supply-intake-v${SUPPLY_INTAKE_WORKFLOW_VERSION}`,
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
    adminProjection: {
      recordType: "event_candidate",
      candidate: eventCandidateProjection(event),
    },
    observedAt: null,
    expiresAt: endOfDate(event.endDate ?? event.startDate),
  });
}

function workItemForOrphanEvent(event, context) {
  return baseWorkItem({
    ...context,
    entityKind: "event",
    id: event.candidateId,
    title: event.title,
    source: {
      sourceProfileId: `external_event:${event.platform}`,
      label: event.platform,
      url: event.eventUrl ?? event.sourceUrl ?? null,
      artifactRef: context.artifact.relativePath,
    },
    evidence: evidenceFor(
      context.artifact,
      event,
      [event.eventUrl, event.sourceUrl].filter(Boolean)
    ),
    raw: event,
    adminProjection: {
      recordType: "orphan_event_candidate",
      candidate: orphanEventProjection(event),
    },
    observedAt: event.startAt,
    expiresAt: event.endAt ?? event.startAt,
  });
}

function workItemForOrganizerEventLead(lead, context) {
  const canonicalUrl = lead.organizerUrl ?? lead.eventUrls?.[0] ?? null;
  const candidate = {
    candidateId: lead.leadId,
    batchId: "event-organizer-leads",
    resultId: lead.leadId,
    rank: 1,
    query: `${lead.organizerName} organizer from event evidence`,
    queryIntent: {
      activityKind: "event_organizer_attribution",
      entityHint: lead.organizerName,
      marketSlug: lead.marketSlug,
    },
    observedAt: dateOnly(lead.observedAt),
    title: lead.organizerName,
    snippet:
      `Organizer named by ${lead.eventCandidateIds.length} source-backed event candidate(s).`,
    url: canonicalUrl,
    canonicalUrl,
    platform: lead.sourcePlatform,
    surfaceKind: lead.organizerUrl ? "organizerProfile" : "eventListing",
    normalizedKey: lead.organizerUrl ?
      `url:${lead.organizerUrl.toLowerCase()}` :
      `event-organizer:${safeId(lead.organizerName)}:${lead.marketSlug}`,
    suggestedSurface: {
      confidence: {city: "high", entityMatch: "low", ownership: "low"},
      crawl: {
        eventDiscoveryStatus: "disabled",
        policy: "manualOnly",
        supportsEventExtraction: true,
      },
      evidenceRefs: lead.eventUrls,
      normalizedKey: lead.organizerUrl ?
        `url:${lead.organizerUrl.toLowerCase()}` :
        `event-organizer:${safeId(lead.organizerName)}:${lead.marketSlug}`,
      notes: "Match or create the organizer before attributing the event.",
      platform: lead.sourcePlatform,
      role: "secondary",
      status: "candidate",
      surfaceId: safeId(`event-lead-${lead.leadId}`),
      surfaceKind: lead.organizerUrl ? "organizerProfile" : "eventListing",
      url: canonicalUrl,
    },
    existingEntityMatches: [],
    reviewAction: lead.reviewAction,
    diagnostics: [lead.blocker],
    reviewContext: {
      recordStatus: "review_now",
      existingInventory: false,
      formats: [],
      sources: lead.eventUrls,
      eventSignal:
        `${lead.eventCandidateIds.length} event candidate(s) name this organizer.`,
      reviewNotes:
        "Resolve organizer identity; attribution stays blocked until a canonical match exists.",
      verifiedAt: dateOnly(lead.observedAt),
    },
  };
  return baseWorkItem({
    ...context,
    entityKind: "organizer",
    id: lead.leadId,
    title: lead.organizerName,
    source: {
      sourceProfileId: `event_organizer_lead:${lead.sourcePlatform}`,
      label: "Event organizer evidence",
      url: canonicalUrl,
      artifactRef: context.artifact.relativePath,
    },
    evidence: evidenceFor(
      context.artifact,
      lead,
      lead.eventUrls ?? []
    ),
    raw: lead,
    adminProjection: {
      recordType: "organizer_search_candidate",
      candidate,
    },
    observedAt: lead.observedAt,
  });
}

function orphanEventProjection(event) {
  return {
    id: event.candidateId,
    candidateId: event.candidateId,
    title: event.title,
    category: "external_event",
    neighborhood: event.location?.address ?? "",
    venue: event.location?.name ?? event.location?.address ?? "",
    startDate: dateOnly(event.startAt),
    endDate: event.endAt ? dateOnly(event.endAt) : null,
    time: timeOnly(event.startAt),
    price: event.priceText ?? "",
    sourceResultIds: [],
    sourceUrl: event.eventUrl ?? event.sourceUrl ?? null,
    sourceLabel: event.platform,
    reviewState: "needs_changes",
    requiresVerification: true,
    explicitSinglesEvent: false,
    whySinglesFriendly: "",
    publicDescription: event.description ?? "",
    scores: {},
    sourceCoverage: {
      sourceResultIds: [],
      matchedSourceResults: 0,
      hasSourceUrl: Boolean(event.eventUrl ?? event.sourceUrl),
      hasManualInstagramReference: false,
    },
    sourceStatus: event.eventUrl || event.sourceUrl ?
      "source_backed" :
      "missing_source_url",
    publishability: "lead_needs_source",
    score: 0,
    warnings: uniqueSorted([
      ...(event.diagnostics ?? []),
      "organizer_not_in_inventory",
    ]),
    attribution: event.attribution,
    blockerCodes: uniqueSorted([
      ...(event.blockers ?? []),
      "organizer_not_in_inventory",
    ]),
    publicationEligibility: "blocked_orphan",
  };
}

function workItemForSourceResult(result, context) {
  return baseWorkItem({
    ...context,
    entityKind: "source_result",
    id: result.id,
    title: result.title,
    source: {
      sourceProfileId: result.sourceProfileId ?? "unknown_source",
      label: result.sourceLabel ?? null,
      url: result.url ?? null,
      artifactRef: context.artifact.relativePath,
    },
    evidence: evidenceFor(context.artifact, result, [result.url].filter(Boolean)),
    raw: result,
    adminProjection: {
      recordType: "event_source_result",
      result: eventSourceResultProjection(result),
    },
    observedAt: result.observedAt ?? null,
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
    adminProjection: {
      recordType: "event_source_profile",
      profile: eventSourceProfileProjection(profile),
    },
  });
}

function eventCandidateProjection(event) {
  const sourceResultIds = Array.isArray(event.sourceResultIds) ?
    event.sourceResultIds.slice(0, 40).map((value) =>
      boundedProjectionString(value, {field: "sourceResultIds"})) :
    [];
  const sourceUrl =
    typeof event.sourceUrl === "string" ?
      boundedProjectionString(event.sourceUrl, {
        field: "sourceUrl",
        maximum: 2_000,
      }) :
      null;
  return {
    id: boundedProjectionString(event.id, {field: "id"}),
    normalizedEventKey:
      typeof event.normalizedEventKey === "string" ?
        boundedProjectionString(event.normalizedEventKey, {
          field: "normalizedEventKey",
        }) :
        boundedProjectionString(event.id, {field: "normalizedEventKey"}),
    title: boundedProjectionString(event.title ?? event.id, {
      field: "title",
    }),
    category: boundedProjectionString(event.category ?? "external_event", {
      field: "category",
    }),
    neighborhood: boundedProjectionString(event.neighborhood ?? "", {
      field: "neighborhood",
      allowEmpty: true,
    }),
    venue: boundedProjectionString(event.venue ?? "", {
      field: "venue",
      allowEmpty: true,
    }),
    startDate: boundedProjectionString(event.startDate, {
      field: "startDate",
      maximum: 40,
    }),
    endDate:
      typeof event.endDate === "string" ?
        boundedProjectionString(event.endDate, {
          field: "endDate",
          maximum: 40,
        }) :
        null,
    time: boundedProjectionString(event.time ?? "", {
      field: "time",
      allowEmpty: true,
      maximum: 40,
    }),
    price: boundedProjectionString(event.price ?? "", {
      field: "price",
      allowEmpty: true,
    }),
    sourceResultIds,
    sourceUrl,
    sourceLabel: boundedProjectionString(event.sourceLabel ?? "Source", {
      field: "sourceLabel",
    }),
    reviewState: boundedProjectionString(event.reviewState ?? "new", {
      field: "reviewState",
    }),
    requiresVerification: event.requiresVerification !== false,
    explicitSinglesEvent: event.explicitSinglesEvent === true,
    whySinglesFriendly: boundedProjectionString(
      event.whySinglesFriendly ?? "",
      {field: "whySinglesFriendly", allowEmpty: true}
    ),
    publicDescription: boundedProjectionString(
      event.publicDescription ?? "",
      {field: "publicDescription", allowEmpty: true, maximum: 1_000}
    ),
    scores:
      event.scores && typeof event.scores === "object" &&
        !Array.isArray(event.scores) ?
        event.scores :
        {},
    sourceCoverage: event.sourceCoverage ?? {
      sourceResultIds,
      matchedSourceResults: sourceResultIds.length,
      hasSourceUrl: Boolean(sourceUrl),
      hasManualInstagramReference: false,
    },
    sourceStatus: event.sourceStatus ?? (
      sourceUrl ? "source_backed" : "missing_source_url"
    ),
    publishability: event.publishability ?? (
      sourceUrl ?
        "reviewable_needs_verification" :
        "lead_needs_source"
    ),
    dedupe: event.dedupe ?? {
      normalizedEventKey:
        String(event.normalizedEventKey ?? event.id),
      canonicalCandidateId: String(event.id),
      duplicateCandidateIds: [],
    },
    score: Number.isFinite(event.score) ? event.score : 0,
    warnings: boundedProjectionStringArray(event.warnings, "warnings"),
    blockerCodes: boundedProjectionStringArray(
      event.blockerCodes,
      "blockerCodes"
    ),
    publicationEligibility: "review_gated",
  };
}

function eventSourceResultProjection(result) {
  return {
    id: boundedProjectionString(result.id, {field: "id"}),
    sourceProfileId: boundedProjectionString(
      result.sourceProfileId ?? "unknown_source",
      {field: "sourceProfileId"}
    ),
    sourceLabel: boundedProjectionString(result.sourceLabel ?? "Source", {
      field: "sourceLabel",
    }),
    queryTemplateId: boundedProjectionString(
      result.queryTemplateId ?? "operations",
      {field: "queryTemplateId"}
    ),
    resultType: boundedProjectionString(
      result.resultType ?? "source_result",
      {field: "resultType"}
    ),
    title: boundedProjectionString(result.title ?? result.id, {
      field: "title",
    }),
    url: boundedProjectionString(result.url ?? "", {
      field: "url",
      allowEmpty: true,
      maximum: 2_000,
    }),
    snippet: boundedProjectionString(result.snippet ?? "", {
      field: "snippet",
      allowEmpty: true,
      maximum: 1_000,
    }),
    observedAt: boundedProjectionString(result.observedAt ?? "", {
      field: "observedAt",
      allowEmpty: true,
      maximum: 80,
    }),
    status: boundedProjectionString(result.status ?? "needs_review", {
      field: "status",
    }),
    riskFlags: boundedProjectionStringArray(
      result.riskFlags,
      "riskFlags"
    ),
    operatorNotes: boundedProjectionString(result.operatorNotes ?? "", {
      field: "operatorNotes",
      allowEmpty: true,
      maximum: 1_000,
    }),
  };
}

function eventSourceProfileProjection(profile) {
  return {
    id: boundedProjectionString(profile.sourceProfileId, {field: "id"}),
    label: boundedProjectionString(profile.label, {field: "label"}),
    type: boundedProjectionString(profile.sourceTier, {field: "type"}),
    status: boundedProjectionString(profile.status, {field: "status"}),
    cadence:
      profile.sourceProfileId === "luma" ? "daily" : "weekly",
    riskLevel:
      profile.publication?.discoveryOnly ? "medium" : "low",
    allowedUse: boundedProjectionString(profile.allowedUse, {
      field: "allowedUse",
    }),
    items: [],
  };
}

function boundedProjectionString(
  value,
  {field, allowEmpty = false, maximum = 500}
) {
  invariant(
    typeof value === "string" && (allowEmpty || value.length > 0),
    "INVALID_EVENT_INTAKE_PROJECTION",
    `Event Intake ${field} must be ${allowEmpty ? "a" : "a non-empty"} string.`,
    {field}
  );
  return value.slice(0, maximum);
}

function boundedProjectionStringArray(value, field) {
  if (value === undefined) return [];
  invariant(
    Array.isArray(value),
    "INVALID_EVENT_INTAKE_PROJECTION",
    `Event Intake ${field} must be an array.`,
    {field}
  );
  return value.slice(0, 40).map((entry, index) =>
    boundedProjectionString(entry, {field: `${field}[${index}]`}));
}

function workItemForOrganizer(packet, context) {
  return baseWorkItem({
    ...context,
    entityKind: "organizer",
    id: packet.entityId ?? packet.canonicalHostId,
    title: packet.displayName,
    source: {
      sourceProfileId: "organizer_intake",
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
    adminProjection: {
      recordType: "organizer_publication_packet",
      packet: organizerPacketProjection(packet),
    },
  });
}

function workItemForOrganizerCandidate(candidate, context) {
  const reviewContext = context.reviewContext ?? null;
  const reviewArtifact = context.reviewArtifact;
  const citations = [
    candidate.canonicalUrl,
    candidate.url,
    ...(reviewContext?.sources ?? []),
  ].filter(Boolean);
  return baseWorkItem({
    ...context,
    entityKind: "organizer",
    id: candidate.candidateId,
    title: candidate.title,
    source: {
      sourceProfileId: `organizer_discovery:${candidate.platform}`,
      label: candidate.platform,
      url: candidate.canonicalUrl ?? candidate.url ?? null,
      artifactRef: context.artifact.relativePath,
    },
    evidence: evidenceForOrganizerCandidate({
      candidateArtifact: context.artifact,
      reviewArtifact,
      candidate,
      reviewContext,
      citations,
    }),
    raw: reviewContext ? {...candidate, reviewContext} : candidate,
    adminProjection: {
      recordType: "organizer_search_candidate",
      candidate: organizerCandidateProjection(candidate, reviewContext),
    },
    observedAt: dateAtUtc(candidate.observedAt),
  });
}

function organizerCandidateProjection(candidate, reviewContext = null) {
  return {
    candidateId: candidate.candidateId,
    batchId: candidate.batchId,
    resultId: candidate.resultId,
    rank: candidate.rank,
    query: candidate.query,
    queryIntent: candidate.queryIntent,
    observedAt: candidate.observedAt,
    title: candidate.title,
    snippet: candidate.snippet ?? null,
    url: candidate.url,
    canonicalUrl: candidate.canonicalUrl,
    platform: candidate.platform,
    surfaceKind: candidate.surfaceKind,
    normalizedKey: candidate.normalizedKey ?? null,
    suggestedSurface: candidate.suggestedSurface,
    existingEntityMatches: candidate.existingEntityMatches ?? [],
    reviewAction: candidate.reviewAction,
    diagnostics: candidate.diagnostics ?? [],
    ...(reviewContext ? {reviewContext} : {}),
  };
}

function organizerPacketProjection(packet) {
  const entityId = boundedPacketString(
    packet.entityId ?? packet.canonicalHostId,
    "entityId"
  );
  const currentDecision = packet.adminDecision?.currentDecision;
  const projection = {
    packetId: boundedPacketString(packet.packetId, "packetId"),
    entityId,
    canonicalHostId: boundedPacketString(
      packet.canonicalHostId ?? entityId,
      "canonicalHostId"
    ),
    displayName: boundedPacketString(packet.displayName, "displayName"),
    status: boundedPacketString(packet.status, "status"),
    priority: boundedPacketString(packet.priority, "priority"),
    markets: boundedPacketMarkets(packet.identity?.geography?.markets),
    blockers: boundedPacketStringList(
      packet.blockers,
      "blockers",
      ORGANIZER_PACKET_LIST_LIMIT
    ),
    dataBlockers: boundedPacketStringList(
      packet.dataBlockers,
      "dataBlockers",
      ORGANIZER_PACKET_LIST_LIMIT
    ),
    evidenceBlockers: boundedPacketStringList(
      packet.evidenceBlockers,
      "evidenceBlockers",
      ORGANIZER_PACKET_LIST_LIMIT
    ),
    approvalChecklist: Object.fromEntries(
      ORGANIZER_PACKET_APPROVAL_CHECKS.map((key) => {
        invariant(
          typeof packet.approvalChecklist?.[key] === "boolean",
          "INVALID_ORGANIZER_PACKET_PROJECTION",
          `Organizer packet approvalChecklist.${key} must be boolean.`,
          {entityId, key}
        );
        return [key, packet.approvalChecklist[key]];
      })
    ),
    evidenceSummary: {
      records: boundedPacketCount(
        packet.evidenceSummary?.records,
        "evidenceSummary.records"
      ),
      manualReportsWithoutArtifacts: boundedPacketCount(
        packet.evidenceSummary?.manualReportsWithoutArtifacts,
        "evidenceSummary.manualReportsWithoutArtifacts"
      ),
      unresolvedLocalRefs: boundedPacketCount(
        packet.evidenceSummary?.unresolvedLocalRefs,
        "evidenceSummary.unresolvedLocalRefs"
      ),
      missingSurfaceEvidence: boundedPacketCount(
        packet.evidenceSummary?.missingSurfaceEvidence,
        "evidenceSummary.missingSurfaceEvidence"
      ),
      rawProviderArtifactRefs: boundedPacketCount(
        packet.evidenceSummary?.rawProviderArtifactRefs,
        "evidenceSummary.rawProviderArtifactRefs"
      ),
      firestoreForbiddenArtifactRefs: boundedPacketCount(
        packet.evidenceSummary?.firestoreForbiddenArtifactRefs,
        "evidenceSummary.firestoreForbiddenArtifactRefs"
      ),
      riskFlags: boundedPacketStringList(
        packet.evidenceSummary?.riskFlags,
        "evidenceSummary.riskFlags",
        ORGANIZER_PACKET_SHORT_LIST_LIMIT
      ),
    },
    publicPresence: {
      canonicalPath: boundedNullablePacketString(
        packet.publicPresence?.canonicalPath,
        "publicPresence.canonicalPath"
      ),
      claimTargetPath: boundedNullablePacketString(
        packet.publicPresence?.claimTargetPath,
        "publicPresence.claimTargetPath"
      ),
      publishStatus: boundedPacketString(
        packet.publicPresence?.publishStatus,
        "publicPresence.publishStatus"
      ),
      indexStatus: boundedPacketString(
        packet.publicPresence?.indexStatus,
        "publicPresence.indexStatus"
      ),
      appVisibility: boundedPacketString(
        packet.publicPresence?.appVisibility,
        "publicPresence.appVisibility"
      ),
      projectionStatus: boundedPacketString(
        packet.publicPresence?.projectionStatus,
        "publicPresence.projectionStatus"
      ),
    },
    adminDecision: {
      allowedDecisions: boundedPacketStringList(
        packet.adminDecision?.allowedDecisions,
        "adminDecision.allowedDecisions",
        ORGANIZER_PACKET_LIST_LIMIT
      ),
      defaultAppVisibility: boundedPacketString(
        packet.adminDecision?.defaultAppVisibility,
        "adminDecision.defaultAppVisibility"
      ),
      currentDecision: currentDecision ? {
        decision: boundedPacketString(
          currentDecision.decision,
          "adminDecision.currentDecision.decision"
        ),
        publishStatus: boundedPacketString(
          currentDecision.publishStatus,
          "adminDecision.currentDecision.publishStatus"
        ),
        indexStatus: boundedPacketString(
          currentDecision.indexStatus,
          "adminDecision.currentDecision.indexStatus"
        ),
        decidedAt: boundedPacketString(
          currentDecision.decidedAt,
          "adminDecision.currentDecision.decidedAt"
        ),
        appVisibility: boundedPacketString(
          currentDecision.appVisibility,
          "adminDecision.currentDecision.appVisibility"
        ),
      } : null,
    },
    nextActions: boundedPacketStringList(
      packet.nextActions,
      "nextActions",
      ORGANIZER_PACKET_SHORT_LIST_LIMIT
    ),
  };
  assertBoundedPacketProjection(projection);
  return projection;
}

function boundedPacketString(value, field) {
  invariant(
    typeof value === "string" && value.length > 0,
    "INVALID_ORGANIZER_PACKET_PROJECTION",
    `Organizer packet ${field} must be a non-empty string.`,
    {field}
  );
  return value.slice(0, ORGANIZER_PACKET_STRING_LIMIT);
}

function boundedNullablePacketString(value, field) {
  if (value === null) return null;
  return boundedPacketString(value, field);
}

function boundedPacketStringList(value, field, maxItems) {
  invariant(
    Array.isArray(value),
    "INVALID_ORGANIZER_PACKET_PROJECTION",
    `Organizer packet ${field} must be an array.`,
    {field}
  );
  return value.slice(0, maxItems).map((entry, index) =>
    boundedPacketString(entry, `${field}[${index}]`));
}

function boundedPacketCount(value, field) {
  invariant(
    Number.isSafeInteger(value) && value >= 0,
    "INVALID_ORGANIZER_PACKET_PROJECTION",
    `Organizer packet ${field} must be a non-negative safe integer.`,
    {field}
  );
  return value;
}

function boundedPacketMarkets(value) {
  invariant(
    Array.isArray(value),
    "INVALID_ORGANIZER_PACKET_PROJECTION",
    "Organizer packet identity.geography.markets must be an array."
  );
  return value.slice(0, ORGANIZER_PACKET_MARKET_LIMIT).map((market, index) => {
    invariant(
      market && typeof market === "object" && !Array.isArray(market),
      "INVALID_ORGANIZER_PACKET_PROJECTION",
      `Organizer packet market ${index} must be an object.`
    );
    return {
      slug: boundedPacketString(
        market.marketSlug,
        `markets[${index}].slug`
      ),
      displayName: boundedPacketString(
        market.displayName,
        `markets[${index}].displayName`
      ),
    };
  });
}

function assertBoundedPacketProjection(value, path = "") {
  if (Array.isArray(value)) {
    const containsObjects = value.some((entry) =>
      entry && typeof entry === "object");
    invariant(
      !containsObjects || path === "markets",
      "INVALID_ORGANIZER_PACKET_PROJECTION",
      `Organizer packet projection has a nested object array at ${path}.`,
      {path}
    );
    value.forEach((entry, index) =>
      assertBoundedPacketProjection(entry, `${path}[${index}]`));
    return;
  }
  if (!value || typeof value !== "object") return;
  for (const [key, entry] of Object.entries(value)) {
    assertBoundedPacketProjection(entry, path ? `${path}.${key}` : key);
  }
}

function organizerReviewPolicySnapshot(reviewPolicy) {
  if (!reviewPolicy) return null;
  return {
    shortlistId: reviewPolicy.shortlistId ?? null,
    generatedAt: reviewPolicy.generatedAt ?? null,
    target: reviewPolicy.target ?? null,
    summary: reviewPolicy.summary ?? null,
    publicationPolicy: reviewPolicy.publicationPolicy ?? null,
    recordStatusDefinitions: reviewPolicy.recordStatusDefinitions ?? null,
  };
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
    basis: event.sourceUrl ?
      "normalized_candidate_with_source" :
      "normalized_lead_missing_source",
    ruleIds: ["event-source-required-v1", "event-expiry-v1", "event-dedupe-flag-v1"],
    reason: primaryStage === "resolve" ? "deterministic_blockers_found" : "deterministic_verification_pending",
    now,
  });
}

function reviewOrphanEvent(item, now) {
  return outcome(item, {
    primaryStage: "resolve",
    lifecycleStatus: item.lifecycleStatus,
    blockers: uniqueSorted([
      ...(item.raw.blockers ?? []),
      "organizer_not_in_inventory",
    ]),
    taskFlags: [
      "organizer_attribution",
      "event_crawl_todo",
    ],
    owner: "human",
    overall: item.source.url ? 0.62 : 0.25,
    basis: "source_backed_orphan_event",
    ruleIds: [
      "orphan-event-attribution-required-v1",
      "orphan-event-publication-block-v1",
    ],
    reason: "organizer_attribution_required",
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
    basis: approved ?
      "reviewed_admin_approval" :
      "normalized_publication_packet",
    ruleIds: ["organizer-publication-packet-v1"],
    reason: blockers.length > 0 ?
      "organizer_packet_blocked" :
      approved ?
        "reviewed_approval_verified" :
        "organizer_decision_pending",
    now,
  });
}

function reviewOrganizerCandidate(item, now) {
  const candidate = item.adminProjection?.candidate ?? item.raw;
  const blockers = [];
  const taskFlags = ["organizer_candidate_review"];
  if (!candidate.canonicalUrl) blockers.push("source_url_missing");
  if (!candidate.normalizedKey) blockers.push("organizer_identity_missing");
  if ((candidate.diagnostics ?? []).length > 0) {
    taskFlags.push("source_verification");
  }
  if ((candidate.existingEntityMatches ?? []).length > 0) {
    taskFlags.push("possible_existing_organizer");
  }
  const primaryStage = blockers.length > 0 ? "resolve" : "incoming";
  return outcome(item, {
    primaryStage,
    blockers,
    taskFlags,
    owner: "human",
    overall: candidate.normalizedKey && candidate.canonicalUrl ? 0.55 : 0.25,
    basis: "normalized_organizer_search_candidate",
    ruleIds: ["organizer-search-candidate-v1"],
    reason: blockers.length > 0 ?
      "organizer_candidate_blocked" :
      "organizer_candidate_review_pending",
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
    basis: operationsOwned ?
      "versioned_operations_profile" :
      "normalized_source_profile",
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
      actorId: `supply-intake-v${SUPPLY_INTAKE_WORKFLOW_VERSION}`,
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
    provenanceStatus: "operations_input_snapshot",
  };
}

function evidenceForOrganizerCandidate({
  candidateArtifact,
  reviewArtifact,
  candidate,
  reviewContext,
  citations,
}) {
  const artifacts = [
    {
      relativePath: candidateArtifact.relativePath,
      sha256: candidateArtifact.sha256,
    },
    ...(reviewContext && reviewArtifact ? [{
      relativePath: reviewArtifact.relativePath,
      sha256: reviewArtifact.sha256,
    }] : []),
  ];
  return {
    artifactRef: artifacts.map((artifact) => artifact.relativePath).join(" + "),
    artifactHash: hashValue({artifacts, candidate, reviewContext}),
    citations: uniqueSorted(citations),
    provenanceStatus: reviewContext ?
      "reviewed_operations_input" : "operations_input_snapshot",
  };
}

function sourceProfileForEvent(event) {
  try {
    const host = new URL(event.sourceUrl).hostname.toLowerCase();
    if (host === "lu.ma" || host.endsWith(".lu.ma") || host === "luma.com" || host.endsWith(".luma.com")) return "luma";
    if (host === "cntraveller.in" || host.endsWith(".cntraveller.in")) return "cntraveller";
    return `web:${host}`;
  } catch {
    return "unknown_source";
  }
}

function endOfDate(value) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value ?? "")) return null;
  return `${value}T23:59:59.999Z`;
}

function dateAtUtc(value) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value ?? "")) return value ?? null;
  return `${value}T00:00:00.000Z`;
}

function dateOnly(value) {
  const parsed = String(value ?? "");
  return /^\d{4}-\d{2}-\d{2}/.test(parsed) ? parsed.slice(0, 10) : "";
}

function timeOnly(value) {
  const parsed = Date.parse(value);
  if (Number.isNaN(parsed)) return "";
  return new Date(parsed).toISOString().slice(11, 16);
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
