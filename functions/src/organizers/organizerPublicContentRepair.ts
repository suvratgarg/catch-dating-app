import crypto from "node:crypto";
import {
  isAuthorityFactLabel,
  isPublicSourceLink,
  organizerPublicContentIssues,
  sourceLinkKey,
  type OrganizerPublicContent,
  type OrganizerPublicContentIssue,
} from "./organizerPublicContent";
import {
  schemaErrorMessages,
  validateOrganizerDocument,
} from "../shared/generated/schemaValidators";

/** Fields a reviewed replacement may set during a public-content repair. */
export const organizerPublicContentReplacementFields = [
  "description",
  "publicPage.seoTitle",
  "publicPage.seoDescription",
  "publicProfile.headline",
  "publicProfile.summary",
  "publicProfile.sourceSummary",
  "publicProfile.facts",
  "publicProfile.eventEvidence",
  "publicSources",
] as const;

export interface OrganizerPublicContentRepairPlan {
  path: string;
  /** Firestore dot-path update; empty when the document is already clean. */
  patch: Record<string, unknown>;
  /** Current stored value of every patched field. */
  before: Record<string, unknown>;
  /** Policy issues left after the patch; apply refuses while any remain. */
  remainingIssues: OrganizerPublicContentIssue[];
  /** Contract errors the patch would introduce; apply refuses these too. */
  schemaRegressions: string[];
  /** Binds an apply to the reviewed `before` state and patch. */
  hash: string;
}

type DocumentData = Record<string, unknown>;

/**
 * Plans the cleanup of one organizer's public fields. Operator-only lists,
 * authority facts and sources without a distinct public link are removed
 * mechanically; wording issues need a reviewed replacement value.
 * @param {string} path Organizer document path.
 * @param {DocumentData} organizer Stored organizer document.
 * @param {DocumentData} replacements Reviewed dot-path replacement values.
 * @return {OrganizerPublicContentRepairPlan} Deterministic repair plan.
 */
export function planOrganizerPublicContentRepair(
  path: string,
  organizer: DocumentData,
  replacements: DocumentData = {}
): OrganizerPublicContentRepairPlan {
  const allowed = new Set<string>(organizerPublicContentReplacementFields);
  for (const field of Object.keys(replacements)) {
    if (!allowed.has(field)) {
      throw new Error(`${path}: ${field} is not a replaceable public field.`);
    }
  }
  const candidate: DocumentData = {...replacements};
  const read = (field: string) =>
    field in candidate ? candidate[field] : valueAt(organizer, field);

  for (const field of [
    "publicProfile.fitNotes",
    "publicProfile.missingEvidence",
  ]) {
    const value = valueAt(organizer, field);
    if (Array.isArray(value) && value.length > 0) candidate[field] = [];
  }
  const facts = read("publicProfile.facts");
  if (Array.isArray(facts)) {
    candidate["publicProfile.facts"] = facts.filter((fact) =>
      !isAuthorityFactLabel(String((fact as DocumentData)?.label ?? "")));
  }
  const sources = read("publicSources");
  if (Array.isArray(sources)) {
    const seen = new Set<string>();
    candidate.publicSources = sources.filter((source) => {
      const href = (source as DocumentData)?.href;
      if (!isPublicSourceLink(href as string | null)) return false;
      const key = sourceLinkKey(href as string);
      if (seen.has(key)) return false;
      seen.add(key);
      return true;
    });
  }

  const patch: DocumentData = {};
  const before: DocumentData = {};
  for (const [field, value] of Object.entries(candidate)) {
    const current = valueAt(organizer, field);
    if (stableJson(current) === stableJson(value)) continue;
    patch[field] = value;
    before[field] = current ?? null;
  }
  const next = withDotPatch(organizer, patch);
  return {
    path,
    patch,
    before,
    remainingIssues: organizerPublicContentIssues(
      next as OrganizerPublicContent
    ),
    schemaRegressions: schemaRegressions(organizer, next),
    hash: crypto.createHash("sha256")
      .update(stableJson({path, before, patch}))
      .digest("hex"),
  };
}

/**
 * Hashes a set of document plans so an apply can name what was reviewed.
 * @param {OrganizerPublicContentRepairPlan[]} plans Document plans.
 * @return {string} Order-independent plan-set hash.
 */
export function organizerPublicContentPlanSetHash(
  plans: OrganizerPublicContentRepairPlan[]
): string {
  return crypto.createHash("sha256")
    .update(plans.map((plan) => plan.hash).sort().join("\n"))
    .digest("hex");
}

/**
 * Lists contract errors present after the patch but not before it.
 * @param {DocumentData} before Stored organizer.
 * @param {DocumentData} after Patched organizer.
 * @return {string[]} New schema errors.
 */
function schemaRegressions(before: DocumentData, after: DocumentData) {
  const errorsFor = (value: DocumentData) => validateOrganizerDocument(value) ?
    [] :
    schemaErrorMessages(validateOrganizerDocument);
  const existing = new Set(errorsFor(before));
  return errorsFor(after).filter((error) => !existing.has(error));
}

/**
 * Reads a dot path from a document.
 * @param {DocumentData} value Document.
 * @param {string} field Dot path.
 * @return {unknown} Stored value or undefined.
 */
function valueAt(value: DocumentData, field: string): unknown {
  let cursor: unknown = value;
  for (const segment of field.split(".")) {
    if (!cursor || typeof cursor !== "object") return undefined;
    cursor = (cursor as DocumentData)[segment];
  }
  return cursor;
}

/**
 * Applies a Firestore dot-path update to a copy of a document.
 * @param {DocumentData} value Document.
 * @param {DocumentData} patch Dot-path update.
 * @return {DocumentData} Patched copy.
 */
function withDotPatch(value: DocumentData, patch: DocumentData): DocumentData {
  const next: DocumentData = {...value};
  for (const [field, fieldValue] of Object.entries(patch)) {
    const segments = field.split(".");
    let cursor = next;
    for (const segment of segments.slice(0, -1)) {
      const child = cursor[segment];
      cursor[segment] = child && typeof child === "object" ?
        {...(child as DocumentData)} :
        {};
      cursor = cursor[segment] as DocumentData;
    }
    cursor[segments[segments.length - 1]] = fieldValue;
  }
  return next;
}

/**
 * Serializes a value with sorted object keys.
 * @param {unknown} value Any JSON-like value, including Firestore timestamps.
 * @return {string} Stable JSON.
 */
function stableJson(value: unknown): string {
  if (value === undefined) return "null";
  if (Array.isArray(value)) return `[${value.map(stableJson).join(",")}]`;
  if (value && typeof value === "object") {
    const record = value as DocumentData;
    return `{${Object.keys(record).sort().map((key) =>
      `${JSON.stringify(key)}:${stableJson(record[key])}`).join(",")}}`;
  }
  return JSON.stringify(value);
}
