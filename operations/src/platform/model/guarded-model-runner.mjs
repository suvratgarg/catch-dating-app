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
    modelId = "disabled",
    maxInputBytes = 32_768,
  } = {}) {
    invariant(cache?.get && cache?.put, "INVALID_MODEL_RUNNER", "A model cache port with get/put is required.");
    this.enabled = enabled;
    this.provider = provider;
    this.cache = cache;
    this.budget = budget;
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
    this.budget.consume({
      modelCalls: 1,
      modelInputTokens: request.estimatedInputTokens ?? 0,
      modelOutputTokens: request.maxOutputTokens ?? 0,
      modelCostMicros: request.maxCostMicros ?? 0,
    }, {reason: `${request.task}:${request.promptVersion}`});
    const response = await this.provider.run({
      task: request.task,
      promptVersion: request.promptVersion,
      input: request.input,
      outputSchema: request.outputSchema,
      modelId: this.modelId,
    });
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
        usage: response.usage ?? null,
      },
    };
    await this.cache.put(cacheKey, record);
    return {output: record.output, provenance: record.provenance};
  }
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
