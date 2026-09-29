import {
  EntitlementSkuCatalog,
  SkuLimits,
  evaluateSoftLimit,
} from "./entitlementPolicy";

export interface ProgramUsage {
  guests: number;
  functions: number;
  staffAssignments: number;
}

export interface ProgramLimitBreach {
  dimension: "guests" | "functions" | "staffAssignments";
  limit: number;
  used: number;
  overBy: number;
}

export type ProgramUsageVerdict =
  {state: "ok"} |
  {state: "softBlock"; breaches: ProgramLimitBreach[]};

/**
 * Evaluates every program-scoped limit in deterministic order. Breaching any
 * limit produces a soft block — callers surface an attention item rather than
 * hard-failing the operation, per the entitlement contract notes.
 */
export function evaluateProgramUsage(
  limits: SkuLimits,
  usage: ProgramUsage,
): ProgramUsageVerdict {
  const breaches: ProgramLimitBreach[] = [];
  const check = (
    dimension: ProgramLimitBreach["dimension"],
    limit: number | null,
    used: number,
  ): void => {
    const verdict = evaluateSoftLimit({used, limit});
    if (verdict.state === "over" && limit !== null) {
      breaches.push({dimension, limit, used, overBy: verdict.overBy});
    }
  };
  check("guests", limits.guests, usage.guests);
  check("functions", limits.functions, usage.functions);
  check("staffAssignments", limits.staffAssignments,
    usage.staffAssignments);
  return breaches.length === 0 ? {state: "ok"} :
    {state: "softBlock", breaches};
}

/**
 * Per-function moment ceiling is evaluated separately from program totals:
 * the limit counts armed moments on one function, not a program-wide pool.
 */
export function momentsWithinFunctionCeiling(
  limits: SkuLimits,
  armedMomentsForFunction: number,
): boolean {
  return evaluateSoftLimit({
    used: armedMomentsForFunction,
    limit: limits.momentsPerFunction,
  }).state !== "over";
}

/**
 * Enabled program capabilities must be a subset of the entitlement ceiling.
 * Returns the disallowed capabilities in deterministic sorted order.
 */
export function disallowedCapabilities(
  capabilitiesAllowed: ReadonlyArray<string>,
  enabled: ReadonlyArray<string>,
): string[] {
  const allowed = new Set(capabilitiesAllowed);
  return [...new Set(enabled.filter((c) => !allowed.has(c)))].sort();
}

/**
 * Resolves the effective program ceiling: prefer the snapshot stored on the
 * program document (immutable grant terms); fall back to catalog limits for
 * the snapshot sku only when the snapshot lacks a dimension.
 */
export function resolveProgramCeiling(
  catalog: EntitlementSkuCatalog,
  snapshot: {
    sku: string;
    limits: Partial<SkuLimits>;
    capabilitiesAllowed?: ReadonlyArray<string>;
  } | null,
): {limits: SkuLimits; capabilitiesAllowed: ReadonlyArray<string>} | null {
  if (snapshot === null) return null;
  const catalogEntry = catalog.skus[snapshot.sku];
  const catalogLimits = catalogEntry?.limits;
  return {
    limits: {
      guests: snapshot.limits.guests === undefined ?
        catalogLimits?.guests ?? null : snapshot.limits.guests,
      functions: snapshot.limits.functions === undefined ?
        catalogLimits?.functions ?? null : snapshot.limits.functions,
      staffAssignments: snapshot.limits.staffAssignments === undefined ?
        catalogLimits?.staffAssignments ?? null :
        snapshot.limits.staffAssignments,
      momentsPerFunction: snapshot.limits.momentsPerFunction === undefined ?
        catalogLimits?.momentsPerFunction ?? null :
        snapshot.limits.momentsPerFunction,
    },
    capabilitiesAllowed: snapshot.capabilitiesAllowed !== undefined ?
      snapshot.capabilitiesAllowed :
      catalogEntry?.capabilitiesAllowed ?? [],
  };
}
