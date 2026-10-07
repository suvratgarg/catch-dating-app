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

/**
 * @typedef {Object} ModelProviderConfig
 * @property {boolean} [enabled]
 * @property {string} modelId
 * @property {string} promptVersion
 * @property {string} prompt Trusted, independently frozen stage prompt.
 * @property {Record<string, unknown>} inputSchema Trusted public-data allowlist.
 * @property {"public_organizer_only"} [dataPolicy]
 * @property {string} serverSecretRef Opaque server reference, never a secret value.
 * @property {(ref:string, options:{signal:AbortSignal})=>Promise<string>} [resolveSecret]
 * @property {(url:string, options:RequestInit)=>Promise<Response>} [transport] One fetch, no hidden retries.
 * @property {number} timeoutMs
 * @property {number} maxAttempts
 * @property {number} maxNetworkRequests
 * @property {number} maxInputBytes Cap for the entire rendered JSON request, including prompt/schema.
 * @property {number} maxOutputTokens
 * @property {number} maxCostMicros Conservative ledger ceiling, not provider billing enforcement.
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

/** Narrow native structured-output subsets; never strip constraints silently.
 * Called after local AJV compilation. References/tools/recursive grammars are
 * outside this bounded draft port, even when a vendor supports them.
 * @param {Record<string, unknown>} schema
 * @param {"openai"|"anthropic"} providerId
 */
export function validateStructuredOutputSchema(schema, providerId) {
  const allowed = new Set(["type", "properties", "required", "additionalProperties",
    "items", "enum", "description", "anyOf"]);
  if (providerId === "openai") {
    for (const key of ["minLength", "maxLength", "minimum", "maximum", "multipleOf", "minItems", "maxItems"]) allowed.add(key);
  } else {
    allowed.add("const"); allowed.add("minItems");
  }
  let properties = 0; let enums = 0; let unions = 0; let optional = 0;
  inspect(schema, 0);
  function inspect(node, objectDepth) {
    const types = Array.isArray(node.type) ? node.type : [node.type];
    if (Object.keys(node).some((key) => !allowed.has(key)) ||
        (providerId === "anthropic" && node.minItems !== undefined && ![0, 1].includes(node.minItems))) fail();
    if (types.length > 1 || node.anyOf) unions++;
    if (types.includes("object")) {
      objectDepth++;
      const keys = Object.keys(node.properties ?? {});
      const required = node.required ?? [];
      const missing = keys.filter((key) => !required.includes(key)).length;
      properties += keys.length; optional += missing;
      if (objectDepth > 10 || properties > 100 ||
          required.some((key) => !keys.includes(key)) ||
          (providerId === "openai" && missing > 0)) fail();
    }
    for (const values of [node.enum, Object.hasOwn(node, "const") ? [node.const] : []]) {
      if (!values) continue;
      enums += values.length;
      if (values.some((value) => value !== null && typeof value === "object")) fail();
    }
    if (enums > 100 || unions > 16 || optional > 24) fail();
    for (const child of Object.values(node.properties ?? {})) inspect(child, objectDepth);
    if (node.items) inspect(node.items, objectDepth);
    for (const child of node.anyOf ?? []) inspect(child, objectDepth);
  }
  function fail() {throw providerError("MODEL_SCHEMA_UNSUPPORTED");}
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
