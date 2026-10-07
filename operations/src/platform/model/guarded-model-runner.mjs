import {BudgetLedger} from "../budget.mjs";
import {hashValue} from "../canonical-json.mjs";
import {OperationsError, invariant} from "../errors.mjs";
import {validateJsonSchema} from "../json-schema.mjs";

export class GuardedModelRunner {
  constructor({
    enabled = false,
    provider = null,
    cache,
    budget = new BudgetLedger(),
    monthlyBudget = null,
    monthlyWindow = null,
    modelId = "disabled",
    providerId = null,
    validateOutput = null,
    maxInputBytes = 32_768,
  } = {}) {
    invariant(cache?.get && cache?.put, "INVALID_MODEL_RUNNER", "A model cache port with get/put is required.");
    this.enabled = enabled;
    this.provider = provider;
    this.cache = cache;
    this.budget = budget;
    this.monthlyBudget = monthlyBudget;
    this.monthlyWindow = monthlyWindow;
    this.modelId = modelId;
    invariant(providerId === null || (typeof providerId === "string" &&
      /^[a-z0-9][a-z0-9._-]{0,99}$/i.test(providerId)),
    "INVALID_MODEL_RUNNER", "Provider identity must be a bounded identifier.");
    this.providerId = providerId;
    this.validateOutput = validateOutput;
    this.maxInputBytes = maxInputBytes;
  }

  async run(request) {
    request = snapshotRequest(request);
    validateRequest(request, this.maxInputBytes);
    checkCancellation(request.signal, "not_submitted");
    const cacheKey = hashValue({
      schemaVersion: 1,
      task: request.task,
      promptVersion: request.promptVersion,
      modelId: this.modelId,
      input: request.input,
      outputSchema: request.outputSchema,
      // Keep legacy keys for existing workflows with no provider identity.
      ...(this.providerId === null ? {} : {providerId: this.providerId}),
    });
    const cached = await this.cache.get(cacheKey);
    checkCancellation(request.signal, "not_submitted");
    if (cached) {
      let metadata;
      if (this.providerId !== null) {
        invariant(cached.provenance?.providerId === this.providerId &&
          cached.provenance.modelId === this.modelId &&
          cached.provenance.task === request.task &&
          cached.provenance.promptVersion === request.promptVersion,
        "MODEL_CACHE_INVALID", "Cached provider identity does not match the request.");
        metadata = validateMetadata(cached.provenance.metadata,
          validateUsage(cached.provenance.usage), this.providerId, this.modelId,
          cached.provenance.request?.maxNetworkRequests);
      }
      const validation = validateJsonSchema(request.outputSchema, cached.output);
      if (!validation.valid) {
        throw new OperationsError("MODEL_CACHE_INVALID", "Cached model output no longer matches its output schema.", {
          details: {cacheKey, errors: validation.errors},
        });
      }
      this.validateOutput?.(cached.output);
      return {output: cached.output, provenance: this.providerId === null ?
        {...cached.provenance, cacheKey, cacheHit: true} : {
          task: request.task, promptVersion: request.promptVersion,
          providerId: this.providerId, modelId: this.modelId, cacheKey, cacheHit: true,
          usage: validateUsage(cached.provenance.usage), metadata,
          request: boundedRequest(cached.provenance.request, this.maxInputBytes),
          monthlyWindow: cached.provenance.monthlyWindow,
        }};
    }
    if (!this.enabled) {
      throw new OperationsError("MODEL_DISABLED", "Model calls are disabled and no valid cached result exists.", {
        details: {cacheKey, task: request.task, promptVersion: request.promptVersion},
        exitCode: 5,
      });
    }
    invariant(this.provider?.run, "MODEL_PROVIDER_MISSING", "An enabled model runner requires a provider.");
    const requestedReservation = {
      modelCalls: 1,
      modelInputTokens: requiredEstimate(request, "estimatedInputTokens"),
      modelOutputTokens: requiredEstimate(request, "maxOutputTokens"),
      modelCostMicros: requiredEstimate(request, "maxCostMicros"),
      networkRequests: this.providerId === null ? 0 : networkLimit(request.maxNetworkRequests),
    };
    const reason = `${request.task}:${request.promptVersion}`;
    if (this.monthlyBudget) {
      invariant(
        /^\d{4}-\d{2}$/.test(this.monthlyWindow ?? ""),
        "MODEL_MONTHLY_WINDOW_REQUIRED",
        "An enabled monthly model budget requires a YYYY-MM window."
      );
      if (!this.budget.canConsume(requestedReservation) ||
          !this.monthlyBudget.canConsume(requestedReservation)) {
        throw new OperationsError(
          "BUDGET_EXCEEDED",
          "Model request would exceed its run or monthly ceiling.",
          {
            details: {
              reason,
              monthlyWindow: this.monthlyWindow,
              run: this.budget.snapshot(),
              month: this.monthlyBudget.snapshot(),
            },
            exitCode: 4,
          }
        );
      }
    }
    const reservation = this.budget.reserve(
      requestedReservation,
      {reason}
    );
    const monthlyReservation = this.monthlyBudget?.reserve(
      requestedReservation,
      {reason}
    ) ?? null;
    let response;
    try {
      response = await runWithCancellation(this.provider, {
      task: request.task,
      promptVersion: request.promptVersion,
      input: request.input,
      outputSchema: request.outputSchema,
      modelId: this.modelId,
      maxOutputTokens: request.maxOutputTokens,
      maxCostMicros: request.maxCostMicros,
      estimatedInputTokens: request.estimatedInputTokens,
      maxNetworkRequests: requestedReservation.networkRequests,
      signal: request.signal,
      });
    } catch (error) {
      // Failed/uncertain calls retain both reservations. No retry or fallback.
      if (this.providerId === null) throw error;
      throw redactedProviderError(error);
    }
    checkCancellation(request.signal, "unknown");
    const usage = validateUsage(response?.usage);
    const metadata = this.providerId === null ? null :
      validateMetadata(response?.metadata, usage, this.providerId, this.modelId,
        requestedReservation.networkRequests);
    const validation = validateJsonSchema(request.outputSchema, response.output);
    if (!validation.valid) {
      throw new OperationsError("MODEL_OUTPUT_INVALID", "Model output failed schema validation.");
    }
    this.validateOutput?.(response.output);
    const actualUsage = {
      modelCalls: 1,
      modelInputTokens: usage.inputTokens,
      modelOutputTokens: usage.outputTokens,
      modelCostMicros: usage.costMicros,
      networkRequests: metadata?.attemptCount ?? 0,
    };
    this.budget.reconcileReservation(reservation, actualUsage, {reason});
    if (this.monthlyBudget && monthlyReservation) {
      this.monthlyBudget.reconcileReservation(
        monthlyReservation,
        actualUsage,
        {reason}
      );
    }
    const record = {
      schemaVersion: 1,
      output: response.output,
      provenance: {
        task: request.task,
        promptVersion: request.promptVersion,
        modelId: this.modelId,
        cacheKey,
        cacheHit: false,
        usage,
        monthlyWindow: this.monthlyWindow,
        ...(metadata === null ? {} : {providerId: this.providerId, metadata,
          request: boundedRequest(request, this.maxInputBytes)}),
      },
    };
    await this.cache.put(cacheKey, record);
    return {output: record.output, provenance: record.provenance};
  }
}

function requiredEstimate(request, key) {
  const value = request[key];
  invariant(
    Number.isSafeInteger(value) && value >= 0,
    "MODEL_BUDGET_ESTIMATE_REQUIRED",
    `${key} must be an explicit non-negative safe integer.`,
    {key}
  );
  return value;
}

function validateUsage(usage) {
  invariant(usage && typeof usage === "object", "MODEL_USAGE_REQUIRED", "Model providers must return usage.");
  for (const key of ["inputTokens", "outputTokens", "costMicros"]) {
    invariant(
      Number.isSafeInteger(usage[key]) && usage[key] >= 0,
      "MODEL_USAGE_INVALID",
      `Model usage ${key} must be a non-negative safe integer.`,
      {key}
    );
  }
  return {
    inputTokens: usage.inputTokens,
    outputTokens: usage.outputTokens,
    costMicros: usage.costMicros,
  };
}

export function modelCachePort(store) {
  return {
    get: (key) => store.getModelCache(key),
    put: (key, value) => store.putModelCache(key, value),
  };
}

function validateRequest(request, maxInputBytes) {
  invariant(request && typeof request === "object", "INVALID_MODEL_REQUEST", "Model request must be an object.");
  invariant(typeof request.task === "string" && request.task.length > 0, "INVALID_MODEL_REQUEST", "Model task is required.");
  invariant(/^[a-z0-9][a-z0-9._-]{0,99}$/i.test(request.promptVersion ?? ""), "INVALID_MODEL_REQUEST", "A versioned prompt id is required.");
  invariant(request.outputSchema?.type === "object", "INVALID_MODEL_REQUEST", "Model output schema must be an object schema.");
  invariant(request.outputSchema.additionalProperties === false, "INVALID_MODEL_REQUEST", "Model output schema must reject additional properties.");
  invariant(request.signal === undefined || request.signal instanceof AbortSignal,
    "INVALID_MODEL_REQUEST", "Cancellation requires an AbortSignal.");
  const inputBytes = Buffer.byteLength(JSON.stringify(request.input), "utf8");
  invariant(inputBytes <= maxInputBytes, "MODEL_INPUT_TOO_LARGE", "Model input exceeds its byte cap.", {inputBytes, maxInputBytes});
}

function snapshotRequest(request) {
  try {
    return {task: request.task, promptVersion: request.promptVersion,
      input: JSON.parse(JSON.stringify(request.input)),
      outputSchema: JSON.parse(JSON.stringify(request.outputSchema)),
      estimatedInputTokens: request.estimatedInputTokens,
      maxOutputTokens: request.maxOutputTokens, maxCostMicros: request.maxCostMicros,
      maxNetworkRequests: request.maxNetworkRequests, signal: request.signal};
  } catch {
    throw new OperationsError("INVALID_MODEL_REQUEST", "Model request must contain serializable JSON.");
  }
}

function networkLimit(value) {
  invariant(Number.isSafeInteger(value) && value > 0 && value <= 2,
    "MODEL_NETWORK_BUDGET_REQUIRED", "Provider calls require an explicit one or two request ceiling.");
  return value;
}

function boundedRequest(request, maxInputBytes) {
  return {maxInputBytes, estimatedInputTokens: requiredEstimate(request, "estimatedInputTokens"),
    maxOutputTokens: requiredEstimate(request, "maxOutputTokens"),
    maxCostMicros: requiredEstimate(request, "maxCostMicros"),
    maxNetworkRequests: networkLimit(request.maxNetworkRequests)};
}

function validateMetadata(value, usage, providerId, modelId, maxNetworkRequests) {
  const integer = (n) => Number.isSafeInteger(n) && n >= 0;
  const tokens = value?.tokens;
  invariant(value?.providerId === providerId && value.modelId === modelId &&
    (value.requestId === null || (typeof value.requestId === "string" && /^[a-z0-9_-]{1,128}$/i.test(value.requestId))) &&
    Number.isSafeInteger(value.attemptCount) && value.attemptCount >= 1 &&
    value.attemptCount <= networkLimit(maxNetworkRequests) &&
    integer(value.durationMs) && value.durationMs <= 600_000 &&
    value.finishReason === "stop" && value.costBasis === "reserved_ceiling" &&
    value.estimatedCostMicros === null && tokens?.inputTotal === usage.inputTokens &&
    tokens.outputTotal === usage.outputTokens,
  "MODEL_METADATA_INVALID", "Provider metadata must match the bounded request and usage.");
  for (const key of ["ordinaryInput", "cacheRead", "cacheWrite", "reasoningOutput"]) {
    invariant(tokens[key] === null || (integer(tokens[key]) &&
      tokens[key] <= (key === "reasoningOutput" ? usage.outputTokens : usage.inputTokens)),
    "MODEL_METADATA_INVALID", "Provider token breakdown is invalid.");
  }
  const inputParts = [tokens.ordinaryInput, tokens.cacheRead, tokens.cacheWrite];
  invariant(inputParts.filter((n) => n !== null).reduce((a, b) => a + b, 0) <= usage.inputTokens &&
    (inputParts.some((n) => n === null) || inputParts.reduce((a, b) => a + b, 0) === usage.inputTokens),
  "MODEL_METADATA_INVALID", "Provider token totals are inconsistent.");
  return {providerId, modelId, requestId: value.requestId, attemptCount: value.attemptCount,
    durationMs: value.durationMs, finishReason: value.finishReason, costBasis: value.costBasis,
    estimatedCostMicros: null, tokens: {inputTotal: tokens.inputTotal,
      ordinaryInput: tokens.ordinaryInput, cacheRead: tokens.cacheRead,
      cacheWrite: tokens.cacheWrite, outputTotal: tokens.outputTotal,
      reasoningOutput: tokens.reasoningOutput}};
}

function checkCancellation(signal, outcome) {
  if (signal?.aborted) throw new OperationsError("MODEL_PROVIDER_CANCELLED",
    "Model request was cancelled.", {details: {outcome, usage: null}});
}

async function runWithCancellation(provider, request) {
  const signal = request.signal;
  checkCancellation(signal, "not_submitted");
  let abort;
  const cancelled = new Promise((_, reject) => {
    abort = () => reject(new OperationsError("MODEL_PROVIDER_CANCELLED",
      "Model request was cancelled.", {details: {outcome: "unknown", usage: null}}));
    signal?.addEventListener("abort", abort, {once: true});
  });
  try {
    return await Promise.race([Promise.resolve().then(() => {
      checkCancellation(signal, "not_submitted");
      return provider.run(request);
    }), cancelled]);
  } finally {
    signal?.removeEventListener("abort", abort);
  }
}

const SAFE_PROVIDER_ERRORS = new Set([
  "MODEL_PROVIDER_CANCELLED", "MODEL_PROVIDER_TIMEOUT", "MODEL_PROVIDER_RATE_LIMITED",
  "MODEL_PROVIDER_TRANSPORT_FAILED", "MODEL_PROVIDER_HTTP_ERROR", "MODEL_PROVIDER_RESPONSE_INVALID",
  "MODEL_PROVIDER_OUTPUT_INVALID", "MODEL_PROVIDER_REFUSED", "MODEL_PROVIDER_INCOMPLETE",
  "MODEL_PROVIDER_USAGE_INVALID", "MODEL_PROVIDER_DISABLED", "MODEL_PROVIDER_REQUEST_INVALID",
  "MODEL_PROVIDER_INPUT_INVALID", "MODEL_SCHEMA_UNSUPPORTED", "MODEL_CAPABILITY_UNSUPPORTED",
]);

function redactedProviderError(error) {
  const details = error?.details;
  return new OperationsError(SAFE_PROVIDER_ERRORS.has(error?.code) ? error.code : "MODEL_PROVIDER_FAILED",
    "Model provider request did not produce a validated draft.", {details: {
      outcome: ["not_submitted", "rejected", "unknown"].includes(details?.outcome) ? details.outcome : "unknown",
      attemptCount: Number.isSafeInteger(details?.attemptCount) && details.attemptCount >= 0 &&
        details.attemptCount <= 2 ? details.attemptCount : null,
      status: Number.isSafeInteger(details?.status) && details.status >= 100 &&
        details.status <= 599 ? details.status : null,
      usage: null,
    }});
}
