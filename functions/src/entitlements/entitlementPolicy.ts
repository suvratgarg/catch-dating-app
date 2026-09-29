export interface EntitlementGrantLike {
  grantId: string;
  sku: string;
  unit: string;
  quantityTotal: number;
  quantityConsumed: number;
  validFromMillis: number;
  validUntilMillis: number | null;
  grantedAtMillis: number;
  revokedAtMillis: number | null;
}

export interface EntitlementDocumentLike {
  grants: ReadonlyArray<EntitlementGrantLike>;
}

export interface SkuLimits {
  guests: number | null;
  functions: number | null;
  staffAssignments: number | null;
  momentsPerFunction: number | null;
}

export interface EntitlementSkuCatalog {
  catalogVersion: number;
  skus: Readonly<Record<string, {
    label: string;
    unit: string;
    priceMinor: number | null;
    currency: string;
    limits: SkuLimits;
    capabilitiesAllowed: ReadonlyArray<string>;
    includedFlightDays: number;
    includedWaConversations: number;
    stakeholderSeats: number | null;
  }>>;
}

export type SoftLimit =
  {state: "unlimited"} |
  {state: "within"; remaining: number} |
  {state: "over"; overBy: number};

export function grantRemaining(grant: EntitlementGrantLike): number {
  requireCount(grant.quantityTotal);
  requireCount(grant.quantityConsumed);
  return grant.quantityTotal - grant.quantityConsumed;
}

export function grantIsActive(
  grant: EntitlementGrantLike,
  nowMillis: number,
): boolean {
  requireMillis(nowMillis);
  requireMillis(grant.validFromMillis);
  requireMillis(grant.grantedAtMillis);
  if (grant.validUntilMillis !== null) requireMillis(grant.validUntilMillis);
  if (grant.revokedAtMillis !== null) requireMillis(grant.revokedAtMillis);
  if (grant.revokedAtMillis !== null) return false;
  if (grant.validFromMillis > nowMillis) return false;
  if (grant.validUntilMillis !== null &&
      grant.validUntilMillis <= nowMillis) {
    return false;
  }
  return grantRemaining(grant) > 0;
}

export function selectConsumableGrant(
  doc: EntitlementDocumentLike,
  target: {sku: string; unit: string},
  nowMillis: number,
): EntitlementGrantLike | null {
  const active = doc.grants.filter((grant) =>
    grant.sku === target.sku && grant.unit === target.unit &&
    grantIsActive(grant, nowMillis));
  if (active.length === 0) return null;
  active.sort((a, b) =>
    (a.validUntilMillis ?? Number.MAX_SAFE_INTEGER) -
      (b.validUntilMillis ?? Number.MAX_SAFE_INTEGER) ||
    a.grantedAtMillis - b.grantedAtMillis ||
    a.grantId.localeCompare(b.grantId));
  return active[0];
}

export function resolveSkuLimits(
  catalog: EntitlementSkuCatalog,
  sku: string,
): SkuLimits | null {
  const entry = catalog.skus[sku];
  if (!entry) return null;
  return entry.limits;
}

export function evaluateSoftLimit(input: {
  used: number;
  limit: number | null;
}): SoftLimit {
  requireCount(input.used);
  if (input.limit === null) return {state: "unlimited"};
  requireCount(input.limit);
  if (input.used > input.limit) {
    return {state: "over", overBy: input.used - input.limit};
  }
  return {state: "within", remaining: input.limit - input.used};
}

function requireMillis(value: number): void {
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new RangeError(
      "Entitlement timing must be non-negative safe milliseconds.");
  }
}

function requireCount(value: number): void {
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new RangeError("Entitlement counts must be non-negative integers.");
  }
}
