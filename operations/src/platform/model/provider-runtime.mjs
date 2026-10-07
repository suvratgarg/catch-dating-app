import {performance} from "node:perf_hooks";
import {setTimeout as delay} from "node:timers/promises";
import {invariant} from "../errors.mjs";
import {compileClosedSchema, positiveLimit, providerError,
  requireModelCapability, snapshotProviderRequest, validateProviderRequest} from "./provider-contract.mjs";

/** @import {ModelProvider, ModelProviderConfig, ModelProviderRequest, ModelProviderResult} from "./provider-contract.mjs" */

/**
 * Fixed vendor protocol supplied by a small adapter; never user/runtime data.
 * @typedef {Object} ProviderProtocol
 * @property {string} providerId
 * @property {Record<string, Record<string, {capabilities:readonly string[], maxOutputTokens:number}>>} catalog
 * @property {string} capability
 * @property {string} endpoint
 * @property {(secret:string)=>Record<string,string>} headers
 * @property {(request:ModelProviderRequest, prompt:string)=>Record<string,unknown>} buildBody
 * @property {(wire:any, request:ModelProviderRequest)=>{usage:ModelProviderResult["metadata"]["tokens"], content:string}} parseResult
 * @property {(schema:Record<string,unknown>)=>void} [validateSchema]
 */

const ERROR_CODES = new Set(["MODEL_PROVIDER_TIMEOUT", "MODEL_PROVIDER_CANCELLED",
  "MODEL_PROVIDER_SECRET_UNAVAILABLE", "MODEL_PROVIDER_RATE_LIMITED", "MODEL_PROVIDER_HTTP_ERROR",
  "MODEL_PROVIDER_RESULT_INVALID", "MODEL_PROVIDER_OUTPUT_INVALID", "MODEL_PROVIDER_RESPONSE_TOO_LARGE",
  "MODEL_PROVIDER_USAGE_INVALID"]);

/** Shared bounded I/O, with no default network or credential ports.
 * The owning workflow authorizes each frozen stage and reserves durable budgets.
 * @param {ProviderProtocol} protocol
 * @param {Partial<ModelProviderConfig>} [options]
 * @returns {ModelProvider}
 */
export function createProviderRuntime(protocol, {enabled = false, modelId, promptVersion, prompt,
  inputSchema, dataPolicy = "public_organizer_only", serverSecretRef,
  resolveSecret, transport, timeoutMs, maxAttempts, maxNetworkRequests,
  maxInputBytes, maxOutputTokens, maxCostMicros} = {}) {
  const model = requireModelCapability(protocol.catalog, protocol.providerId, modelId, protocol.capability);
  invariant(dataPolicy === "public_organizer_only" &&
    typeof promptVersion === "string" && /^[a-z0-9][a-z0-9._-]{0,99}$/i.test(promptVersion) &&
    typeof prompt === "string" && prompt.length > 0 && Buffer.byteLength(prompt) <= 32_000 &&
    typeof serverSecretRef === "string" && /^[a-z0-9][a-z0-9._/-]{0,127}$/i.test(serverSecretRef),
  "MODEL_PROVIDER_CONFIG_INVALID", "A versioned trusted prompt and server secret reference are required.");
  const config = {modelId, promptVersion,
    timeoutMs: positiveLimit(timeoutMs, 120_000),
    maxAttempts: positiveLimit(maxAttempts, 2),
    maxNetworkRequests: positiveLimit(maxNetworkRequests, 2),
    maxInputBytes: positiveLimit(maxInputBytes, 32_768),
    maxOutputTokens: positiveLimit(maxOutputTokens, model.maxOutputTokens),
    maxCostMicros: positiveLimit(maxCostMicros, 100_000_000)};
  invariant(config.maxAttempts <= config.maxNetworkRequests,
    "MODEL_PROVIDER_CONFIG_INVALID", "Attempts must fit the explicit network allowance.");
  const validateInput = compileClosedSchema(inputSchema, {publicInput: true});

  return {async run(request) {
    request = snapshotProviderRequest(request);
    const validateOutput = validateProviderRequest(request, config, validateInput);
    protocol.validateSchema?.(request.outputSchema);
    const signal = request.signal;
    const body = JSON.stringify(protocol.buildBody(request, prompt));
    invariant(Buffer.byteLength(body) <= config.maxInputBytes,
      "MODEL_PROVIDER_INPUT_INVALID", "The full rendered request exceeds its byte cap.");
    if (enabled !== true) throw providerError("MODEL_PROVIDER_DISABLED");
    invariant(typeof transport === "function" && typeof resolveSecret === "function",
      "MODEL_PROVIDER_PORT_REQUIRED", "Enabled providers require trusted transport and secret ports.");
    const controller = new AbortController();
    const started = performance.now();
    const deadline = started + config.timeoutMs;
    let attemptCount = 0;
    let outcome = "not_submitted";
    let timedOut = false;
    let currentResponse;
    const cancelResponse = () => {
      if (currentResponse?.body && !currentResponse.body.locked) {
        void currentResponse.body.cancel().catch(() => undefined);
      }
    };
    const checkDeadline = () => {
      if (performance.now() >= deadline) {timedOut = true; controller.abort();}
      if (controller.signal.aborted) throw providerError(timedOut ? "MODEL_PROVIDER_TIMEOUT" : "MODEL_PROVIDER_CANCELLED",
        {attemptCount, outcome});
    };
    const cancel = () => controller.abort();
    if (signal?.aborted) throw providerError("MODEL_PROVIDER_CANCELLED");
    signal?.addEventListener("abort", cancel, {once: true});
    const timer = setTimeout(() => {timedOut = true; controller.abort();}, config.timeoutMs);
    let stop;
    const aborted = new Promise((_, reject) => {
      stop = () => reject(providerError(timedOut ? "MODEL_PROVIDER_TIMEOUT" : "MODEL_PROVIDER_CANCELLED",
        {attemptCount, outcome}));
      controller.signal.addEventListener("abort", stop, {once: true});
    });
    // Race even injected ports which ignore AbortSignal. Late results never cache.
    const bounded = async (operation) => {
      checkDeadline();
      const value = await Promise.race([operation, aborted]);
      checkDeadline();
      return value;
    };
    try {
      const secret = await bounded(Promise.resolve().then(() => resolveSecret(serverSecretRef,
        {signal: controller.signal})));
      invariant(typeof secret === "string" && secret.length > 0 && !/[\r\n]/.test(secret),
        "MODEL_PROVIDER_SECRET_UNAVAILABLE", "The trusted secret port did not return a credential.");
      while (attemptCount < config.maxAttempts) {
        checkDeadline();
        const response = await bounded(Promise.resolve().then(() => {
          checkDeadline();
          attemptCount++;
          outcome = "unknown";
          return transport(protocol.endpoint, {
          method: "POST", redirect: "error", headers: {"Content-Type": "application/json", ...protocol.headers(secret)}, body, signal: controller.signal,
          });
        }).then((response) => {
          currentResponse = response;
          if (controller.signal.aborted) cancelResponse();
          return response;
        }));
        // Only an explicit rejection is retryable. Transport/5xx/timeout outcomes
        // may have incurred a paid call; never retry them or switch providers.
        if (response?.redirected) throw providerError("MODEL_PROVIDER_HTTP_ERROR", {attemptCount, outcome});
        if (response?.status === 429) {
          outcome = "rejected";
          await bounded(Promise.resolve(response.body?.cancel?.()));
          if (attemptCount === config.maxAttempts) throw providerError("MODEL_PROVIDER_RATE_LIMITED",
            {attemptCount, outcome, status: 429});
          await bounded(delay(100 * attemptCount, undefined, {signal: controller.signal}));
          continue;
        }
        if (response?.status !== 200) {
          throw providerError("MODEL_PROVIDER_HTTP_ERROR", {attemptCount, outcome,
            status: Number.isInteger(response?.status) ? response.status : null});
        }
        const wire = await bounded(readBoundedJson(response, controller.signal));
        const {usage, content} = protocol.parseResult(wire, request);
        let output;
        try { output = JSON.parse(content); } catch {
          throw providerError("MODEL_PROVIDER_OUTPUT_INVALID", {attemptCount, outcome});
        }
        if (!validateOutput(output)) throw providerError("MODEL_PROVIDER_OUTPUT_INVALID", {attemptCount, outcome});
        checkDeadline();
        return {schemaVersion: 1, output,
          // GuardedModelRunner requires integer cost accounting. Preserve the
          // entire reservation; this is not a reported bill or price estimate.
          usage: {inputTokens: usage.inputTotal, outputTokens: usage.outputTotal,
            costMicros: request.maxCostMicros},
          metadata: {providerId: protocol.providerId, modelId: config.modelId,
            requestId: typeof wire.id === "string" && /^[a-z0-9_-]{1,128}$/i.test(wire.id) ? wire.id : null,
            attemptCount, durationMs: Math.ceil(performance.now() - started),
            finishReason: "stop", costBasis: "reserved_ceiling", estimatedCostMicros: null,
            tokens: usage}};
      }
      throw providerError("MODEL_PROVIDER_RATE_LIMITED", {attemptCount, outcome});
    } catch (error) {
      if (controller.signal.aborted) throw providerError(timedOut ? "MODEL_PROVIDER_TIMEOUT" : "MODEL_PROVIDER_CANCELLED",
        {attemptCount, outcome});
      // Never preserve a cause, SDK error text, vendor body or schema value.
      throw providerError(ERROR_CODES.has(error?.code) ? error.code : "MODEL_PROVIDER_TRANSPORT_ERROR",
        {attemptCount, outcome, status: Number.isInteger(error?.details?.status) &&
          error.details.status >= 100 && error.details.status <= 599 ? error.details.status : null});
    } finally {
      clearTimeout(timer);
      cancelResponse();
      signal?.removeEventListener("abort", cancel);
      controller.signal.removeEventListener("abort", stop);
    }
  }};
}

async function readBoundedJson(response, signal) {
  const reader = response.body?.getReader?.();
  if (!reader) throw providerError("MODEL_PROVIDER_RESULT_INVALID");
  const chunks = [];
  let bytes = 0;
  let cancelled = false;
  const cancel = () => {
    if (cancelled) return;
    cancelled = true;
    void reader.cancel().catch(() => undefined);
  };
  signal.addEventListener("abort", cancel, {once: true});
  try {
    while (true) {
      if (signal.aborted) throw providerError("MODEL_PROVIDER_CANCELLED");
      const {done, value} = await reader.read();
      if (done) break;
      bytes += value.byteLength;
      if (bytes > 262_144) throw providerError("MODEL_PROVIDER_RESPONSE_TOO_LARGE");
      chunks.push(Buffer.from(value));
    }
    return JSON.parse(Buffer.concat(chunks).toString("utf8"));
  } finally {
    // A stuck cancel must not prevent the overall deadline from returning.
    signal.removeEventListener("abort", cancel);
    cancel();
    reader.releaseLock();
  }
}
