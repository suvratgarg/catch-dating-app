import Ajv from "ajv";
import {OperationsError, invariant} from "../errors.mjs";

/** @import {ValidateFunction} from "ajv" */

/**
 * Provider adapters implement this port, not a vendor's wire protocol.
 * The trusted workflow owns current activation, durable attempt claims, cache
 * and run/month reservations through GuardedModelRunner before invoking it.
 * Input schemas are server-owned allowlists for reviewed public organizer data;
 * schema validation cannot establish that arbitrary free text is public.
 * @typedef {Object} ModelProviderRequest
 * @property {string} task
 * @property {string} promptVersion
 * @property {string} modelId
 * @property {Record<string, unknown>} input
 * @property {Record<string, unknown>} outputSchema
 * @property {number} maxOutputTokens
 * @property {number} maxCostMicros
 * @property {AbortSignal} [signal]
 * @typedef {Object} ModelProviderResult
 * @property {1} schemaVersion
 * @property {Record<string, unknown>} output Schema-validated draft/proposal only.
 * @property {{inputTokens:number, outputTokens:number, costMicros:number}} usage
 * @property {Object} metadata
 * @property {string} metadata.providerId
 * @property {string} metadata.modelId
 * @property {string|null} metadata.requestId
 * @property {number} metadata.attemptCount
 * @property {number} metadata.durationMs
 * @property {"stop"} metadata.finishReason
 * @property {"reserved_ceiling"} metadata.costBasis
 * @property {null} metadata.estimatedCostMicros No reviewed price book in this slice.
 * @property {{inputTotal:number, ordinaryInput:number|null, cacheRead:number|null,
 *   cacheWrite:number|null, outputTotal:number, reasoningOutput:number|null}} metadata.tokens
 * @typedef {{run:(request:ModelProviderRequest)=>Promise<ModelProviderResult>}} ModelProvider
 */

const PRIVATE_KEYS = /^(?:uid|userId|guest.*|attendee.*|datingProfile|email|phone(?:Number)?|contacts?|contactExport|payment.*|private.*|crmNotes|apiKey|secret|credential.*|authorization)$/i;

/**
 * Errors deliberately contain no request/response bodies, headers or causes.
 * @param {string} code
 * @param {{attemptCount?:number, outcome?:string, status?:number|null}} [details]
 */
export function providerError(code, {attemptCount = 0, outcome = "not_submitted", status = null} = {}) {
  return new OperationsError(code, "Model provider request did not produce a validated draft.", {
    details: {attemptCount, outcome, status, usage: null},
  });
}

export function positiveLimit(value, maximum) {
  invariant(Number.isSafeInteger(value) && value > 0 && value <= maximum,
    "MODEL_PROVIDER_CONFIG_INVALID", "Provider limits must be explicit bounded positive integers.");
  return value;
}

/** Fail closed for unknown provider/model/capability combinations. */
export function requireModelCapability(catalog, providerId, modelId, capability) {
  const model = typeof providerId === "string" && typeof modelId === "string" && typeof capability === "string" &&
    Object.hasOwn(catalog, providerId) && Object.hasOwn(catalog[providerId], modelId) ?
    catalog[providerId][modelId] : null;
  invariant(model && model.capabilities.includes(capability),
    "MODEL_CAPABILITY_UNSUPPORTED", "The configured provider/model does not support this capability.");
  return model;
}

/**
 * Compile before I/O; unsupported schema keywords and references fail closed.
 * @returns {ValidateFunction<Record<string, unknown>>}
 */
export function compileClosedSchema(schema, {publicInput = false} = {}) {
  try {
    const json = JSON.stringify(schema);
    if (typeof json !== "string" || Buffer.byteLength(json) > 32_768) {
      throw providerError("MODEL_SCHEMA_UNSUPPORTED");
    }
    schema = JSON.parse(json);
    invariant(schema?.type === "object" && schema.additionalProperties === false,
      "MODEL_SCHEMA_UNSUPPORTED", "A closed object schema is required.");
    inspect(schema);
    // Avoid duplicate $id conflicts and an unbounded process-global schema cache.
    return /** @type {ValidateFunction<Record<string, unknown>>} */ (
      new Ajv({strict: true, allErrors: false, validateFormats: false}).compile(schema));
  } catch {
    throw providerError("MODEL_SCHEMA_UNSUPPORTED");
  }

  function inspect(node) {
    if (!node || typeof node !== "object" || Array.isArray(node)) {
      throw providerError("MODEL_SCHEMA_UNSUPPORTED");
    }
    const types = Array.isArray(node.type) ? node.type : [node.type];
    const compositions = ["anyOf", "oneOf", "allOf"].filter((key) => node[key]);
    // Every value, including array elements and nullable objects, must have a
    // concrete shape. A schema such as {} would allow arbitrary private data.
    if ((!node.type && compositions.length === 0) ||
        (node.type && types.some((type) => !["object", "array", "string", "number", "integer", "boolean", "null"].includes(type))) ||
        (types.includes("object") && node.additionalProperties !== false) ||
        (types.includes("array") && !node.items)) {
      throw providerError("MODEL_SCHEMA_UNSUPPORTED");
    }
    // Remote schema loading and open dictionaries are outside this small port.
    if (["$ref", "patternProperties", "format"].some((key) => Object.hasOwn(node, key)) ||
        (types.includes("object") && node.additionalProperties !== false)) {
      throw providerError("MODEL_SCHEMA_UNSUPPORTED");
    }
    for (const [key, child] of Object.entries(node.properties ?? {})) {
      if (publicInput && PRIVATE_KEYS.test(key)) throw providerError("MODEL_SCHEMA_UNSUPPORTED");
      inspect(child);
    }
    if (node.items) inspect(node.items);
    for (const keyword of ["anyOf", "oneOf", "allOf"]) {
      for (const child of node[keyword] ?? []) inspect(child);
    }
  }
}

/** Snapshot once before validation, including getters/toJSON at the JSON boundary.
 * @param {ModelProviderRequest} request
 * @returns {ModelProviderRequest}
 */
export function snapshotProviderRequest(request) {
  try {
    return {task: request.task, promptVersion: request.promptVersion, modelId: request.modelId,
      maxOutputTokens: request.maxOutputTokens, maxCostMicros: request.maxCostMicros,
      input: JSON.parse(JSON.stringify(request.input)),
      outputSchema: JSON.parse(JSON.stringify(request.outputSchema)), signal: request.signal};
  } catch {
    throw providerError("MODEL_PROVIDER_REQUEST_INVALID");
  }
}

/** @param {ModelProviderRequest} request */
export function validateProviderRequest(request, config, validateInput) {
  invariant(request && typeof request.task === "string" &&
    /^[a-z0-9][a-z0-9._-]{0,99}$/i.test(request.task) &&
    request.modelId === config.modelId && request.promptVersion === config.promptVersion &&
    Number.isSafeInteger(request.maxOutputTokens) && request.maxOutputTokens > 0 &&
    request.maxOutputTokens <= config.maxOutputTokens &&
    Number.isSafeInteger(request.maxCostMicros) && request.maxCostMicros > 0 &&
    request.maxCostMicros <= config.maxCostMicros,
  "MODEL_PROVIDER_REQUEST_INVALID", "Request must match the frozen model, prompt and spending limits.");
  invariant(request.signal === undefined || request.signal instanceof AbortSignal,
    "MODEL_PROVIDER_REQUEST_INVALID", "Cancellation requires an AbortSignal.");
  let input;
  try {
    input = JSON.stringify(request.input);
  } catch {
    throw providerError("MODEL_PROVIDER_INPUT_INVALID");
  }
  invariant(typeof input === "string" && Buffer.byteLength(input) <= config.maxInputBytes &&
    validateInput(request.input), "MODEL_PROVIDER_INPUT_INVALID", "Input must match the public data allowlist and byte cap.");
  return compileClosedSchema(request.outputSchema);
}
