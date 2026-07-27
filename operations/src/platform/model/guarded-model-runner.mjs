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
    this.maxInputBytes = maxInputBytes;
  }

  async run(request) {
    validateRequest(request, this.maxInputBytes);
    const cacheKey = hashValue({
      schemaVersion: 1,
      task: request.task,
      promptVersion: request.promptVersion,
      modelId: this.modelId,
      input: request.input,
      outputSchema: request.outputSchema,
    });
    const cached = await this.cache.get(cacheKey);
    if (cached) {
      const validation = validateJsonSchema(request.outputSchema, cached.output);
      if (!validation.valid) {
        throw new OperationsError("MODEL_CACHE_INVALID", "Cached model output no longer matches its output schema.", {
          details: {cacheKey, errors: validation.errors},
        });
      }
      return {output: cached.output, provenance: {...cached.provenance, cacheKey, cacheHit: true}};
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
    const response = await this.provider.run({
      task: request.task,
      promptVersion: request.promptVersion,
      input: request.input,
      outputSchema: request.outputSchema,
      modelId: this.modelId,
      maxOutputTokens: request.maxOutputTokens,
      maxCostMicros: request.maxCostMicros,
    });
    const usage = validateUsage(response?.usage);
    const actualUsage = {
      modelCalls: 1,
      modelInputTokens: usage.inputTokens,
      modelOutputTokens: usage.outputTokens,
      modelCostMicros: usage.costMicros,
    };
    this.budget.reconcileReservation(reservation, actualUsage, {reason});
    if (this.monthlyBudget && monthlyReservation) {
      this.monthlyBudget.reconcileReservation(
        monthlyReservation,
        actualUsage,
        {reason}
      );
    }
    const validation = validateJsonSchema(request.outputSchema, response.output);
    if (!validation.valid) {
      throw new OperationsError("MODEL_OUTPUT_INVALID", "Model output failed schema validation.", {
        details: {errors: validation.errors, task: request.task, promptVersion: request.promptVersion},
      });
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
    {key, value}
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
      {key, value: usage[key]}
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
  const inputBytes = Buffer.byteLength(JSON.stringify(request.input), "utf8");
  invariant(inputBytes <= maxInputBytes, "MODEL_INPUT_TOO_LARGE", "Model input exceeds its byte cap.", {inputBytes, maxInputBytes});
}
