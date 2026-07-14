import {OperationsError, invariant} from "./errors.mjs";

export const BUDGET_DIMENSIONS = Object.freeze([
  "workItems",
  "networkRequests",
  "modelCalls",
  "modelInputTokens",
  "modelOutputTokens",
  "modelCostMicros",
  "publicWrites",
]);

export class BudgetLedger {
  constructor({limits = {}, consumed = {}} = {}) {
    this.limits = normalizeBudget(limits, Number.MAX_SAFE_INTEGER);
    this.consumed = normalizeBudget(consumed, 0);
    for (const key of BUDGET_DIMENSIONS) {
      invariant(this.consumed[key] <= this.limits[key], "BUDGET_CORRUPT", `${key} consumption exceeds its limit.`);
    }
  }

  canConsume(request) {
    const normalized = normalizeBudget(request, 0);
    return BUDGET_DIMENSIONS.every((key) => this.consumed[key] + normalized[key] <= this.limits[key]);
  }

  consume(request, {reason = "unspecified"} = {}) {
    const normalized = normalizeBudget(request, 0);
    const exceeded = BUDGET_DIMENSIONS.filter((key) => this.consumed[key] + normalized[key] > this.limits[key]);
    if (exceeded.length > 0) {
      throw new OperationsError("BUDGET_EXCEEDED", `Budget would be exceeded for ${exceeded.join(", ")}.`, {
        details: {reason, exceeded, request: normalized, snapshot: this.snapshot()},
        exitCode: 4,
      });
    }
    for (const key of BUDGET_DIMENSIONS) this.consumed[key] += normalized[key];
    return this.snapshot();
  }

  remaining() {
    return Object.fromEntries(BUDGET_DIMENSIONS.map((key) => [key, this.limits[key] - this.consumed[key]]));
  }

  snapshot() {
    return {
      schemaVersion: 1,
      limits: {...this.limits},
      consumed: {...this.consumed},
      remaining: this.remaining(),
    };
  }
}

function normalizeBudget(value, fallback) {
  return Object.fromEntries(BUDGET_DIMENSIONS.map((key) => {
    const current = value[key] ?? fallback;
    invariant(Number.isSafeInteger(current) && current >= 0, "INVALID_BUDGET", `${key} must be a non-negative safe integer.`, {
      key,
      value: current,
    });
    return [key, current];
  }));
}
