import {createHash} from "node:crypto";
import {isWhatsappStopCommand} from "../organizers/organizerCampaignModel";

/** Structural ReadinessScope compatibility, without a runtime dependency. */
export interface ArchiveReadinessScope {
  projectId: string;
  wabaId: string;
  phoneNumberId: string;
  recipientUid: string;
  endpointHash: string;
  evidenceSha256: string;
}
export interface ArchiveReadinessApproval {
  approvalId: string;
  action: "create" | "revoke";
  scope: ArchiveReadinessScope;
  atomicIngressStartedAtMillis: number;
  reviewedAtMillis: number;
  expiresAtMillis: number;
}

/**
 * Trusted server-side input from an independently authorized audit store, NOT
 * request JSON or archive metadata. The audit identified by sourceAuditSha256
 * must establish source authenticity, complete sender/endpoint history from
 * inception, lossless normalization, retention/export gaps, late deliveries and
 * the exact atomic-ingress cutover. A digest alone establishes none of those.
 * Store access, approval fencing and the audit itself are adapter obligations.
 */
export interface TrustedCatchHistoryArchivePin {
  schema: "catch.whatsapp-history-audit-pin/v1";
  approvalId: string;
  scope: ArchiveReadinessScope;
  sourceAuditSha256: string;
  atomicIngressStartedAtMillis: number;
  coveredThroughMillis: number;
}
export interface VerifiedCatchArchiveHistory {
  approvalId: string;
  scope: ArchiveReadinessScope;
  provenanceSha256: string;
  historyFromMillis: 0;
  coveredThroughMillis: number;
  atomicIngressStartedAtMillis: number;
}

const maxBytes = 8 * 1024 * 1024;
const maxSegments = 4096;
const maxRecords = 100000;
const sha = (value: string | Uint8Array): string =>
  createHash("sha256").update(value).digest("hex");
const hash = (value: unknown): value is string =>
  typeof value === "string" && /^[a-f0-9]{64}$/u.test(value);
const millis = (value: unknown): value is number =>
  typeof value === "number" && Number.isSafeInteger(value) && value >= 0;
const uid = (value: unknown): value is string =>
  typeof value === "string" && /^[A-Za-z0-9_-]{1,128}$/u.test(value);
function fail(): never {
  // Never expose private message content, endpoint or archive bytes in errors.
  throw new Error("Catch historical archive verification unavailable.");
}
function object(value: unknown, keys: string[]): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value) ||
      Object.keys(value).sort().join("|") !== keys.sort().join("|")) fail();
  return value as Record<string, unknown>;
}
function scope(value: unknown): ArchiveReadinessScope {
  const s = object(value, ["projectId", "wabaId", "phoneNumberId",
    "recipientUid", "endpointHash", "evidenceSha256"]);
  if (typeof s.projectId !== "string" ||
      !/^[a-z][a-z0-9-]{4,28}[a-z0-9]$/u.test(s.projectId) ||
      typeof s.wabaId !== "string" || !/^[0-9]{1,32}$/u.test(s.wabaId) ||
      typeof s.phoneNumberId !== "string" ||
      !/^[0-9]{1,32}$/u.test(s.phoneNumberId) || !uid(s.recipientUid) ||
      !hash(s.endpointHash) || !hash(s.evidenceSha256)) fail();
  return {projectId: s.projectId, wabaId: s.wabaId,
    phoneNumberId: s.phoneNumberId, recipientUid: s.recipientUid,
    endpointHash: s.endpointHash, evidenceSha256: s.evidenceSha256};
}
function identity(s: ArchiveReadinessScope): string[] {
  return [s.projectId, s.wabaId, s.phoneNumberId, s.recipientUid,
    s.endpointHash];
}

/**
 * Offline verifier for ONE deliberately narrow Catch normalization format;
 * Not a native Meta export parser. UTF-8 JSON must round-trip exactly
 * through JSON.stringify (no duplicate keys, whitespace or alternate encoding).
 * Root: {schema, identity:{projectId,wabaId,phoneNumberId,recipientUid,
 * endpointHash}, atomicIngressStartedAtMillis, segments:[{fromMillis,
 * throughMillis, records:[{messageId,receivedAtMillis,endpointHash,messageType,
 * text,textTruncated}]}]}. Intervals are adjacent [from, through), starting at
 * epoch zero and ending at the independently verified atomic cutover. Records
 * describe ALL inbound messages for this endpoint, ordered by receipt time.
 * Only complete text records are supported; other input fails closed.
 *
 * Empty input cannot clear history. A nonempty archive still
 * proves no completeness by itself: only a separately audited trusted pin can
 * authorize its use. This performs no I/O and grants no send authority.
 */
export function verifyCatchWhatsappHistoryArchive(input: {
  archiveBytes: Uint8Array;
  approval: ArchiveReadinessApproval;
  trustedPin: TrustedCatchHistoryArchivePin;
  nowMillis: number;
}): VerifiedCatchArchiveHistory {
  const {approval: a, trustedPin: p, nowMillis: now} = input;
  if (!a || !p || !uid(a.approvalId) || a.action !== "create" ||
      !millis(now) || !millis(a.reviewedAtMillis) ||
      !millis(a.expiresAtMillis) || a.reviewedAtMillis > now ||
      a.expiresAtMillis <= now || a.expiresAtMillis <= a.reviewedAtMillis ||
      a.expiresAtMillis - a.reviewedAtMillis > 86400000 ||
      !millis(a.atomicIngressStartedAtMillis) ||
      a.atomicIngressStartedAtMillis === 0 ||
      a.atomicIngressStartedAtMillis > a.reviewedAtMillis) fail();
  object(p, ["schema", "approvalId", "scope", "sourceAuditSha256",
    "atomicIngressStartedAtMillis", "coveredThroughMillis"]);
  const expected = scope(a.scope);
  const pinned = scope(p.scope);
  if (p.schema !== "catch.whatsapp-history-audit-pin/v1" ||
      p.approvalId !== a.approvalId || !hash(p.sourceAuditSha256) ||
      JSON.stringify(expected) !== JSON.stringify(pinned) ||
      p.atomicIngressStartedAtMillis !== a.atomicIngressStartedAtMillis ||
      p.coveredThroughMillis !== a.atomicIngressStartedAtMillis ||
      !(input.archiveBytes instanceof Uint8Array) ||
      input.archiveBytes.byteLength === 0 ||
      input.archiveBytes.byteLength > maxBytes) fail();
  // Copy bytes before hashing/parsing so caller-owned buffers cannot change.
  const bytes = Buffer.from(input.archiveBytes);
  if (sha(bytes) !== expected.evidenceSha256) fail();
  let parsed: unknown;
  try {
    const text = new TextDecoder("utf-8", {fatal: true}).decode(bytes);
    parsed = JSON.parse(text);
    if (!Buffer.from(JSON.stringify(parsed), "utf8").equals(bytes)) fail();
  } catch {
    fail();
  }
  const root = object(parsed, ["schema", "identity",
    "atomicIngressStartedAtMillis", "segments"]);
  const archiveIdentity = object(root.identity, ["projectId", "wabaId",
    "phoneNumberId", "recipientUid", "endpointHash"]);
  if (root.schema !== "catch.whatsapp-history-archive/v1" ||
      JSON.stringify([archiveIdentity.projectId, archiveIdentity.wabaId,
        archiveIdentity.phoneNumberId, archiveIdentity.recipientUid,
        archiveIdentity.endpointHash]) !== JSON.stringify(identity(expected)) ||
      root.atomicIngressStartedAtMillis !== a.atomicIngressStartedAtMillis ||
      !Array.isArray(root.segments) || root.segments.length === 0 ||
      root.segments.length > maxSegments) fail();
  let cursor = 0;
  let lastReceived = 0;
  const messageIds = new Set<string>();
  for (const rawSegment of root.segments) {
    const segment = object(rawSegment,
      ["fromMillis", "throughMillis", "records"]);
    if (segment.fromMillis !== cursor || !millis(segment.throughMillis) ||
        segment.throughMillis <= cursor ||
        segment.throughMillis > p.coveredThroughMillis ||
        !Array.isArray(segment.records)) fail();
    for (const rawRecord of segment.records) {
      const record = object(rawRecord, ["messageId", "receivedAtMillis",
        "endpointHash", "messageType", "text", "textTruncated"]);
      if (typeof record.messageId !== "string" ||
          !/^[\x21-\x7e]{1,240}$/u.test(record.messageId) ||
          messageIds.has(record.messageId) || messageIds.size >= maxRecords ||
          !millis(record.receivedAtMillis) ||
          record.receivedAtMillis < cursor ||
          record.receivedAtMillis >= segment.throughMillis ||
          record.receivedAtMillis < lastReceived ||
          record.endpointHash !== expected.endpointHash ||
          record.messageType !== "text" || record.textTruncated !== false ||
          typeof record.text !== "string" || record.text.length === 0 ||
          record.text.length > 4096 || isWhatsappStopCommand(record.text)) {
        fail();
      }
      messageIds.add(record.messageId);
      lastReceived = record.receivedAtMillis;
    }
    cursor = segment.throughMillis;
  }
  if (cursor !== p.coveredThroughMillis || messageIds.size === 0) fail();
  return {approvalId: a.approvalId, scope: expected,
    provenanceSha256: sha(JSON.stringify([p.schema, p.approvalId,
      ...identity(expected), expected.evidenceSha256, p.sourceAuditSha256,
      p.atomicIngressStartedAtMillis, p.coveredThroughMillis])),
    historyFromMillis: 0, coveredThroughMillis: cursor,
    atomicIngressStartedAtMillis: a.atomicIngressStartedAtMillis};
}
