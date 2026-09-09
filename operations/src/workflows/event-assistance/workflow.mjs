import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import Ajv from "ajv";
import addFormats from "ajv-formats";
import {hashValue} from "../../platform/canonical-json.mjs";
import {assertWorkItem as assertPlatformWorkItem} from "../../platform/contracts.mjs";
import {invariant} from "../../platform/errors.mjs";
import {EVENT_ASSISTANCE_DEFINITION as definition} from "./definition.mjs";
import {
  assertLateJoinContext,
  evaluateLateJoinPolicy,
} from "./generated/late-join.mjs";

const defaultRepoRoot = fileURLToPath(new URL("../../../../", import.meta.url));

/** Registered snapshot evaluation; live dispatch requires the trusted worker. */
export class EventAssistanceWorkflow {
  constructor({repoRoot = defaultRepoRoot} = {}) {
    this.workflowId = definition.workflowId;
    this.version = definition.version;
    this.primaryStages = definition.primaryStages;
    this.lifecycleStatuses = definition.lifecycleStatuses;
    this.lifecycleSemantics = definition.lifecycleSemantics;
    this.entityKinds = definition.entityKinds;
    this.allowedTransitions = definition.allowedTransitions;
    this.repoRoot = repoRoot;
    this.validators = null;
  }

  planningContext({inputPath}) {
    invariant(typeof inputPath === "string", "ASSISTANCE_INPUT_REQUIRED",
      "Event assistance needs --input with a JSON array of late-join snapshots.");
    const file = path.resolve(inputPath);
    invariant(fs.statSync(file).size <= 2_000_000, "ASSISTANCE_INPUT_TOO_LARGE",
      "Split assistance snapshots into input files of at most 2 MB.");
    return {inputs: JSON.parse(fs.readFileSync(file, "utf8"))};
  }

  createPlan({inputs, now}) {
    invariant(Array.isArray(inputs) && inputs.length > 0 &&
      inputs.length <= definition.maxWorkItemsPerRun, "INVALID_ASSISTANCE_INPUT",
    "A plan needs 1–10,000 bounded late-join snapshots.");
    const generatedAt = new Date(now).toISOString();
    const identities = new Set();
    let contextHash = null;
    for (const input of inputs) {
      this.assertInput(input);
      const identity = episodeIdentity(input);
      invariant(!identities.has(identity), "DUPLICATE_ASSISTANCE_EPISODE",
        "An event guest episode can occur only once in a snapshot plan.");
      identities.add(identity);
      const candidateContext = hashValue(input.context);
      invariant(contextHash === null || contextHash === candidateContext,
        "ASSISTANCE_CONTEXT_MISMATCH", "A run must have one event and context.");
      contextHash = candidateContext;
      invariant(input.now === Date.parse(generatedAt), "ASSISTANCE_CLOCK_MISMATCH",
        "Snapshot inputs must use the plan evaluation time.");
    }
    const basis = {
      schemaVersion: 1,
      workflowId: this.workflowId,
      workflowVersion: this.version,
      mode: "shadow",
      generatedAt,
      workflowContract: {
        primaryStages: this.primaryStages,
        lifecycleStatuses: this.lifecycleStatuses,
        lifecycleSemantics: this.lifecycleSemantics,
        entityKinds: this.entityKinds,
        allowedTransitions: this.allowedTransitions,
      },
      inputs: structuredClone(inputs).sort((a, b) =>
        episodeIdentity(a).localeCompare(episodeIdentity(b))),
      capabilities: {...definition.capabilities},
      budgets: {
        workItems: inputs.length, networkRequests: 0, modelCalls: 0,
        modelInputTokens: 0, modelOutputTokens: 0, modelCostMicros: 0,
        publicWrites: 0,
      },
    };
    const basisHash = hashValue(basis);
    return {...basis, basisHash, planId: "assistance-" + basisHash};
  }

  assertPlan(plan) {
    invariant(plan && typeof plan === "object", "INVALID_ASSISTANCE_PLAN",
      "An assistance plan is required.");
    const expected = this.createPlan({inputs: plan.inputs, now: plan.generatedAt});
    invariant(hashValue(plan) === hashValue(expected), "ASSISTANCE_PLAN_DRIFT",
      "Plan identity, scope, capabilities and budget must match frozen evidence.");
    return plan;
  }

  project(plan, {runId, now}) {
    this.assertPlan(plan);
    return plan.inputs.map((input) => {
      const id = episodeIdentity(input);
      return this.assertWorkItem({
        schemaVersion: 1,
        workItemId: "wi-" + hashValue([runId, id]),
        runId,
        workflowId: this.workflowId,
        entityKind: "guest_episode",
        sourceEntity: {id, title: "Late-arrival assistance"},
        primaryStage: "evaluating",
        lifecycleStatus: "active",
        owner: "system",
        taskFlags: [],
        blockers: [],
        decisionProvenance: {
          actorKind: "deterministic", actorId: this.workflowId,
          decision: "awaiting_evaluation", decidedAt: now,
          inputHash: hashValue(input), model: null,
          ruleIds: ["late-join-v1"],
        },
        confidence: {overall: 1, basis: "validated_snapshot",
          calibrated: false, fieldConfidence: {}},
        evidence: {planId: plan.planId, inputHash: hashValue(input),
          artifactHash: hashValue(input), artifactRef: null,
          citations: [], provenanceStatus: "snapshot"},
        source: {kind: "event_snapshot"},
        timestamps: {observedAt: new Date(input.now).toISOString(),
          evidenceStaleAt: null},
        raw: {kind: "lateJoin", input: structuredClone(input)},
        expiresAt: null,
        stageHistory: [],
        createdAt: now,
        updatedAt: now,
      });
    });
  }

  assertWorkItem(item) {
    assertPlatformWorkItem(item);
    invariant(item.workflowId === this.workflowId &&
      this.entityKinds.includes(item.entityKind) &&
      this.primaryStages.includes(item.primaryStage) &&
      this.lifecycleStatuses.includes(item.lifecycleStatus) &&
      item.raw?.kind === "lateJoin", "INVALID_ASSISTANCE_WORK_ITEM",
    "The item must belong to the registered assistance workflow.");
    this.assertInput(item.raw.input);
    const identity = episodeIdentity(item.raw.input);
    invariant(item.sourceEntity.id === identity &&
      item.workItemId === "wi-" + hashValue([item.runId, identity]) &&
      item.evidence.inputHash === hashValue(item.raw.input),
    "ASSISTANCE_EVIDENCE_DRIFT", "The item must bind its frozen guest episode.");
    return item;
  }

  review(item, {now}) {
    this.assertWorkItem(item);
    const decision = evaluateLateJoinPolicy(item.raw.input);
    invariant(this.contractValidators().decision(decision),
      "INVALID_ASSISTANCE_DECISION", "Policy output failed its wire contract.");
    const outcome = projectDecision(decision);
    return {
      ...outcome,
      confidence: item.confidence,
      decisionProvenance: {
        actorKind: "deterministic", actorId: this.workflowId,
        decision: decision.kind, decidedAt: now,
        inputHash: hashValue(item.raw.input), model: null,
        ruleIds: ["late-join-v1"], evaluation: decision,
        // "ready" is a proposal in this snapshot executor, never a send.
        effectDisposition: "shadow_only",
      },
    };
  }

  assertInput(input) {
    invariant(this.contractValidators().input(input), "INVALID_ASSISTANCE_INPUT",
      "Late-join input failed its canonical schema.");
    assertLateJoinContext(input);
  }

  contractValidators() {
    if (this.validators) return this.validators;
    const read = (file) => JSON.parse(fs.readFileSync(
      path.join(this.repoRoot, "contracts", file), "utf8"));
    const ajv = new Ajv({allErrors: true, strict: false});
    addFormats(ajv);
    ajv.addSchema(read("shared/event_assistance_common.schema.json"));
    this.validators = {
      input: ajv.compile(read("operations/event_assistance_late_join_input.schema.json")),
      decision: ajv.compile(read("operations/event_assistance_late_join_decision.schema.json")),
    };
    return this.validators;
  }
}

function episodeIdentity(input) {
  return hashValue([input.context, input.eventId,
    input.guest.attendeeId, input.guest.episodeId]);
}

function projectDecision(decision) {
  switch (decision.kind) {
    case "resolved":
    case "cancelled":
    case "expired":
      return {primaryStage: "finished", lifecycleStatus: decision.kind,
        owner: "system", reason: decision.reason, taskFlags: [], blockers: []};
    case "wait":
      return {primaryStage: "waiting", lifecycleStatus: "active",
        owner: "system", reason: decision.reason, taskFlags: [],
        blockers: [decision.reason]};
    case "hostDecision":
      return {primaryStage: "host_review", lifecycleStatus: "active",
        owner: "human", reason: decision.reason,
        taskFlags: ["human_review_required"], blockers: [decision.reason]};
    case "update":
      return {primaryStage: decision.shouldSend ? "ready" : "waiting",
        lifecycleStatus: "active", owner: "system",
        reason: decision.shouldSend ? "message_proposed" : "guidance_current",
        taskFlags: [], blockers: []};
    default:
      throw new Error("Unhandled assistance decision: " + decision.kind);
  }
}
