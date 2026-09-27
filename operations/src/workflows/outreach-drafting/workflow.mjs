import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import Ajv from "ajv";
import addFormats from "ajv-formats";
import {hashValue} from "../../platform/canonical-json.mjs";
import {assertWorkItem as assertPlatformWorkItem} from "../../platform/contracts.mjs";
import {OperationsEngine} from "../../platform/engine.mjs";
import {invariant} from "../../platform/errors.mjs";
import {GuardedModelRunner, modelCachePort} from "../../platform/model/guarded-model-runner.mjs";

const repositoryRoot = fileURLToPath(new URL("../../../../", import.meta.url));
export const OUTREACH_DRAFTING_DEFINITION = Object.freeze(JSON.parse(
  fs.readFileSync(new URL("./manifest.json", import.meta.url), "utf8")
));
const zeroUsage = Object.freeze({inputTokens: 0, outputTokens: 0, costMicros: 0});

/** Private, draft-only workflow. The trusted eligibility port is mandatory at execution. */
export class OutreachDraftingWorkflow {
  constructor({repoRoot = repositoryRoot, store = null, eligibilityPort = null,
    modelActivation = null, modelProvider = null, monthlyBudget = null,
    monthlyBudgetPort = null, monthlyWindow = null,
    clock = () => new Date()} = {}) {
    Object.assign(this, {
      workflowId: OUTREACH_DRAFTING_DEFINITION.workflowId,
      version: OUTREACH_DRAFTING_DEFINITION.version,
      primaryStages: OUTREACH_DRAFTING_DEFINITION.primaryStages,
      lifecycleStatuses: OUTREACH_DRAFTING_DEFINITION.lifecycleStatuses,
      lifecycleSemantics: OUTREACH_DRAFTING_DEFINITION.lifecycleSemantics,
      entityKinds: OUTREACH_DRAFTING_DEFINITION.entityKinds,
      allowedTransitions: OUTREACH_DRAFTING_DEFINITION.allowedTransitions,
      repoRoot, store, eligibilityPort, modelActivation, modelProvider,
      monthlyBudget, monthlyBudgetPort, monthlyWindow, clock,
    });
    this.validators = null;
  }

  planningContext({inputPath}) {
    invariant(typeof inputPath === "string", "OUTREACH_INPUT_REQUIRED",
      "A private reviewed input file is required for a draft plan.");
    const file = path.resolve(inputPath);
    const initial = fs.lstatSync(file);
    invariant(initial.isFile() && !initial.isSymbolicLink() &&
      initial.size <= 500_000,
    "OUTREACH_INPUT_INVALID_FILE", "Input must be a bounded regular file.");
    const fd = fs.openSync(file, fs.constants.O_RDONLY |
      fs.constants.O_NOFOLLOW | fs.constants.O_NONBLOCK);
    try {
      const opened = fs.fstatSync(fd);
      invariant(opened.isFile() && opened.size <= 500_000,
        "OUTREACH_INPUT_INVALID_FILE", "Input must be a bounded regular file.");
      return {inputs: JSON.parse(fs.readFileSync(fd, "utf8"))};
    } finally {
      fs.closeSync(fd);
    }
  }

  createPlan({inputs, now}) {
    invariant(Array.isArray(inputs) && inputs.length > 0 &&
      inputs.length <= OUTREACH_DRAFTING_DEFINITION.maxWorkItemsPerRun,
    "INVALID_OUTREACH_INPUT", "A draft plan needs 1–50 input snapshots.");
    const generatedAt = new Date(now).toISOString();
    const identities = new Set();
    for (const input of inputs) {
      this.assertInput(input);
      invariant(Date.parse(input.evaluatedAt) === Date.parse(generatedAt),
        "OUTREACH_CLOCK_MISMATCH", "Input and plan evaluation times must match.");
      const identity = draftIdentity(input);
      invariant(!identities.has(identity), "DUPLICATE_OUTREACH_DRAFT",
        "A plan may contain one draft per contact, opportunity and purpose.");
      identities.add(identity);
    }
    const modelBudget = this.activationBudget(inputs.length);
    const basis = {
      schemaVersion: 1, workflowId: this.workflowId, workflowVersion: this.version,
      mode: "shadow", generatedAt,
      workflowContract: {
        primaryStages: this.primaryStages,
        lifecycleStatuses: this.lifecycleStatuses,
        lifecycleSemantics: this.lifecycleSemantics,
        entityKinds: this.entityKinds,
        allowedTransitions: this.allowedTransitions,
      },
      inputs: structuredClone(inputs).sort((a, b) => draftIdentity(a).localeCompare(draftIdentity(b))),
      modelPolicy: this.modelActivation ? {
        policyDecisionId: this.modelActivation.policyDecisionId,
        modelId: this.modelActivation.modelId,
        monthlyWindow: this.monthlyWindow,
        monthlyLimitsHash: hashValue(this.monthlyBudget.snapshot().limits),
        estimatedInputTokens: this.modelActivation.estimatedInputTokens,
        maxOutputTokens: this.modelActivation.maxOutputTokens,
        maxCostMicros: this.modelActivation.maxCostMicros,
      } : null,
      capabilities: {network: false, modelCalls: modelBudget.modelCalls > 0,
        publicWrites: false, ruleDeployment: false},
      budgets: {workItems: inputs.length, networkRequests: 0, ...modelBudget,
        publicWrites: 0},
    };
    const basisHash = hashValue(basis);
    return {...basis, basisHash, planId: `outreach-${basisHash}`};
  }

  assertPlan(plan) {
    invariant(plan?.workflowId === this.workflowId, "INVALID_OUTREACH_PLAN",
      "Plan belongs to a different workflow.");
    const expected = this.createPlan({inputs: plan.inputs, now: plan.generatedAt});
    invariant(hashValue(plan) === hashValue(expected), "OUTREACH_PLAN_DRIFT",
      "Frozen identity, inputs, capabilities or budgets changed.");
    return plan;
  }

  project(plan, {runId, now}) {
    this.assertPlan(plan);
    return plan.inputs.map((input) => this.assertWorkItem({
      schemaVersion: 1,
      workItemId: `wi-${hashValue([runId, draftIdentity(input)])}`,
      runId, workflowId: this.workflowId, entityKind: "outreach_draft",
      sourceEntity: {id: draftIdentity(input), title: "Private outreach draft"},
      primaryStage: "drafting", lifecycleStatus: "active", owner: "system",
      taskFlags: [], blockers: [],
      decisionProvenance: {actorKind: "deterministic", actorId: this.workflowId,
        decision: "pending", decidedAt: now, inputHash: hashValue(input),
        model: null, ruleIds: ["approved-clauses-v1"]},
      confidence: {overall: 1, basis: "approved_clause_snapshot",
        calibrated: false, fieldConfidence: {}},
      evidence: {planId: plan.planId, inputHash: hashValue(input),
        artifactHash: hashValue(input), artifactRef: null, citations: [],
        provenanceStatus: "private_snapshot"},
      source: {kind: "sales_snapshot"},
      timestamps: {observedAt: input.evaluatedAt, evidenceStaleAt: null},
      raw: {kind: "outreachDraft", input: structuredClone(input)},
      expiresAt: null, stageHistory: [], createdAt: now, updatedAt: now,
    }));
  }

  async review(item, {now, budget, persistBudget, recordReviewAction}) {
    this.assertWorkItem(item);
    const input = item.raw.input;
    await this.assertCurrent(input);
    const eligible = eligibleClauses(input, this.clock().toISOString());
    if (!eligible.ok) return blockedOutcome(item, now, eligible.reason);
    let selection;
    let model = {modelId: "deterministic", promptVersion: input.policy.promptVersion,
      playbookVersion: input.policy.playbookVersion, cacheHit: false, usage: zeroUsage};
    if (this.modelActivation) {
      invariant(budget && this.store?.getModelCache && this.store?.putModelCache,
        "OUTREACH_MODEL_RUNTIME_REQUIRED", "A durable model cache and run budget are required.");
      invariant(typeof persistBudget === "function" &&
        typeof recordReviewAction === "function",
      "OUTREACH_MODEL_RUNTIME_REQUIRED",
      "Model calls require the leased engine's budget and receipt hooks.");
      invariant(this.monthlyBudget?.snapshot && /^\d{4}-\d{2}$/.test(this.monthlyWindow ?? ""),
        "OUTREACH_MONTHLY_BUDGET_REQUIRED", "A reviewed monthly budget is required.");
      invariant(this.monthlyWindow === this.clock().toISOString().slice(0, 7),
        "OUTREACH_MONTHLY_BUDGET_REQUIRED", "Monthly model budget window is stale.");
      invariant(this.modelProvider?.run && this.modelActivation.reviewed === true &&
        input.policy.modelId === this.modelActivation.modelId,
      "OUTREACH_MODEL_DISABLED", "Model activation must be reviewed and version-bound.");
      const request = {task: "outreach-clause-selection",
        promptVersion: input.policy.promptVersion,
        input: {organizerId: input.organizer.organizerId,
          contactId: input.contact.contactId,
          opportunityId: input.opportunity.opportunityId,
          language: input.language, purpose: input.purpose, channel: input.channel,
          playbookVersion: input.policy.playbookVersion,
          inputHash: hashValue(input),
          stage: input.opportunity.stage, motion: input.opportunity.motion,
          observationOptions: eligible.observations.map(clauseOption),
          capabilityOptions: eligible.capabilities.map(clauseOption),
          referenceOptions: eligible.references.map(clauseOption),
          ctaOptions: input.ctas.map(clauseOption),
          priorInteraction: input.priorInteraction},
        outputSchema: this.selectionSchema(),
        estimatedInputTokens: this.modelActivation.estimatedInputTokens,
        maxOutputTokens: this.modelActivation.maxOutputTokens,
        maxCostMicros: this.modelActivation.maxCostMicros};
      const cacheKey = hashValue({schemaVersion: 1, task: request.task,
        promptVersion: request.promptVersion,
        modelId: this.modelActivation.modelId,
        input: request.input, outputSchema: request.outputSchema});
      const attemptId = `model-attempt-${hashValue([item.workItemId, cacheKey])}`;
      const reservation = {modelCalls: 1,
        modelInputTokens: request.estimatedInputTokens,
        modelOutputTokens: request.maxOutputTokens,
        modelCostMicros: request.maxCostMicros};
      const monthBefore = this.monthlyBudget.snapshot().consumed;
      const cached = await this.store.getModelCache(cacheKey);
      if (!cached) {
        const prior = (await this.store.listActions(item.runId)).find(
          (action) => action.actionId === attemptId);
        invariant(!prior, "OUTREACH_MODEL_ATTEMPT_UNCERTAIN",
          "A prior model attempt has no validated cache result; manual reconciliation is required.");
        invariant(budget.canConsume(reservation) &&
          this.monthlyBudget.canConsume(reservation),
        "OUTREACH_MODEL_BUDGET_EXCEEDED",
        "Run or monthly model allowance is exhausted.");
        await recordReviewAction("outreach.model_attempt_reserved",
          {workItemId: item.workItemId,
            inputHash: hashValue(input), cacheKey,
            modelId: this.modelActivation.modelId,
            policyDecisionId: this.modelActivation.policyDecisionId,
            reservation, disposition: "unknown_until_cache_or_manual_reconciliation"},
          attemptId);
      }
      const guardedProvider = {run: async (payload) => {
        // The runner has reserved both ledgers before calling this port.
        // Persist the conservative reservation before any provider I/O.
        invariant(this.monthlyWindow === this.clock().toISOString().slice(0, 7),
          "OUTREACH_MONTHLY_BUDGET_REQUIRED",
          "Monthly model budget window changed before provider reservation.");
        await persistBudget();
        await this.monthlyBudgetPort.reserveAttempt({attemptId,
          monthKey: this.monthlyWindow,
          limitsHash: hashValue(this.monthlyBudget.snapshot().limits),
          expectedConsumed: monthBefore, reservation});
        return this.modelProvider.run(payload);
      }};
      const runner = new GuardedModelRunner({enabled: true, provider: guardedProvider,
        cache: modelCachePort(this.store), budget, monthlyBudget: this.monthlyBudget,
        monthlyWindow: this.monthlyWindow, modelId: this.modelActivation.modelId});
      let response;
      try {
        response = await runner.run(request);
        if (!response.provenance.cacheHit) {
          await persistBudget();
          await this.monthlyBudgetPort.completeAttempt({attemptId,
            monthKey: this.monthlyWindow,
            usage: response.provenance.usage});
          await recordReviewAction("outreach.model_attempt_completed",
            {workItemId: item.workItemId, cacheKey,
              outputHash: hashValue(response.output),
              usage: response.provenance.usage},
            `model-completed-${hashValue([item.workItemId, cacheKey])}`);
        }
      } catch (error) {
        if (!cached) {
          await recordReviewAction("outreach.model_attempt_indeterminate",
            {workItemId: item.workItemId, cacheKey,
              failureCode: error?.code ?? "PROVIDER_OUTCOME_UNKNOWN",
              disposition: "manual_reconciliation_required"},
            `model-indeterminate-${hashValue([item.workItemId, cacheKey])}`)
            .catch(() => undefined);
        }
        throw error;
      }
      selection = response.output;
      model = {modelId: response.provenance.modelId,
        promptVersion: response.provenance.promptVersion,
        playbookVersion: input.policy.playbookVersion,
        cacheHit: response.provenance.cacheHit,
        usage: response.provenance.cacheHit ? zeroUsage : response.provenance.usage};
    } else {
      selection = {organizerId: input.organizer.organizerId,
        contactId: input.contact.contactId,
        opportunityId: input.opportunity.opportunityId,
        language: input.language,
        observationId: eligible.observations[0]?.id ?? null,
        capabilityId: eligible.capabilities[0]?.id ?? null,
        referenceId: null, ctaId: input.ctas[0]?.id ?? null,
        reasonToBlock: null, omittedIds: []};
    }
    await this.assertCurrent(input); // cache hits do not bypass current eligibility
    this.assertSelection(input, selection, eligible);
    if (selection.reasonToBlock) return blockedOutcome(item, now, "model_abstained");
    const draft = this.render(input, selection, model);
    return {primaryStage: "human_review", lifecycleStatus: "active",
      owner: "human", reason: "draft_requires_factual_and_tone_review",
      taskFlags: ["human_review_required"], blockers: [],
      confidence: item.confidence,
      decisionProvenance: {actorKind: model.modelId === "deterministic" ?
        "deterministic" : "model", actorId: this.workflowId,
        decision: "draft_proposed", decidedAt: now, inputHash: hashValue(input),
        model, ruleIds: ["approved-clauses-v1"], draft,
        effectDisposition: "draft_only_no_send"}};
  }

  async approveDraft(request) {
    invariant(this.contracts().approval(request), "INVALID_OUTREACH_APPROVAL",
      "Approval requires factual, tone and manual-channel review of exact text.");
    const {runId, workItemId, actorId, expectedContentHash} = request;
    invariant(this.store?.requireRun && this.store?.listWorkItems && this.store?.appendAction,
      "OUTREACH_STORE_REQUIRED", "Durable Operations store is required for approval.");
    invariant(typeof actorId === "string" && /^[A-Za-z0-9._:-]{1,160}$/.test(actorId),
      "OUTREACH_ACTOR_REQUIRED", "A reviewer identity is required.");
    const run = await this.store.requireRun(runId);
    invariant(run.workflowId === this.workflowId && run.status === "completed",
      "OUTREACH_RUN_NOT_READY", "A completed draft run is required.");
    await new OperationsEngine({store: this.store, workflow: this}).repairCompletedRun(runId);
    const item = (await this.store.listWorkItems({runId})).find(
      (entry) => entry.workItemId === workItemId);
    invariant(item, "OUTREACH_DRAFT_NOT_FOUND", "Draft work item not found.");
    this.assertWorkItem(item);
    const draft = item.decisionProvenance?.draft;
    invariant(item.primaryStage === "human_review" &&
      draft?.contentHash === expectedContentHash &&
      hashValue({subject: draft.subject, text: draft.text}) === draft.contentHash,
    "OUTREACH_DRAFT_CHANGED", "Approval must bind the exact saved draft text.");
    await this.assertCurrent(item.raw.input);
    const eligible = eligibleClauses(item.raw.input, this.clock().toISOString());
    invariant(eligible.ok, "OUTREACH_CLAUSE_EXPIRED",
      "Approved evidence or capability expired before approval.");
    this.assertSelection(item.raw.input, draft.selection, eligible);
    const actionId = `approval-${hashValue([workItemId, actorId, expectedContentHash])}`;
    const existing = (await this.store.listActions(runId)).find(
      (action) => action.actionId === actionId);
    if (existing) return existing;
    const approvedAt = this.clock().toISOString();
    return this.store.appendAction({schemaVersion: 1, actionId, runId,
      type: "outreach.draft_approved", at: approvedAt, actorId,
      payload: {workItemId, draftId: draft.draftId,
        exactContentHash: draft.contentHash, inputHash: draft.inputHash,
        sourceRevisions: draft.sourceRevisions,
        factualValidity: request.factualValidity, tone: request.tone,
        channelReadiness: request.channelReadiness,
        sendAuthority: false, providerConfirmed: false}});
  }

  assertInput(input) {
    invariant(this.contracts().input(input), "INVALID_OUTREACH_INPUT",
      "Input does not match the private drafting contract.");
    const ids = [input.organizer.organizerId, input.contact.contactId,
      input.opportunity.opportunityId,
      ...(input.priorInteraction ? [input.priorInteraction.activityId] : []),
      ...["observations", "capabilities", "references", "ctas"]
        .flatMap((key) => input[key].map((entry) => entry.id))];
    invariant(new Set(ids).size === ids.length, "DUPLICATE_OUTREACH_CLAUSE",
      "All approved clause and CTA ids must be unique.");
    invariant(input.purpose !== "follow_up" || input.priorInteraction,
      "OUTREACH_PRIOR_INTERACTION_REQUIRED", "Follow-ups require a real prior interaction.");
    for (const clause of [...input.observations, ...input.capabilities, ...input.references]) {
      invariant(clause.organizerId === input.organizer.organizerId,
        "OUTREACH_TARGET_MISMATCH", "Clause belongs to another organizer.");
    }
    return input;
  }

  assertWorkItem(item) {
    assertPlatformWorkItem(item);
    invariant(item.workflowId === this.workflowId &&
      item.raw?.kind === "outreachDraft" &&
      this.primaryStages.includes(item.primaryStage) &&
      this.lifecycleStatuses.includes(item.lifecycleStatus),
    "INVALID_OUTREACH_WORK_ITEM", "Work item belongs to another workflow.");
    this.assertInput(item.raw.input);
    invariant(item.evidence.inputHash === hashValue(item.raw.input) &&
      item.sourceEntity.id === draftIdentity(item.raw.input) &&
      item.workItemId === `wi-${hashValue([item.runId, draftIdentity(item.raw.input)])}`,
    "OUTREACH_EVIDENCE_DRIFT", "Work item identity or frozen input changed.");
    if (item.decisionProvenance?.draft) {
      invariant(this.contracts().draft(item.decisionProvenance.draft),
        "INVALID_OUTREACH_DRAFT", "Saved draft failed its strict contract.");
    }
    return item;
  }

  async assertCurrent(input) {
    invariant(this.eligibilityPort?.getCurrent,
      "OUTREACH_ELIGIBILITY_PORT_REQUIRED", "A trusted current eligibility port is required.");
    const current = await this.eligibilityPort.getCurrent({
      organizerId: input.organizer.organizerId,
      contactId: input.contact.contactId,
      opportunityId: input.opportunity.opportunityId,
    });
    invariant(current?.organizerId === input.organizer.organizerId &&
      current.organizerRevision === input.organizer.revision &&
      current.contactId === input.contact.contactId &&
      current.contactRevision === input.contact.revision &&
      current.opportunityId === input.opportunity.opportunityId &&
      current.opportunityRevision === input.opportunity.revision &&
      current.stage === input.opportunity.stage &&
      current.evidenceConflictStatus === input.evidenceConflictStatus &&
      current.promptVersion === input.policy.promptVersion &&
      current.playbookVersion === input.policy.playbookVersion &&
      current.identityStatus === "verified" &&
      current.contactEligible === true && current.suppressed === false &&
      current.capabilityClaimsEligible === true,
    "OUTREACH_CURRENT_ELIGIBILITY_CHANGED",
    "Identity, stage, contact, suppression or claim eligibility changed.");
    const revisions = current.approvedClauseRevisions ?? {};
    for (const clause of [...input.observations, ...input.capabilities, ...input.references]) {
      invariant(revisions[clause.id] === clause.revision,
        "OUTREACH_CLAUSE_CHANGED", "An approved source clause changed or lost approval.");
    }
    invariant(input.capabilities.every((entry) =>
      current.supportedCapabilityIds?.includes(entry.id)) &&
      input.references.every((entry) =>
        current.permittedReferenceIds?.includes(entry.id)),
    "OUTREACH_CLAUSE_INELIGIBLE", "Capability or reference permission changed.");
    invariant(input.ctas.every((entry) =>
      current.approvedCtaRevisions?.[entry.id] === entry.revision) &&
      (!input.priorInteraction ||
        current.priorInteractionRevision === input.priorInteraction.revision),
    "OUTREACH_CLAUSE_CHANGED", "CTA or prior interaction changed.");
  }

  assertSelection(input, selection, eligible) {
    invariant(this.contracts().selection(selection), "INVALID_OUTREACH_SELECTION",
      "Model selection failed its strict contract.");
    invariant(selection.organizerId === input.organizer.organizerId &&
      selection.contactId === input.contact.contactId &&
      selection.opportunityId === input.opportunity.opportunityId &&
      selection.language === input.language,
    "OUTREACH_TARGET_MISMATCH", "Model changed target identity or language.");
    const has = (rows, id) => id === null || rows.some((row) => row.id === id);
    invariant(has(eligible.observations, selection.observationId) &&
      has(eligible.capabilities, selection.capabilityId) &&
      has(eligible.references, selection.referenceId) &&
      has(input.ctas, selection.ctaId),
    "OUTREACH_UNKNOWN_CLAUSE", "Model selected an unknown or ineligible clause.");
    const allIds = new Set([...input.observations, ...input.capabilities,
      ...input.references, ...input.ctas].map((entry) => entry.id));
    invariant(selection.omittedIds.every((id) => allIds.has(id)),
      "OUTREACH_UNKNOWN_CLAUSE", "Model reported an unknown omitted clause.");
    invariant(selection.reasonToBlock ||
      (selection.observationId && selection.capabilityId && selection.ctaId),
    "OUTREACH_REQUIRED_CLAUSE_MISSING",
    "A draft requires a verified observation, supported capability and CTA.");
  }

  render(input, selection, model) {
    const locate = (rows, id) => rows.find((row) => row.id === id);
    const sentences = [];
    if (input.purpose === "follow_up") sentences.push({
      text: input.priorInteraction.summary, kind: "prior_interaction",
      sourceIds: [input.priorInteraction.activityId]});
    const add = (kind, clause) => sentences.push({text: clause.text, kind,
      sourceIds: [clause.id]});
    add("observation", locate(input.observations, selection.observationId));
    add("capability", locate(input.capabilities, selection.capabilityId));
    if (selection.referenceId) add("reference",
      locate(input.references, selection.referenceId));
    add("cta", locate(input.ctas, selection.ctaId));
    const text = sentences.map((sentence) => sentence.text).join("\n\n");
    const safeName = input.organizer.name.replace(/[\r\n]+/g, " ").trim().slice(0, 120);
    const subject = input.channel === "email" ? `A question for ${safeName}` : null;
    const contentHash = hashValue({subject, text});
    const sourceRevisions = Object.fromEntries([
      [input.organizer.organizerId, input.organizer.revision],
      [input.contact.contactId, input.contact.revision],
      [input.opportunity.opportunityId, input.opportunity.revision],
      ...[...input.observations, ...input.capabilities, ...input.references,
        ...input.ctas].map((clause) => [clause.id, clause.revision]),
      ...(input.priorInteraction ? [[input.priorInteraction.activityId,
        input.priorInteraction.revision]] : []),
    ]);
    const draft = {schemaVersion: 1,
      draftId: `draft-${hashValue([hashValue(input), selection, contentHash])}`,
      organizerId: input.organizer.organizerId,
      contactId: input.contact.contactId,
      opportunityId: input.opportunity.opportunityId,
      language: input.language, channel: input.channel, subject, text,
      sentences, selection, inputHash: hashValue(input), contentHash,
      sourceRevisions, model, reviewStatus: "pending_review", sendAuthority: false};
    invariant(this.contracts().draft(draft), "INVALID_OUTREACH_DRAFT",
      "Rendered draft failed its strict contract.");
    return draft;
  }

  activationBudget(itemCount) {
    if (!this.modelActivation) return {modelCalls: 0, modelInputTokens: 0,
      modelOutputTokens: 0, modelCostMicros: 0};
    const activation = this.modelActivation;
    invariant(activation.reviewed === true &&
      /^[A-Za-z0-9._:-]{1,160}$/.test(activation.policyDecisionId ?? "") &&
      this.modelProvider?.run &&
      typeof this.monthlyBudgetPort?.reserveAttempt === "function" &&
      typeof this.monthlyBudgetPort?.completeAttempt === "function" &&
      this.monthlyBudget?.snapshot && /^\d{4}-\d{2}$/.test(this.monthlyWindow ?? "") &&
      Number.isSafeInteger(activation.estimatedInputTokens) &&
      Number.isSafeInteger(activation.maxOutputTokens) &&
      Number.isSafeInteger(activation.maxCostMicros) &&
      activation.estimatedInputTokens > 0 &&
      activation.maxOutputTokens > 0 && activation.maxCostMicros > 0 &&
      Number.isSafeInteger(itemCount * activation.estimatedInputTokens) &&
      Number.isSafeInteger(itemCount * activation.maxOutputTokens) &&
      Number.isSafeInteger(itemCount * activation.maxCostMicros),
    "OUTREACH_MODEL_DISABLED", "A reviewed model, provider and explicit budgets are required.");
    const monthLimits = this.monthlyBudget.snapshot().limits;
    invariant(["modelCalls", "modelInputTokens", "modelOutputTokens",
      "modelCostMicros"].every((key) => monthLimits[key] > 0),
    "OUTREACH_MONTHLY_BUDGET_REQUIRED",
    "Every monthly model ceiling must be explicitly positive.");
    return {modelCalls: itemCount,
      modelInputTokens: itemCount * activation.estimatedInputTokens,
      modelOutputTokens: itemCount * activation.maxOutputTokens,
      modelCostMicros: itemCount * activation.maxCostMicros};
  }

  selectionSchema() { return this.schema("outreach_drafting_selection.schema.json"); }
  schema(file) { return JSON.parse(fs.readFileSync(path.join(this.repoRoot,
    "contracts", "operations", file), "utf8")); }
  contracts() {
    if (this.validators) return this.validators;
    const ajv = new Ajv({allErrors: true, strict: false});
    addFormats(ajv);
    ajv.addSchema(this.selectionSchema());
    this.validators = {
      input: ajv.compile(this.schema("outreach_drafting_input.schema.json")),
      selection: ajv.getSchema("https://catch.app/contracts/operations/outreach_drafting_selection.schema.json"),
      draft: ajv.compile(this.schema("outreach_drafting_draft.schema.json")),
      approval: ajv.compile(this.schema("outreach_drafting_approval.schema.json")),
    };
    return this.validators;
  }
}

function draftIdentity(input) {
  return hashValue([input.organizer.organizerId, input.contact.contactId,
    input.opportunity.opportunityId, input.purpose, input.channel]);
}
function clauseOption(clause) { return {id: clause.id, text: clause.text}; }
function eligibleClauses(input, now) {
  if (input.evidenceConflictStatus !== "clear") {
    return {ok: false, reason: "conflicting_evidence_review_needed"};
  }
  const fresh = (clause) => Date.parse(clause.validUntil) > Date.parse(now);
  const observations = input.observations.filter(fresh);
  const capabilities = input.capabilities.filter(fresh);
  const references = input.references.filter(fresh);
  if (!observations.length) return {ok: false, reason: "research_needed"};
  if (!capabilities.length) return {ok: false, reason: "capability_review_needed"};
  return {ok: true, observations, capabilities, references};
}
function blockedOutcome(item, now, reason) {
  return {primaryStage: "blocked", lifecycleStatus: "blocked", owner: "human",
    reason, taskFlags: ["human_review_required"], blockers: [reason],
    confidence: item.confidence,
    decisionProvenance: {actorKind: "deterministic", actorId: "outreach-drafting",
      decision: "blocked", decidedAt: now,
      inputHash: hashValue(item.raw.input), model: null,
      ruleIds: ["approved-clauses-v1"], effectDisposition: "no_draft_no_send"}};
}
