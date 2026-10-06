import {createHash} from "node:crypto";

export type CatchCapability = "review" | "reply" | "receive";
export interface CatchAuthorityIdentity {projectId: string; uid: string}
export interface CatchAuthorityBinding extends CatchAuthorityIdentity {
  revision: number;
  incarnation: string;
  capability: CatchCapability;
  endpointHash: string | null;
}
export interface CatchPendingGrant {
  nonce: string;
  issuer: CatchAuthorityBinding;
  capabilities: CatchCapability[];
  endpointHash: string | null;
  expiresAtMillis: number;
}
export interface CatchAppAuthority extends CatchAuthorityIdentity {
  schemaVersion: 1;
  revision: number;
  incarnation: string | null;
  state: "denied" | "granting" | "active";
  authNotBeforeSeconds: number;
  updatedAtMillis: number;
  capabilities: CatchCapability[];
  endpointHash: string | null;
  pending: CatchPendingGrant | null;
  /** Audit only; issuer changes do not revoke active descendants. */
  grantedBy: CatchAuthorityBinding | null;
}

/**
 * Trusted server observation, never request JSON. Creation time must retain
 * authoritative Firebase creation identity precision, not a profile timestamp.
 * Do NOT derive it via Date.parse(getUser().metadata.creationTime): Admin SDK
 * formats that value with toUTCString(), losing milliseconds. An adapter needs
 * authoritative raw precision or a separately reviewed identity alternative.
 * These observations do not fence simultaneous external Firebase mutations.
 */
export interface CatchFirebaseObservation extends CatchAuthorityIdentity {
  creationTimeMillis: number;
  observedAtMillis: number;
  disabled: boolean;
  /** Projection of only the two roles relevant to this Catch model. */
  relevantRoles: ("adminOwner" | "support")[];
  endpointHash: string | null;
  tokensValidAfterMillis: number;
}
/** Signature/project/UID verification is a mandatory adapter responsibility. */
export interface CatchVerifiedSession extends CatchAuthorityIdentity {
  authTimeSeconds: number;
  expiresAtSeconds: number;
}
export interface CatchAuthorityPrincipal {
  record: unknown;
  auth: unknown;
  session?: unknown;
}

const capabilities = ["review", "reply", "receive"] as const;
const observationLifetime = 30000;
const grantLifetime = 15 * 60 * 1000;
const hash = (value: unknown): value is string =>
  typeof value === "string" && /^[a-f0-9]{64}$/u.test(value);
const integer = (value: unknown): value is number =>
  typeof value === "number" && Number.isSafeInteger(value) && value >= 0;
function deny(): never {
  throw new Error("Catch app authority unavailable.");
}
function object(value: unknown, keys: string[]): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value) ||
      Object.keys(value).sort().join("|") !== keys.sort().join("|")) deny();
  return value as Record<string, unknown>;
}
function identity(value: CatchAuthorityIdentity): void {
  if (typeof value.projectId !== "string" ||
      !/^[a-z][a-z0-9-]{4,28}[a-z0-9]$/u.test(value.projectId) ||
      typeof value.uid !== "string" ||
      !/^[A-Za-z0-9_-]{1,128}$/u.test(value.uid)) deny();
}
function sameIdentity(a: CatchAuthorityIdentity, b: CatchAuthorityIdentity) {
  return a.projectId === b.projectId && a.uid === b.uid;
}
function readCapabilities(value: unknown): CatchCapability[] {
  if (!Array.isArray(value) || value.length > capabilities.length ||
      new Set(value).size !== value.length ||
      !value.every((entry) => capabilities.some((c) => entry === c))) deny();
  return [...value].sort();
}
function endpoint(caps: CatchCapability[], value: unknown): void {
  if (caps.includes("receive") ? !hash(value) : value !== null) deny();
}
function binding(value: unknown): CatchAuthorityBinding {
  const b = object(value, ["projectId", "uid", "revision", "incarnation",
    "capability", "endpointHash"]);
  identity(b as unknown as CatchAuthorityIdentity);
  if (!integer(b.revision) || b.revision === 0 || !hash(b.incarnation) ||
      !capabilities.some((c) => c === b.capability)) deny();
  endpoint([b.capability as CatchCapability], b.endpointHash);
  return {...b} as unknown as CatchAuthorityBinding;
}

/** Missing/malformed records supply no active default or revision reset. */
export function readCatchAppAuthority(value: unknown): CatchAppAuthority {
  const s = object(value, ["schemaVersion", "projectId", "uid", "revision",
    "incarnation", "state", "authNotBeforeSeconds", "updatedAtMillis",
    "capabilities", "endpointHash", "pending", "grantedBy"]);
  identity(s as unknown as CatchAuthorityIdentity);
  if (s.schemaVersion !== 1 || !integer(s.revision) || s.revision === 0 ||
      !integer(s.authNotBeforeSeconds) ||
      !Number.isSafeInteger(s.authNotBeforeSeconds * 1000) ||
      !integer(s.updatedAtMillis) ||
      !(s.incarnation === null || hash(s.incarnation))) deny();
  const caps = readCapabilities(s.capabilities);
  endpoint(caps, s.endpointHash);
  let pending: CatchPendingGrant | null = null;
  if (s.state === "granting") {
    const p = object(s.pending, ["nonce", "issuer", "capabilities",
      "endpointHash", "expiresAtMillis"]);
    const desired = readCapabilities(p.capabilities);
    const issuer = binding(p.issuer);
    endpoint(desired, p.endpointHash);
    if (!hash(p.nonce) || desired.length === 0 ||
        issuer.projectId !== s.projectId || issuer.uid === s.uid ||
        issuer.capability !== "review" || !integer(p.expiresAtMillis) ||
        p.expiresAtMillis <= s.updatedAtMillis ||
        p.expiresAtMillis - s.updatedAtMillis > grantLifetime) deny();
    pending = {...p, issuer, capabilities: desired} as CatchPendingGrant;
  } else if (s.pending !== null) deny();
  const grantedBy = s.grantedBy === null ? null : binding(s.grantedBy);
  if (grantedBy && (grantedBy.projectId !== s.projectId ||
      grantedBy.uid === s.uid || grantedBy.capability !== "review")) deny();
  if (s.state === "active") {
    if (!hash(s.incarnation) || caps.length === 0) deny();
  } else if (s.state === "denied" || s.state === "granting") {
    if (caps.length !== 0 || s.endpointHash !== null || grantedBy !== null ||
        (s.state === "granting" && !hash(s.incarnation))) deny();
  } else deny();
  return {...s, capabilities: caps, pending, grantedBy} as unknown as
    CatchAppAuthority;
}

function readAuth(value: unknown, now: number): CatchFirebaseObservation {
  const a = object(value, ["projectId", "uid", "creationTimeMillis",
    "observedAtMillis", "disabled", "relevantRoles", "endpointHash",
    "tokensValidAfterMillis"]);
  identity(a as unknown as CatchAuthorityIdentity);
  if (!integer(now) || !integer(a.creationTimeMillis) ||
      !integer(a.observedAtMillis) ||
      a.creationTimeMillis > a.observedAtMillis ||
      a.observedAtMillis > now ||
      now - a.observedAtMillis > observationLifetime ||
      a.disabled !== false || !integer(a.tokensValidAfterMillis) ||
      a.tokensValidAfterMillis > a.observedAtMillis ||
      !(a.endpointHash === null || hash(a.endpointHash)) ||
      !Array.isArray(a.relevantRoles) || a.relevantRoles.length > 2 ||
      new Set(a.relevantRoles).size !== a.relevantRoles.length ||
      !a.relevantRoles.every((r) => r === "adminOwner" || r === "support")) {
    deny();
  }
  return {...a, relevantRoles: [...a.relevantRoles]} as unknown as
    CatchFirebaseObservation;
}
function incarnation(auth: CatchFirebaseObservation): string {
  return createHash("sha256").update(JSON.stringify([
    "catch.firebase-creation/v1", auth.projectId, auth.uid,
    auth.creationTimeMillis])).digest("hex");
}
function role(auth: CatchFirebaseObservation, cap: CatchCapability): void {
  if (cap === "review" && !auth.relevantRoles.includes("adminOwner")) deny();
  if (cap === "reply" && !auth.relevantRoles.includes("adminOwner") &&
      !auth.relevantRoles.includes("support")) deny();
}

/**
 * Pure decision only. Store must read the record in the SAME transaction as the
 * new send claim/readiness mutation; a saved binding is never fresh authority.
 * Revoke committed first denies a new claim. An earlier committed claim may
 * finish. Keep existing Firebase, STOP, preference and permanent-dedupe checks.
 */
export function authorizeCatchAppCapability(principal: CatchAuthorityPrincipal,
  capability: CatchCapability, now: number,
  expected: CatchAuthorityIdentity & {endpointHash?: string}):
  CatchAuthorityBinding {
  const s = readCatchAppAuthority(principal.record);
  const a = readAuth(principal.auth, now);
  identity(expected);
  if (!capabilities.includes(capability) || !sameIdentity(s, expected) ||
      !sameIdentity(a, s) || s.state !== "active" ||
      s.updatedAtMillis > now || s.incarnation !== incarnation(a) ||
      !s.capabilities.includes(capability)) deny();
  role(a, capability);
  if (capability === "receive") {
    if (!hash(expected.endpointHash) ||
        s.endpointHash !== expected.endpointHash ||
        a.endpointHash !== expected.endpointHash) deny();
  } else {
    const t = object(principal.session,
      ["projectId", "uid", "authTimeSeconds", "expiresAtSeconds"]);
    if (!sameIdentity(t as unknown as CatchAuthorityIdentity, s) ||
        !integer(t.authTimeSeconds) || !integer(t.expiresAtSeconds) ||
        !Number.isSafeInteger(t.authTimeSeconds * 1000) ||
        !Number.isSafeInteger(t.expiresAtSeconds * 1000) ||
        t.authTimeSeconds * 1000 > now || t.expiresAtSeconds * 1000 <= now ||
        t.expiresAtSeconds <= t.authTimeSeconds ||
        t.authTimeSeconds < s.authNotBeforeSeconds ||
        t.authTimeSeconds * 1000 < a.tokensValidAfterMillis ||
        t.authTimeSeconds < Math.floor(a.creationTimeMillis / 1000)) deny();
  }
  return {projectId: s.projectId, uid: s.uid, revision: s.revision,
    incarnation: s.incarnation!, capability,
    endpointHash: capability === "receive" ? s.endpointHash : null};
}

function nextRevision(current: CatchAppAuthority, now: number): number {
  if (!integer(now) || now < current.updatedAtMillis ||
      current.revision >= Number.MAX_SAFE_INTEGER) deny();
  return current.revision + 1;
}
function cutoff(previous: number, now: number): number {
  const result = Math.max(previous, Math.floor(now / 1000) + 1);
  if (!Number.isSafeInteger(result * 1000)) deny();
  return result;
}

/**
 * Denial is the ONLY initialization. Adapter authorizes the command and uses
 * create-only/CAS with expectedRevision (zero only for truly new records).
 * Never delete/reset this durable record or add TTL. No owner bootstrap exists.
 */
export function denyCatchAppAuthority(current: unknown | null,
  expected: CatchAuthorityIdentity, expectedRevision: number,
  now: number): CatchAppAuthority {
  identity(expected);
  if (!integer(now) || !integer(expectedRevision)) deny();
  const s = current === null ? null : readCatchAppAuthority(current);
  if (s ? !sameIdentity(s, expected) || s.revision !== expectedRevision :
    expectedRevision !== 0) deny();
  return {schemaVersion: 1, projectId: expected.projectId, uid: expected.uid,
    revision: s ? nextRevision(s, now) : 1,
    incarnation: s?.incarnation ?? null, state: "denied",
    authNotBeforeSeconds: cutoff(s?.authNotBeforeSeconds ?? 0, now),
    updatedAtMillis: now, capabilities: [], endpointHash: null, pending: null,
    grantedBy: null};
}

/** Both target and issuer records must be part of the caller's CAS read set. */
export function prepareCatchAppGrant(current: unknown, input: {
  expectedRevision: number; nonce: string; capabilities: CatchCapability[];
  endpointHash: string | null; expiresAtMillis: number;
}, owner: CatchAuthorityPrincipal, targetAuth: unknown,
now: number): CatchAppAuthority {
  object(input, ["expectedRevision", "nonce", "capabilities",
    "endpointHash", "expiresAtMillis"]);
  const s = readCatchAppAuthority(current);
  const a = readAuth(targetAuth, now);
  const ownerRecord = readCatchAppAuthority(owner.record);
  const issuer = authorizeCatchAppCapability(owner, "review", now,
    {projectId: s.projectId, uid: ownerRecord.uid});
  const caps = readCapabilities(input.capabilities);
  endpoint(caps, input.endpointHash);
  if (!sameIdentity(a, s) || s.uid === issuer.uid ||
      s.revision !== input.expectedRevision || !hash(input.nonce) ||
      caps.length === 0 || !integer(input.expiresAtMillis) ||
      input.expiresAtMillis <= now ||
      input.expiresAtMillis - now > grantLifetime ||
      (caps.includes("receive") && input.endpointHash !== a.endpointHash)) {
    deny();
  }
  caps.forEach((cap) => role(a, cap));
  return {schemaVersion: 1, projectId: s.projectId, uid: s.uid,
    revision: nextRevision(s, now), incarnation: incarnation(a),
    state: "granting",
    authNotBeforeSeconds: cutoff(s.authNotBeforeSeconds, now),
    updatedAtMillis: now, capabilities: [], endpointHash: null,
    grantedBy: null,
    pending: {nonce: input.nonce, issuer, capabilities: caps,
      endpointHash: input.endpointHash,
      expiresAtMillis: input.expiresAtMillis}};
}

/** Compare pending nonce/revision AND current issuer revision/incarnation. */
export function finalizeCatchAppGrant(current: unknown,
  expectedRevision: number,
  nonce: string, owner: CatchAuthorityPrincipal, targetAuth: unknown,
  now: number): CatchAppAuthority {
  const s = readCatchAppAuthority(current);
  const a = readAuth(targetAuth, now);
  if (s.state !== "granting" || !s.pending ||
      s.revision !== expectedRevision || s.pending.nonce !== nonce ||
      !hash(nonce) || now >= s.pending.expiresAtMillis ||
      !sameIdentity(a, s) || incarnation(a) !== s.incarnation) deny();
  const issuer = authorizeCatchAppCapability(owner, "review", now,
    {projectId: s.projectId, uid: s.pending.issuer.uid});
  assertCatchAuthorityBinding(issuer, s.pending.issuer);
  s.pending.capabilities.forEach((cap) => role(a, cap));
  if (s.pending.capabilities.includes("receive") &&
      s.pending.endpointHash !== a.endpointHash) deny();
  return {...s, revision: nextRevision(s, now), state: "active",
    updatedAtMillis: now, capabilities: [...s.pending.capabilities],
    endpointHash: s.pending.endpointHash, pending: null, grantedBy: issuer};
}

/** Bind reviewed snapshots to current transaction decisions. */
export function assertCatchAuthorityBinding(current: unknown,
  expected: unknown): void {
  const a = binding(current);
  const b = binding(expected);
  if (!sameIdentity(a, b) || a.revision !== b.revision ||
      a.incarnation !== b.incarnation || a.capability !== b.capability ||
      a.endpointHash !== b.endpointHash) deny();
}

export function catchReadinessAuthorityBindings(input: {
  projectId: string; reviewerUid: string; recipientUid: string;
  endpointHash: string; reviewer: CatchAuthorityPrincipal;
  recipient: CatchAuthorityPrincipal;
}, now: number): {
  reviewer: CatchAuthorityBinding; recipient: CatchAuthorityBinding;
} {
  return {
    reviewer: authorizeCatchAppCapability(input.reviewer, "review", now,
      {projectId: input.projectId, uid: input.reviewerUid}),
    recipient: authorizeCatchAppCapability(input.recipient, "receive", now,
      {projectId: input.projectId, uid: input.recipientUid,
        endpointHash: input.endpointHash}),
  };
}

export function catchReplyAuthorityBindings(input: Parameters<
  typeof catchReadinessAuthorityBindings>[0] & {
    actorUid: string; actor: CatchAuthorityPrincipal;
  }, now: number): {
    actor: CatchAuthorityBinding; reviewer: CatchAuthorityBinding;
    recipient: CatchAuthorityBinding;
  } {
  return {...catchReadinessAuthorityBindings(input, now),
    actor: authorizeCatchAppCapability(input.actor, "reply", now,
      {projectId: input.projectId, uid: input.actorUid})};
}
