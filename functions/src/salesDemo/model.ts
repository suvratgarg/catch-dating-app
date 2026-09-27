import {HttpsError} from "firebase-functions/v2/https";

export const DEMO_CAPABILITY = "synthetic_forms_v1";
export const DEMO_ACTIONS = ["reviewApplication", "prepareReply", "admitGuest",
  "requestAssistance"] as const;
export type DemoAction = typeof DEMO_ACTIONS[number];
export type ContactKind = "email" | "phone";
export interface ContactBinding {kind: ContactKind; digest: string}
export interface Preview {
  brandName: string;
  headline: string;
  scenario: string;
  steps: string[];
  retainedTools: string[];
  limitations: string[];
  cta: string;
}
export type MappingDisposition = "exact" | "manual" | "retained" |
  "unsupported";
export interface FormCapabilityReview {
  questionTypes: MappingDisposition;
  branching: MappingDisposition;
  requiredFields: MappingDisposition;
  scoringApproval: MappingDisposition;
  uploads: MappingDisposition;
}
export interface FieldMappingReview {
  sourceField: string;
  catchField: string | null;
  disposition: MappingDisposition;
}
export interface Blueprint {
  schemaVersion: 1;
  classification: "sales_private";
  blueprintId: string;
  revision: number;
  state: "draft" | "reviewed" | "withdrawn";
  organizerId: string | null;
  candidateId: string | null;
  opportunityId: string | null;
  capability: typeof DEMO_CAPABILITY;
  capabilityRevision: string;
  evidenceRevision: string;
  seedVersion: 1;
  formCapabilityReview: FormCapabilityReview;
  fieldMappings: FieldMappingReview[];
  preview: Preview;
  reviewedByUid: string | null;
  reviewedAt: string | null;
  updatedAt: string;
  updatedByUid: string;
}
export interface Invitation {
  schemaVersion: 1;
  classification: "sales_private";
  invitationId: string;
  blueprintId: string;
  blueprintRevision: number;
  tokenDigest: string;
  contactBinding: ContactBinding | null;
  expiresAt: string;
  revoked: boolean;
  revision: number;
  sessionCap: number;
  sessionCount: number;
  startReceiptCount: number;
  startWindowMinute: number;
  startWindowCount: number;
  currentSessionId: string | null;
  issuedByUid: string;
  issuedAt: string;
  revokedByUid?: string;
  revokedAt?: string;
}
export interface Session {
  schemaVersion: 1;
  classification: "sales_private";
  sessionId: string;
  invitationId: string;
  blueprintId: string;
  blueprintRevision: number;
  actorUid: string;
  createdAt: string;
  expiresAt: string;
  status: "active" | "completed";
  allowedActions: DemoAction[];
  revision: number;
  actionCount: number;
  step: "application" | "reply" | "admission" | "complete";
  application: {applicantName: "Sample Applicant";
    request: "Sample event application";
    review: "pending" | "approved" | "needs_info"};
  reply: {status: "none" | "prepared";
    template: "none" | "welcome" | "clarify"};
  guest: {status: "not_admitted" | "admitted";
    displayName: "Sample Applicant"};
  assistanceRequested: boolean;
}
export interface Identity {
  uid: string;
  token: {email?: unknown; email_verified?: unknown;
    phone_number?: unknown; auth_time?: unknown};
}
export interface CurrentUser {
  disabled: boolean;
  customClaims?: Record<string, unknown>;
  tokensValidAfterTime?: string;
  email?: string;
  emailVerified?: boolean;
  phoneNumber?: string;
}

const ID = /^[A-Za-z0-9_-]{3,128}$/u;
const REQUEST_ID = /^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$/u;
const TEXT = /^[^<>]{1,160}$/u;
export function fail(code: "invalid-argument" | "permission-denied" |
  "failed-precondition" | "not-found" | "resource-exhausted" |
  "unauthenticated" | "already-exists", message: string): never {
  throw new HttpsError(code, message);
}
export function record(value: unknown): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return fail("invalid-argument", "Object required.");
  }
  return value as Record<string, unknown>;
}
export function only(value: Record<string, unknown>, keys: string[]): void {
  if (Object.keys(value).some((key) => !keys.includes(key))) {
    fail("invalid-argument", "Unknown demo field.");
  }
}
export function id(value: unknown): string {
  if (typeof value !== "string" || !ID.test(value)) {
    return fail("invalid-argument", "Invalid identifier.");
  }
  return value;
}
export function optionalId(value: unknown): string | null {
  return value === null || value === undefined ? null : id(value);
}
export function requestId(value: unknown): string {
  if (typeof value !== "string" || !REQUEST_ID.test(value)) {
    return fail("invalid-argument", "Stable requestId required.");
  }
  return value;
}
export function revision(value: unknown): number {
  if (typeof value !== "number" || !Number.isInteger(value) ||
      value < 0 || value > 1000000) {
    return fail("invalid-argument", "Expected revision required.");
  }
  return value;
}
export function text(value: unknown): string {
  if (typeof value !== "string" || !TEXT.test(value.trim()) ||
      [...value].some((character) => {
        const code = character.charCodeAt(0);
        return code < 32 || code === 127;
      })) {
    return fail("invalid-argument", "Invalid public preview text.");
  }
  return value.trim();
}
function textList(value: unknown, max: number): string[] {
  if (!Array.isArray(value) || value.length > max ||
      value.some((part) => typeof part !== "string" || !TEXT.test(part))) {
    return fail("invalid-argument", "Invalid public preview list.");
  }
  return value.map((part) => text(part));
}
export function preview(value: unknown): Preview {
  const obj = record(value);
  only(obj, ["brandName", "headline", "scenario", "steps",
    "retainedTools", "limitations", "cta"]);
  const steps = textList(obj.steps, 5);
  if (steps.length !== 3) {
    return fail("invalid-argument", "Three synthetic steps required.");
  }
  return {brandName: text(obj.brandName), headline: text(obj.headline),
    scenario: text(obj.scenario), steps,
    retainedTools: textList(obj.retainedTools, 8),
    limitations: textList(obj.limitations, 8), cta: text(obj.cta)};
}
function disposition(value: unknown): MappingDisposition {
  if (value === "exact" || value === "manual" ||
      value === "retained" || value === "unsupported") return value;
  return fail("invalid-argument", "Invalid form support status.");
}
export function formReview(value: unknown): FormCapabilityReview {
  const obj = record(value);
  only(obj, ["questionTypes", "branching", "requiredFields",
    "scoringApproval", "uploads"]);
  return {questionTypes: disposition(obj.questionTypes),
    branching: disposition(obj.branching),
    requiredFields: disposition(obj.requiredFields),
    scoringApproval: disposition(obj.scoringApproval),
    uploads: disposition(obj.uploads)};
}
export function fieldMappings(value: unknown): FieldMappingReview[] {
  if (!Array.isArray(value) || value.length > 30) {
    return fail("invalid-argument", "Too many field mappings.");
  }
  const mappings = value.map((part) => {
    const obj = record(part);
    only(obj, ["sourceField", "catchField", "disposition"]);
    return {sourceField: text(obj.sourceField),
      catchField: obj.catchField === null ? null : text(obj.catchField),
      disposition: disposition(obj.disposition)};
  });
  if (new Set(mappings.map((part) => part.sourceField)).size !==
      mappings.length) {
    return fail("invalid-argument", "Duplicate source field mapping.");
  }
  return mappings;
}
export function contact(value: unknown):
  {kind: ContactKind; value: string} | null {
  if (value === null || value === undefined) return null;
  const obj = record(value);
  only(obj, ["kind", "value"]);
  if (obj.kind === "email" && typeof obj.value === "string") {
    const normalized = obj.value.trim().toLowerCase();
    if (normalized.length <= 254 &&
        /^[^\s@]+@[^\s@]+\.[^\s@]+$/u.test(normalized)) {
      return {kind: "email", value: normalized};
    }
  }
  if (obj.kind === "phone" && typeof obj.value === "string" &&
      /^\+[1-9][0-9]{7,14}$/u.test(obj.value)) {
    return {kind: "phone", value: obj.value};
  }
  return fail("invalid-argument", "Invalid contact binding.");
}
export function positive(value: unknown, max: number): number {
  if (typeof value !== "number" || !Number.isInteger(value) ||
      value < 1 || value > max) {
    return fail("invalid-argument", "Invalid bounded count.");
  }
  return value;
}
export function grantToken(value: unknown): string {
  if (typeof value !== "string" || !/^[A-Za-z0-9_-]{43}$/u.test(value)) {
    return fail("permission-denied", "Invalid invitation grant.");
  }
  return value;
}
