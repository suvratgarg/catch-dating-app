import fs from "node:fs";
import {BudgetLedger} from "../../platform/budget.mjs";
import {hashValue} from "../../platform/canonical-json.mjs";
import {invariant} from "../../platform/errors.mjs";
import {validateJsonSchema} from "../../platform/json-schema.mjs";
import {GuardedModelRunner} from "../../platform/model/guarded-model-runner.mjs";
import {authorizePreparationStage} from "./preparation-policy.mjs";
import {validateSalesResearchProposal} from "./research-proposal.mjs";

const selectionSchema = JSON.parse(fs.readFileSync(new URL(
  "../../../../contracts/operations/outreach_drafting_selection.schema.json", import.meta.url), "utf8"));
const string = {type: "string"};
const nullable = {type: ["string", "null"]};
const strings = {type: "array", items: string};
const object = (properties) => ({type: "object", additionalProperties: false,
  required: Object.keys(properties), properties});
const choice = (values) => ({type: "string", enum: values});
const kinds = ["observation", "capability", "reference", "cta"];

// Small wire DTOs, explicitly authored for the intersection supported by #582.
// Canonical constraints are applied again locally; none are silently stripped.
const writingInput = object({options: {type: "array", items: object({
  alias: string, kind: choice(kinds), text: string})}});
const writingOutput = object({observationAlias: nullable, capabilityAlias: nullable,
  referenceAlias: nullable, ctaAlias: nullable, reasonToBlock: nullable, omittedAliases: strings});
const researchInput = object({sources: {type: "array", items: object({alias: string, text: string})}});
const researchOutput = object({facts: {type: "array", items: object({
  claimKey: choice(["identity", "recurrence", "operation", "stack", "other"]),
  knowledgeStatus: choice(["observed", "inferred", "unknown"]), value: nullable,
  excerpt: nullable, sourceAliases: strings, rationale: string})},
workflowComparison: object({knowledgeStatus: choice(["inferred", "unknown"]),
  visibleTools: {type: "array", items: object({name: string, sourceAlias: string})},
  strongestPlausibleWorkflow: string, incrementalValue: string, remainingQuestions: strings})});

/**
 * Isolated, disabled-by-default source composition. A trusted worker must own
 * fresh public classification, current eligibility, durable unique attempts,
 * run/month persistence and leases before supplying enabled=true.
 * Named factories are the native adapters from dependent PR #582, injected at
 * the eventual Functions boundary. No arbitrary provider registry or fallback.
 * This helper neither persists Sales records nor renders or sends message prose.
 * @param {{enabled?:boolean, factories?:{
 * createDeepSeekProvider?:(options:Record<string,any>)=>{run:(request:any)=>Promise<any>},
 * createOpenAIProvider?:(options:Record<string,any>)=>{run:(request:any)=>Promise<any>},
 * createAnthropicProvider?:(options:Record<string,any>)=>{run:(request:any)=>Promise<any>}},
 * cache?:{get:(key:string)=>Promise<any>,put:(key:string,record:any)=>Promise<any>},
 * monthlyBudget?:BudgetLedger, monthlyWindow?:string,
 * activationPort?:{current:(binding:any)=>Promise<any>}, clock?:()=>Date,
 * providerOptions?:{serverSecretRef?:string, resolveSecret?:(ref:string,options:{signal:AbortSignal})=>Promise<string>,
 * transport?:(url:string,options:RequestInit)=>Promise<Response>,timeoutMs?:number}}} [options]
 */
export function createSalesPreparationAdapter({enabled = false, factories = {}, cache,
  monthlyBudget, monthlyWindow, activationPort, clock = () => new Date(),
  providerOptions = {}} = {}) {
  return {async run(request) {
    invariant(enabled === true, "MODEL_DISABLED", "Sales provider preparation is disabled.");
    const signal = request.signal;
    invariant(signal === undefined || signal instanceof AbortSignal,
      "INVALID_MODEL_REQUEST", "Cancellation requires an AbortSignal.");
    cancelled(signal);
    // Bind the DTO, private mapping and policy before any asynchronous port.
    const stage = request.stage;
    const projection = stage === "writing" ? projectWriting(request) :
      stage === "research" ? projectResearch(request) : null;
    invariant(projection, "SALES_PREPARATION_STAGE_INVALID", "Choose research or writing.");
    const frozen = structuredClone(request.frozen);
    const currentPolicy = structuredClone(request.currentPolicy);
    const estimatedInputTokens = request.estimatedInputTokens;
    const authority = await authorizePreparationStage({frozen, currentPolicy, stage,
      activationPort, ownerUid: request.ownerUid, clock});
    cancelled(signal);
    invariant(authority.providerAuthority, "SALES_PROVIDER_STAGE_INACTIVE",
      "Only the independently authorized API stage can invoke a provider.");
    const config = authority.config;
    invariant(monthlyBudget instanceof BudgetLedger && /^\d{4}-\d{2}$/.test(monthlyWindow ?? ""),
      "MODEL_MONTHLY_WINDOW_REQUIRED", "A trusted monthly ledger and window are required.");
    invariant(Number.isSafeInteger(estimatedInputTokens) && estimatedInputTokens > 0,
      "MODEL_BUDGET_ESTIMATE_REQUIRED", "The rendered request requires an explicit input token ceiling.");
    invariant(config.budget.networkRequests >= 1,
      "MODEL_NETWORK_BUDGET_REQUIRED", "API stages require an explicit network budget.");
    const factory = selectFactory(factories, config.providerId);
    invariant(typeof factory === "function", "MODEL_PROVIDER_MISSING", "The configured native factory is required.");
    const budget = new BudgetLedger({limits: config.budget});
    const maxInputBytes = 32_768;
    invariant(Buffer.byteLength(JSON.stringify(projection.input), "utf8") <= maxInputBytes,
      "MODEL_INPUT_TOO_LARGE", "Reviewed public input exceeds its byte cap.");
    const provider = factory({enabled: true, modelId: config.modelId,
      prompt: config.prompt, promptVersion: config.promptVersion, inputSchema: projection.inputSchema,
      dataPolicy: "public_organizer_only", maxAttempts: 1, maxNetworkRequests: 1,
      maxInputBytes, maxOutputTokens: config.budget.modelOutputTokens,
      maxCostMicros: config.budget.modelCostMicros,
      // Only trusted transport/secret reference ports; no environment defaults.
      serverSecretRef: providerOptions.serverSecretRef,
      resolveSecret: providerOptions.resolveSecret, transport: providerOptions.transport,
      timeoutMs: providerOptions.timeoutMs});
    const runner = new GuardedModelRunner({enabled: true, provider, cache, budget,
      monthlyBudget, monthlyWindow, providerId: config.providerId, modelId: config.modelId, maxInputBytes,
      validateOutput: projection.compose});
    const result = await runner.run({task: `sales-${stage}-${frozen.stageHashes[stage]}`, promptVersion: config.promptVersion,
      input: projection.input, outputSchema: projection.outputSchema,
      estimatedInputTokens,
      maxOutputTokens: config.budget.modelOutputTokens, maxCostMicros: config.budget.modelCostMicros,
      maxNetworkRequests: 1, signal});
    cancelled(signal);
    return {...projection.compose(result.output), provenance: result.provenance,
      budget: budget.snapshot(), policyHash: frozen.policyHash, stageHash: frozen.stageHashes[stage],
      stage, authorizationId: authority.authorizationId, sendAuthority: false};
  }};
}

function selectFactory(factories, providerId) {
  switch (providerId) {
    case "deepseek": return factories.createDeepSeekProvider;
    case "openai": return factories.createOpenAIProvider;
    case "anthropic": return factories.createAnthropicProvider;
    default: invariant(false, "MODEL_CAPABILITY_UNSUPPORTED", "Choose a supported native provider.");
  }
}

function projectWriting({context, publicClauses}) {
  invariant(Array.isArray(publicClauses) && publicClauses.length <= 100,
    "SALES_PUBLIC_INPUT_INVALID", "Writing requires bounded reviewed public clauses.");
  const binding = {organizerId: context?.organizerId, contactId: context?.contactId,
    opportunityId: context?.opportunityId};
  invariant(Object.values(binding).every((id) => typeof id === "string" && id.length > 0 && id.length <= 128),
    "SALES_PUBLIC_INPUT_INVALID", "Local selection identities are required.");
  const byAlias = new Map();
  const seen = new Set();
  const options = publicClauses.map((clause, index) => {
    invariant(clause.dataClassification === "reviewed_public" && clause.approved === true &&
      kinds.includes(clause.kind) && typeof clause.id === "string" && clause.id.length > 0 &&
      clause.id.length <= 160 && !seen.has(clause.id) && typeof clause.text === "string" &&
      clause.text.length > 0 && clause.text.length <= 3000,
    "SALES_PUBLIC_INPUT_INVALID", "Only approved, reviewed public clauses may reach the provider.");
    seen.add(clause.id);
    const alias = `option_${index}`;
    byAlias.set(alias, {id: clause.id, kind: clause.kind});
    return {alias, kind: clause.kind, text: clause.text};
  });
  const lookup = (alias, kind) => {
    if (alias === null) return null;
    const clause = byAlias.get(alias);
    invariant(clause && (!kind || clause.kind === kind), "SALES_SELECTION_ALIAS_INVALID",
      "Selection must reference a supplied option of the correct kind.");
    return clause.id;
  };
  return {input: {options}, inputSchema: writingInput, outputSchema: writingOutput,
    compose(output) {
      invariant(validateJsonSchema(writingOutput, output).valid,
        "SALES_SELECTION_INVALID", "Writing output must match the wire DTO.");
      const selection = {...binding, language: "en", reasonToBlock: output.reasonToBlock,
        omittedIds: output.omittedAliases.map((alias) => lookup(alias))};
      for (const kind of kinds) selection[`${kind}Id`] = lookup(output[`${kind}Alias`], kind);
      invariant(validateJsonSchema(selectionSchema, selection).valid,
        "SALES_SELECTION_INVALID", "Selection must satisfy the full canonical contract.");
      return {selection, selectionHash: hashValue(selection)};
    }};
}

function projectResearch({context, publicSources}) {
  invariant(typeof context?.organizerId === "string" && context.organizerId.length > 0 &&
    context.organizerId.length <= 128 && Array.isArray(publicSources) && publicSources.length <= 50,
  "SALES_PUBLIC_INPUT_INVALID", "Research requires an organizer and bounded reviewed public sources.");
  const organizerId = context.organizerId;
  const sources = publicSources.map((source) => {
    invariant(source.dataClassification === "reviewed_public", "SALES_PUBLIC_INPUT_INVALID",
      "Research accepts only reviewed public captures.");
    let url;
    try {url = new URL(source.url);} catch { /* Do not expose a malformed URL. */ }
    invariant(url?.protocol === "https:" && !url.username && !url.password,
      "SALES_PUBLIC_INPUT_INVALID", "Research requires valid public HTTPS source URLs.");
    return {sourceId: source.sourceId, url: source.url, text: source.text,
      capturedAt: source.capturedAt, contentHash: source.contentHash};
  });
  const sourceHash = hashValue(sources);
  const byAlias = new Map(sources.map((source, index) => [`source_${index}`, source.sourceId]));
  // Reuse the full source validation boundary before provider I/O.
  validateSalesResearchProposal({organizerId, sourceHash, sources, proposal: {
    schemaVersion: 1, organizerId, sourceHash,
    facts: [{claimKey: "other", knowledgeStatus: "unknown", value: null, excerpt: null,
      sourceIds: [], rationale: "Pending reviewed public research."}],
    workflowComparison: {knowledgeStatus: "unknown", visibleTools: [],
      strongestPlausibleWorkflow: "Unknown", incrementalValue: "Unknown", remainingQuestions: []}}});
  const lookup = (alias) => {
    invariant(byAlias.has(alias), "SALES_RESEARCH_SOURCE_UNKNOWN", "Research must cite a supplied source alias.");
    return byAlias.get(alias);
  };
  return {input: {sources: sources.map((source, index) => ({alias: `source_${index}`, text: source.text}))},
    inputSchema: researchInput, outputSchema: researchOutput,
    compose(output) {
      invariant(validateJsonSchema(researchOutput, output).valid,
        "SALES_RESEARCH_PROPOSAL_INVALID", "Research output must match the wire DTO.");
      const proposal = {schemaVersion: 1, organizerId, sourceHash,
        facts: output.facts.map(({sourceAliases, ...fact}) => ({...fact, sourceIds: sourceAliases.map(lookup)})),
        workflowComparison: {...output.workflowComparison,
          visibleTools: output.workflowComparison.visibleTools.map(({name, sourceAlias}) => ({name, sourceId: lookup(sourceAlias)}))}};
      return validateSalesResearchProposal({proposal, organizerId, sourceHash, sources});
    }};
}

function cancelled(signal) {
  invariant(!signal?.aborted, "MODEL_PROVIDER_CANCELLED", "Sales preparation was cancelled.");
}
