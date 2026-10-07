import fs from "node:fs";
import {hashValue} from "../../platform/canonical-json.mjs";
import {invariant} from "../../platform/errors.mjs";
import {validateJsonSchema} from "../../platform/json-schema.mjs";

const schema = JSON.parse(fs.readFileSync(new URL(
  "../../../../contracts/operations/sales_preparation_policy.schema.json", import.meta.url), "utf8"));

/** Frozen job input. Configuration is not provider activation authority. */
export function freezeSalesPreparationPolicy(value) {
  const validation = validateJsonSchema(schema, value);
  invariant(validation.valid, "SALES_PREPARATION_POLICY_INVALID",
    "Research and writing require separate explicit configuration.", {errors: validation.errors});
  const policy = structuredClone(value);
  for (const stage of ["research", "writing"]) {
    const setting = policy[stage];
    if (setting.executionMode === "deterministic") {
      invariant(setting.providerId === null && setting.modelId === null &&
        setting.billingSourceId === null && Object.values(setting.budget).every((n) => n === 0),
      "SALES_DETERMINISTIC_POLICY_INVALID", "Deterministic execution cannot reserve provider spending.");
    } else if (setting.executionMode === "reviewed_import") {
      invariant(setting.billingSourceId === null && Object.values(setting.budget).every((n) => n === 0),
        "SALES_IMPORT_POLICY_INVALID", "Reviewed imports cannot authorize backend provider spending.");
    } else if (setting.executionMode === "api") {
      invariant(setting.providerId && setting.modelId && setting.billingSourceId &&
        setting.budget.modelCalls > 0 && setting.budget.modelInputTokens > 0 &&
        setting.budget.modelOutputTokens > 0 && setting.budget.modelCostMicros > 0,
      "SALES_API_POLICY_INCOMPLETE", "API configuration requires an explicit billing source and bounded spending.");
    }
  }
  return {policy, policyHash: hashValue(policy),
    stageHashes: {research: hashValue(policy.research), writing: hashValue(policy.writing)}};
}

/** Called by a trusted worker before reservation or provider I/O. No fallback. */
export async function authorizePreparationStage({frozen, stage, currentPolicy,
  activationPort, ownerUid, clock = () => new Date()}) {
  invariant(["research", "writing"].includes(stage), "SALES_PREPARATION_STAGE_INVALID",
    "Choose the independently configured research or writing stage.");
  const verified = freezeSalesPreparationPolicy(frozen.policy);
  invariant(verified.policyHash === frozen.policyHash &&
    verified.stageHashes[stage] === frozen.stageHashes?.[stage],
  "SALES_PREPARATION_POLICY_DRIFT", "Frozen configuration changed.");
  invariant(freezeSalesPreparationPolicy(currentPolicy).policyHash === verified.policyHash,
    "SALES_PREPARATION_POLICY_STALE", "Current configuration changed; create a reviewed replacement job.");
  const config = verified.policy[stage];
  if (config.executionMode !== "api") return {stage, config: structuredClone(config),
    providerAuthority: false, fallbackAuthority: false};
  invariant(activationPort?.current && typeof ownerUid === "string" && ownerUid.length > 0,
    "SALES_API_INACTIVE", "API billing remains inactive until exact owner authorization.");
  const decision = await activationPort.current({ownerUid, stage,
    policyHash: verified.policyHash, stageHash: verified.stageHashes[stage],
    billingSourceId: config.billingSourceId});
  // The port may wait. A timestamp captured before that wait cannot prove
  // activation remains current before budget reservation or provider I/O.
  const at = new Date(clock()).getTime();
  invariant(decision?.status === "active" && decision.ownerUid === ownerUid &&
    decision.stage === stage && decision.policyHash === verified.policyHash &&
    decision.stageHash === verified.stageHashes[stage] &&
    decision.billingSourceId === config.billingSourceId &&
    typeof decision.authorizationId === "string" && decision.authorizationId.length > 0 &&
    Number.isFinite(Date.parse(decision.expiresAt)) &&
    Number.isFinite(at) && Date.parse(decision.expiresAt) > at,
  "SALES_API_INACTIVE", "Current exact policy and billing authorization are required.");
  return {stage, config: structuredClone(config), providerAuthority: true,
    authorizationId: decision.authorizationId, fallbackAuthority: false};
}
